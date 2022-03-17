use common::{Diagnostic, DiagnosticsResult, Location, WithLocation};
use errors::validate;
use graphql_ir::{Field, LinkedField, Program, ScalarField, ValidationMessage, Validator};
use intern::string_key::{Intern, StringKey};
use schema::Schema;

/// This disallows selecting a bunch of keywords in ReScript. Also disallows
/// uppercased fields. In the future, this should be replaced with proper
/// `@as("")` tags in ReScript. But for now, it's easier to just let the user
/// manually set up a valid alias.
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
                "asr".intern(),
                "assert".intern(),
                "begin".intern(),
                "class".intern(),
                "constraint".intern(),
                "do".intern(),
                "while".intern(),
                "for".intern(),
                "done".intern(),
                "while".intern(),
                "for".intern(),
                "downto".intern(),
                "else".intern(),
                "end".intern(),
                "exception".intern(),
                "external".intern(),
                "false".intern(),
                "for".intern(),
                "fun".intern(),
                "function".intern(),
                "functor".intern(),
                "if".intern(),
                "in".intern(),
                "include".intern(),
                "inherit".intern(),
                "initializer".intern(),
                "land".intern(),
                "lazy".intern(),
                "let".intern(),
                "lor".intern(),
                "lsl".intern(),
                "lsr".intern(),
                "lxor".intern(),
                "match".intern(),
                "method".intern(),
                "mod".intern(),
                "module".intern(),
                "open".intern(),
                "mutable".intern(),
                "new".intern(),
                "nonrec".intern(),
                "object".intern(),
                "of".intern(),
                "open".intern(),
                "open!".intern(),
                "or".intern(),
                "private".intern(),
                "rec".intern(),
                "let".intern(),
                "module".intern(),
                "sig".intern(),
                "struct".intern(),
                "then".intern(),
                "to".intern(),
                "true".intern(),
                "try".intern(),
                "type".intern(),
                "val".intern(),
                "virtual".intern(),
                "val".intern(),
                "method".intern(),
                "class".intern(),
                "when".intern(),
                "while".intern(),
                "with".intern(),
                "switch".intern(),
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
                validate_field_name(&self.reserved_names, alias, field.alias_or_name_location())
            } else {
                validate_field_name(
                    &self.reserved_names,
                    self.program.schema.field(field.definition.item).name,
                    field.alias_or_name_location(),
                )
            },
            self.validate_selections(&field.selections)
        )
    }

    fn validate_scalar_field(&mut self, field: &ScalarField) -> DiagnosticsResult<()> {
        if let Some(alias) = field.alias {
            validate_field_name(&self.reserved_names, alias, field.alias_or_name_location())
        } else {
            validate_field_name(
                &self.reserved_names,
                self.program.schema.field(field.definition.item).name,
                field.alias_or_name_location(),
            )
        }
    }
}

fn validate_field_name(
    reserved_names: &[StringKey],
    field_name: WithLocation<StringKey>,
    location: Location,
) -> DiagnosticsResult<()> {
    let mut validation_errors = vec![];
    let the_field_name_as_str = field_name.item.to_string();

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
            let result = validate_field_name_once(*reserved_name, field_name, location);
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

fn validate_field_name_once(
    reserved_name: StringKey,
    field_name: WithLocation<StringKey>,
    location: Location,
) -> DiagnosticsResult<()> {
    if field_name.item == reserved_name {
        Err(vec![Diagnostic::error(
            ValidationMessage::RescriptRelayDisallowSelectionName(reserved_name),
            location,
        )])
    } else {
        Ok(())
    }
}
