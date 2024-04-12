use common::{Diagnostic, DiagnosticsResult, Location};
use errors::validate;
use graphql_ir::{
    Field, LinkedField, OperationDefinition, Program, ScalarField, ValidationMessage, Validator,
};
use intern::string_key::{Intern, StringKey};
use schema::Schema;

/// This disallows selecting/naming variables a bunch of keywords in ReScript.
/// Also disallows uppercased fields.
pub fn rescript_relay_disallow_invalid_names(program: &Program) -> DiagnosticsResult<()> {
    let mut validator = RescriptRelayTransformDisallowInvalidNames::new(program);
    validator.validate_program(program)
}

struct RescriptRelayTransformDisallowInvalidNames<'program> {
    program: &'program Program,
    reserved_names: Vec<StringKey>,
}

impl<'program> RescriptRelayTransformDisallowInvalidNames<'program> {
    fn new(program: &'program Program) -> Self {
        Self {
            program,
            reserved_names: vec![
                "and".intern(),
                "as".intern(),
                "assert".intern(),
                "constraint".intern(),
                "else".intern(),
                "exception".intern(),
                "external".intern(),
                "false".intern(),
                "for".intern(),
                "if".intern(),
                "in".intern(),
                "include".intern(),
                "lazy".intern(),
                "let".intern(),
                "module".intern(),
                "mutable".intern(),
                "of".intern(),
                "open".intern(),
                "rec".intern(),
                "switch".intern(),
                "true".intern(),
                "try".intern(),
                "type".intern(),
                "when".intern(),
                "while".intern(),
                "with".intern(),
                "private".intern(),
                "fragment".intern(),
                "t_fragment".intern(),
                "subscription".intern(),
                "mutation".intern(),
                "response".intern(),
                "variables".intern(),
                "refetchVariables".intern(),
                "t".intern(),
                "fragmentRef".intern(),
                "fragmentRefs".intern(),
                "updatableFragmentRefs".intern(),
                "fragmentRefSelector".intern(),
                "operationType".intern(),
            ],
        }
    }
}

impl Validator for RescriptRelayTransformDisallowInvalidNames<'_> {
    const NAME: &'static str = "RescriptRelayTransformDisallowInvalidNames";
    const VALIDATE_ARGUMENTS: bool = false;
    const VALIDATE_DIRECTIVES: bool = false;

    fn validate_linked_field(&mut self, field: &LinkedField) -> DiagnosticsResult<()> {
        validate!(
            if let Some(alias) = field.alias {
                validate_identifier(
                    &self.reserved_names,
                    alias.item,
                    field.alias_or_name_location(),
                )
            } else {
                validate_identifier(
                    &self.reserved_names,
                    self.program.schema.field(field.definition.item).name.item,
                    field.alias_or_name_location(),
                )
            },
            self.validate_selections(&field.selections)
        )
    }

    fn validate_scalar_field(&mut self, field: &ScalarField) -> DiagnosticsResult<()> {
        if let Some(alias) = field.alias {
            validate_identifier(
                &self.reserved_names,
                alias.item,
                field.alias_or_name_location(),
            )
        } else {
            validate_identifier(
                &self.reserved_names,
                self.program.schema.field(field.definition.item).name.item,
                field.alias_or_name_location(),
            )
        }
    }

    fn validate_operation(&mut self, operation: &OperationDefinition) -> DiagnosticsResult<()> {
        let diagnostics: Vec<Diagnostic> = operation
            .variable_definitions
            .iter()
            .filter_map(|variable| {
                match validate_identifier(
                    &self.reserved_names,
                    variable.name.item.0,
                    variable.name.location,
                ) {
                    Ok(_) => None,
                    Err(diagnostic) => Some(diagnostic),
                }
            })
            .flatten()
            .collect();

        if diagnostics.is_empty() {
            Ok(())
        } else {
            Err(diagnostics)
        }
    }
}

fn validate_identifier(
    reserved_names: &[StringKey],
    identifier: StringKey,
    location: Location,
) -> DiagnosticsResult<()> {
    let mut validation_errors = vec![];
    let the_field_name_as_str = identifier.to_string();

    let first_letter_as_uppercase = the_field_name_as_str.chars().collect::<Vec<char>>()[0]
        .to_uppercase()
        .nth(0)
        .unwrap();

    let first_letter_untouched = the_field_name_as_str.chars().collect::<Vec<char>>()[0];

    // Check if first letter is uppercased
    if first_letter_untouched.is_alphabetic() && first_letter_as_uppercase == first_letter_untouched
    {
        validation_errors.push(Diagnostic::error(
            ValidationMessage::RescriptRelayDisallowCapitalizedNames,
            location,
        ));

        Err(validation_errors)
    } else {
        for reserved_name in reserved_names {
            let result = validate_identifier_once(*reserved_name, identifier, location);
            if let Err(errors) = result {
                for err in errors {
                    validation_errors.push(err);
                }
            }
        }
        if validation_errors.is_empty() {
            Ok(())
        } else {
            Err(validation_errors)
        }
    }
}

fn validate_identifier_once(
    reserved_name: StringKey,
    identifier: StringKey,
    location: Location,
) -> DiagnosticsResult<()> {
    if identifier == reserved_name {
        Err(vec![Diagnostic::error(
            ValidationMessage::RescriptRelayDisallowSelectionName(reserved_name),
            location,
        )])
    } else {
        Ok(())
    }
}
