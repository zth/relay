use std::sync::Arc;

use common::{Diagnostic, DiagnosticsResult, DirectiveName, NamedItem, ArgumentName};
use graphql_ir::{LinkedField, Program, ScalarField, Selection, OperationDefinition, Validator, Value, ConstantValue};
use intern::string_key::Intern;
use lazy_static::lazy_static;
use schema::{ObjectID, SDLSchema, Schema, Type};

use crate::ValidationMessage;
use relay_config::ProjectConfig;

lazy_static! {
    pub static ref EXHAUSTIVE_DIRECTIVE_NAME: DirectiveName = DirectiveName("exhaustive".intern());
    pub static ref IGNORE_ARG_NAME: ArgumentName = ArgumentName("ignore".intern());
    pub static ref NON_EXHAUSTIVE_DIRECTIVE_NAME: DirectiveName = DirectiveName("nonExhaustive".intern());
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
        Self { schema, program, project_config, is_mutation: false, errors: vec![] }
    }

    fn validate_exhaustive(&mut self, field: &LinkedField) {
        let mut ignored = std::collections::HashSet::new();
        let mut has_directive = false;
        if let Some(directive) = field.directives.named(*EXHAUSTIVE_DIRECTIVE_NAME) {
            has_directive = true;
            if let Some(arg) = directive.arguments.named(*IGNORE_ARG_NAME) {
                if let Value::Constant(ConstantValue::List(items)) = &arg.value.item {
                    for item in items {
                        if let ConstantValue::String(name) = item {
                            ignored.insert(*name);
                        }
                    }
                }
            }
        } else if self.project_config.auto_exhaustive_mutations
            && self.is_mutation
            && self.field_is_top_level_mutation(field)
            && field.directives.named(*NON_EXHAUSTIVE_DIRECTIVE_NAME).is_none()
        {
            has_directive = true;
        }
        if !has_directive {
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
        for member in &self.schema.union(union_id).members {
            let member_name = self.schema.get_type_name(Type::Object(*member));
            if ignored.contains(&member_name) {
                continue;
            }
            if !self.has_selection_for_object(field, *member) {
                let member_name = self.schema.get_type_name(Type::Object(*member));
                let field_name = field.alias.map_or(field_def.name.item, |a| a.item);
                self.errors.push(Diagnostic::error(
                    ValidationMessage::MissingExhaustiveUnionMember {
                        field_name,
                        member_name,
                    },
                    field.definition.location,
                ));
            }
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
}

