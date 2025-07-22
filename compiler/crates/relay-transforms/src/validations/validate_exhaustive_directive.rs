use std::sync::Arc;

use common::ArgumentName;
use common::Diagnostic;
use common::DiagnosticsResult;
use common::DirectiveName;
use common::NamedItem;
use graphql_ir::ConstantValue;
use graphql_ir::FragmentDefinition;
use graphql_ir::LinkedField;
use graphql_ir::OperationDefinition;
use graphql_ir::Program;
use graphql_ir::ScalarField;
use graphql_ir::Selection;
use graphql_ir::Validator;
use graphql_ir::Value;
use intern::string_key::Intern;
use intern::string_key::StringKey;
use lazy_static::lazy_static;
use relay_config::ProjectConfig;
use schema::ObjectID;
use schema::SDLSchema;
use schema::Schema;
use schema::Type;

use crate::ValidationMessage;

lazy_static! {
    pub static ref EXHAUSTIVE_DIRECTIVE_NAME: DirectiveName = DirectiveName("exhaustive".intern());
    pub static ref IGNORE_ARG_NAME: ArgumentName = ArgumentName("ignore".intern());
    pub static ref DISABLED_ARG_NAME: ArgumentName = ArgumentName("disabled".intern());
}

pub fn validate_exhaustive_directive(
    program: &Program,
    project_config: &ProjectConfig,
) -> DiagnosticsResult<()> {
    let mut validator = ExhaustiveDirectiveValidator::new(&program.schema, program, project_config);
    validator.validate_program(program)?;

    if validator.errors.is_empty() {
        Ok(())
    } else {
        Err(validator.errors)
    }
}

struct ExhaustiveDirectiveValidator<'schema, 'program, 'pc> {
    schema: &'schema Arc<SDLSchema>,
    program: &'program Program,
    project_config: &'pc ProjectConfig,
    is_mutation: bool,
    errors: Vec<Diagnostic>,
}

impl<'schema, 'program, 'pc> ExhaustiveDirectiveValidator<'schema, 'program, 'pc> {
    fn new(
        schema: &'schema Arc<SDLSchema>,
        program: &'program Program,
        project_config: &'pc ProjectConfig,
    ) -> Self {
        Self {
            schema,
            program,
            project_config,
            is_mutation: false,
            errors: vec![],
        }
    }

    fn parse_exhaustive_directive_args(
        directive: &graphql_ir::Directive,
    ) -> (std::collections::HashSet<StringKey>, bool) {
        let mut ignored = std::collections::HashSet::new();
        let mut disabled = false;

        if let Some(arg) = directive.arguments.named(*IGNORE_ARG_NAME) {
            if let Value::Constant(ConstantValue::List(items)) = &arg.value.item {
                for item in items {
                    if let ConstantValue::String(name) = item {
                        ignored.insert(*name);
                    }
                }
            }
        }

        if let Some(arg) = directive.arguments.named(*DISABLED_ARG_NAME) {
            if let Value::Constant(ConstantValue::Boolean(value)) = &arg.value.item {
                disabled = *value;
            }
        }

        (ignored, disabled)
    }

    fn check_exhaustive_coverage(
        &self,
        union_id: schema::UnionID,
        ignored: &std::collections::HashSet<StringKey>,
        has_selection_fn: impl Fn(ObjectID) -> bool,
    ) -> Vec<StringKey> {
        let mut missing_members = Vec::new();

        for member in &self.schema.union(union_id).members {
            let member_name = self.schema.get_type_name(Type::Object(*member));
            if ignored.contains(&member_name) {
                continue;
            }
            if !has_selection_fn(*member) {
                missing_members.push(member_name);
            }
        }

        missing_members
    }

    fn validate_exhaustive(&mut self, field: &LinkedField) {
        let mut ignored = std::collections::HashSet::new();
        let mut has_directive = false;
        let mut disabled = false;

        if let Some(directive) = field.directives.named(*EXHAUSTIVE_DIRECTIVE_NAME) {
            has_directive = true;
            let (parsed_ignored, parsed_disabled) =
                Self::parse_exhaustive_directive_args(directive);
            ignored = parsed_ignored;
            disabled = parsed_disabled;
        } else if self.project_config.auto_exhaustive_mutations
            && self.is_mutation
            && self.field_is_top_level_mutation(field)
        {
            has_directive = true;
        }

        if !has_directive || disabled {
            return;
        }

        let field_def = self.schema.field(field.definition.item);
        let return_type = field_def.type_.inner();
        let union_id = match return_type {
            Type::Union(id) => id,
            _ => {
                self.errors.push(Diagnostic::error(
                    ValidationMessage::ExhaustiveDirectiveOnNonUnionField,
                    field.definition.location,
                ));
                return;
            }
        };

        let missing_members = self.check_exhaustive_coverage(union_id, &ignored, |object_id| {
            self.has_selection_for_object(field, object_id)
        });

        if !missing_members.is_empty() {
            let field_name = field.alias.map_or(field_def.name.item, |a| a.item);
            let member_names = missing_members
                .iter()
                .map(|name| format!("'{}'", name))
                .collect::<Vec<_>>()
                .join(", ");

            self.errors.push(Diagnostic::error(
                ValidationMessage::MissingExhaustiveUnionMembersOnField {
                    field_name,
                    member_names,
                },
                field.definition.location,
            ));
        }
    }

    fn validate_exhaustive_fragment(&mut self, fragment: &FragmentDefinition) {
        let Some(directive) = fragment.directives.named(*EXHAUSTIVE_DIRECTIVE_NAME) else {
            return;
        };

        let (ignored, disabled) = Self::parse_exhaustive_directive_args(directive);

        if disabled {
            return;
        }

        let union_id = match fragment.type_condition {
            Type::Union(id) => id,
            _ => {
                self.errors.push(Diagnostic::error(
                    ValidationMessage::ExhaustiveDirectiveOnNonUnionField,
                    fragment.name.location,
                ));
                return;
            }
        };

        let missing_members = self.check_exhaustive_coverage(union_id, &ignored, |object_id| {
            self.has_selection_for_object_in_fragment(fragment, object_id)
        });

        if !missing_members.is_empty() {
            let fragment_name = fragment.name.item.into();
            let member_names = missing_members
                .iter()
                .map(|name| format!("'{}'", name))
                .collect::<Vec<_>>()
                .join(", ");

            self.errors.push(Diagnostic::error(
                ValidationMessage::MissingExhaustiveUnionMembersOnFragment {
                    fragment_name,
                    member_names,
                },
                fragment.name.location,
            ));
        }
    }

    fn has_selection_for_object(&self, field: &LinkedField, object_id: ObjectID) -> bool {
        let obj_type = Type::Object(object_id);
        for selection in &field.selections {
            match selection {
                Selection::InlineFragment(frag) => {
                    if frag.type_condition == Some(obj_type) {
                        return true;
                    }
                }
                Selection::FragmentSpread(frag_spread) => {
                    if let Some(frag_def) = self.program.fragment(frag_spread.fragment.item) {
                        if frag_def.type_condition == obj_type {
                            return true;
                        }
                    }
                }
                _ => {}
            }
        }
        false
    }

    fn has_selection_for_object_in_fragment(
        &self,
        fragment: &FragmentDefinition,
        object_id: ObjectID,
    ) -> bool {
        let obj_type = Type::Object(object_id);
        for selection in &fragment.selections {
            match selection {
                Selection::InlineFragment(frag) => {
                    if frag.type_condition == Some(obj_type) {
                        return true;
                    }
                }
                Selection::FragmentSpread(frag_spread) => {
                    if let Some(frag_def) = self.program.fragment(frag_spread.fragment.item) {
                        if frag_def.type_condition == obj_type {
                            return true;
                        }
                    }
                }
                _ => {}
            }
        }
        false
    }

    fn field_is_top_level_mutation(&self, field: &LinkedField) -> bool {
        match (
            self.schema.mutation_type(),
            self.schema.field(field.definition.item).parent_type,
        ) {
            (Some(Type::Object(root)), Some(Type::Object(parent))) => root == parent,
            _ => false,
        }
    }
}

impl Validator for ExhaustiveDirectiveValidator<'_, '_, '_> {
    const NAME: &'static str = "ExhaustiveDirectiveValidator";
    const VALIDATE_ARGUMENTS: bool = false;
    const VALIDATE_DIRECTIVES: bool = false;

    fn validate_linked_field(&mut self, field: &LinkedField) -> DiagnosticsResult<()> {
        self.validate_exhaustive(field);
        self.default_validate_linked_field(field)
    }

    fn validate_operation(&mut self, operation: &OperationDefinition) -> DiagnosticsResult<()> {
        let prev = self.is_mutation;
        self.is_mutation = operation.is_mutation();
        let result = self.default_validate_operation(operation);
        self.is_mutation = prev;
        result
    }

    fn validate_scalar_field(&mut self, field: &ScalarField) -> DiagnosticsResult<()> {
        if field.directives.named(*EXHAUSTIVE_DIRECTIVE_NAME).is_some() {
            self.errors.push(Diagnostic::error(
                ValidationMessage::ExhaustiveDirectiveOnNonUnionField,
                field.definition.location,
            ));
        }
        self.default_validate_scalar_field(field)
    }

    fn validate_fragment(&mut self, fragment: &FragmentDefinition) -> DiagnosticsResult<()> {
        self.validate_exhaustive_fragment(fragment);
        self.default_validate_fragment(fragment)
    }
}
