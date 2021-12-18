use std::ops::Add;

use graphql_ir::{FragmentDefinition, Visitor};
use log::warn;
use relay_transforms::RelayDirective;
use schema::SDLSchema;

use crate::{
    rescript::DefinitionType,
    rescript_ast::{Context, ConverterInstructions, FullEnum},
    rescript_relay_visitor::{RescriptRelayOperationMetaData, RescriptRelayVisitor},
    writer::{Prop, AST},
};

use std::fmt::{Result, Write};

pub fn uncapitalize_string(str: &String) -> String {
    str[..1].to_lowercase().add(&str[1..])
}

pub fn path_to_name(path: &Vec<String>) -> String {
    let mut str = String::from("");

    let mut first = true;

    for path_name in path.iter() {
        if first {
            first = false;
        } else {
            write!(str, "_").unwrap();
        }

        write!(str, "{}", path_name).unwrap();
    }

    str
}

pub fn extract_fragments_from_fragment_spread(ast: &AST) -> Vec<String> {
    match &ast {
        AST::FragmentReference(fragment_names) => {
            fragment_names.iter().map(|name| name.to_string()).collect()
        }
        unmatched => {
            warn!("Found unmapped fragment spread member: {:?}", unmatched);
            vec![]
        }
    }
}

// This unwraps an AST item, meaning it'll extract single union members to its underlying type, handle nullability etc.
pub fn unwrap_ast(ast: &AST) -> (bool, &AST) {
    let (nullable, inner_ast) = match ast {
        AST::Nullable(inner_ast) => (true, inner_ast.as_ref()),
        inner_ast => (false, inner_ast),
    };

    match inner_ast {
        // The Relay compiler will typically output the union AST even if it
        // only holds a single value. This will unwrap that union into its inner
        // value if it's only a single one.
        AST::Union(members) => {
            if members.len() == 0 {
                warn!("Unexpected empty union.");
                (nullable, inner_ast)
            } else if members.len() == 1 {
                // If this contains just one member, return that
                match members.get(0) {
                    None => (nullable, inner_ast),
                    Some(unwrapped_ast) => (nullable, unwrapped_ast),
                }
            } else {
                // More than one member means this is an actual union, so we can return it directly.
                (nullable, inner_ast)
            }
        }
        // We count all other ASTs as already being unwrapped.
        already_unwrapped_ast => (nullable, already_unwrapped_ast),
    }
}

#[derive(Debug)]
pub enum ClassifiedTopLevelObjectType<'a> {
    Object(&'a Vec<Prop>),
    Union(&'a Vec<AST>),
    ArrayWithObject(&'a Vec<Prop>),
    ArrayWithUnion(&'a Vec<AST>),
}

// This classifies top level object types, meaning anything that comes in the
// `export <someTypeName>$<data/variables/response/rawResponse>` form.
pub fn classify_top_level_object_type_ast(ast: &AST) -> Option<ClassifiedTopLevelObjectType<'_>> {
    // TODO: With bubbling etc this should probably handle nullability too...?
    match &ast {
        &AST::ExactObject(props) => Some(ClassifiedTopLevelObjectType::Object(&props)),
        &AST::Union(members) => {
            if members.len() == 1 {
                match members.get(0) {
                    Some(AST::ExactObject(props)) => {
                        Some(ClassifiedTopLevelObjectType::Object(props))
                    }
                    _ => None,
                }
            } else {
                Some(ClassifiedTopLevelObjectType::Union(members))
            }
        }
        &AST::ReadOnlyArray(inner_ast) => {
            match classify_top_level_object_type_ast(inner_ast.as_ref()) {
                Some(ClassifiedTopLevelObjectType::Object(props)) => {
                    Some(ClassifiedTopLevelObjectType::ArrayWithObject(&props))
                }
                Some(ClassifiedTopLevelObjectType::Union(ast)) => {
                    Some(ClassifiedTopLevelObjectType::ArrayWithUnion(&ast))
                }
                _ => None,
            }
        }
        _ => None,
    }
}

// Removes the root_object_name from a path, because we don't need/want that in
// conversion instructions.
pub fn conversion_instruction_path_to_name(path: &Vec<String>) -> String {
    path_to_name(&path[1..].to_vec())
}

#[derive(PartialEq, Eq, Debug)]
pub enum RescriptCustomTypeValue {
    Module,
    Type,
}

// ReScript values/types can end up in the Relay compiler output through custom
// scalar types. RescriptRelay supports custom scalars being either a type, or a
// module that has a `parse` and `serialize` implementation (to allow for
// autoconversion of custom scalars). Because of the ReScript syntax (types are
// always uncapitalized, modules are always capitalized) we can figure out what
// type it is by looking at the string holding the value itself.
pub fn classify_rescript_value_string(str: &String) -> RescriptCustomTypeValue {
    let target_value = str.as_str().split(".").last();

    match target_value {
        None => {
            panic!("Could not classify ReScript value string. {}", str)
        }
        Some(last_value) => {
            let first_char = &last_value[0..1];

            if first_char == first_char.to_uppercase() {
                RescriptCustomTypeValue::Module
            } else {
                RescriptCustomTypeValue::Type
            }
        }
    }
}

pub fn uppercase_first_letter(s: &str) -> String {
    let mut c = s.chars();
    match c.next() {
        None => String::new(),
        Some(f) => f.to_uppercase().collect::<String>() + c.as_str(),
    }
}

pub fn root_name_from_context(context: &Context) -> String {
    match context {
        Context::Fragment => String::from("fragment"),
        Context::RawResponse => String::from("rawResponse"),
        Context::Response => String::from("response"),
        Context::RootObject(root_object_name) => root_object_name.to_string(),
        Context::Variables => String::from("variables"),
        Context::NotRelevant => String::new(),
    }
}

pub fn write_indentation(str: &mut String, indentation: usize) -> Result {
    write!(str, "{}", &"  ".repeat(indentation))
}

pub fn get_enum_definition_body(
    full_enum: &FullEnum,
    indentation: usize,
    as_private: bool,
) -> String {
    let mut str = String::new();

    writeln!(str, "[{}", if as_private { ">" } else { "" }).unwrap();

    for value in &full_enum.values {
        write_indentation(&mut str, indentation + 2).unwrap();
        writeln!(str, "| #{}", value.to_string()).unwrap();
    }

    write_indentation(&mut str, indentation + 1).unwrap();
    writeln!(str, "]").unwrap();

    str
}

pub fn get_rescript_relay_meta_data(
    schema: &SDLSchema,
    typegen_definition: &DefinitionType,
) -> RescriptRelayOperationMetaData {
    let mut state = RescriptRelayOperationMetaData {
        connection_config: None,
        variables_with_connection_data_ids: vec![],
    };

    match &typegen_definition {
        DefinitionType::Fragment(definition) => {
            let mut visitor =
                RescriptRelayVisitor::new(schema, &mut state, String::from("fragment"));
            visitor.visit_fragment(definition)
        }
        DefinitionType::Operation(definition) => {
            let mut visitor =
                RescriptRelayVisitor::new(schema, &mut state, String::from("response"));
            visitor.visit_operation(definition)
        }
    }

    state
}

const DISALLOWED_IDENTIFIERS: &'static [&'static str] = &[
    "and",
    "as",
    "asr",
    "assert",
    "begin",
    "class",
    "constraint",
    "do",
    "while",
    "for",
    "done",
    "while",
    "for",
    "downto",
    "else",
    "end",
    "exception",
    "external",
    "false",
    "for",
    "fun",
    "function",
    "functor",
    "if",
    "in",
    "include",
    "inherit",
    "initializer",
    "land",
    "lazy",
    "let",
    "lor",
    "lsl",
    "lsr",
    "lxor",
    "match",
    "method",
    "mod",
    "module",
    "open",
    "mutable",
    "new",
    "nonrec",
    "object",
    "of",
    "open",
    "open!",
    "or",
    "private",
    "rec",
    "let",
    "module",
    "sig",
    "struct",
    "then",
    "to",
    "true",
    "try",
    "type",
    "val",
    "virtual",
    "val",
    "method",
    "class",
    "when",
    "while",
    "with",
    "switch",
    "fragment",
    "t_fragment",
    "subscription",
    "mutation",
    "response",
    "variables",
    "refetchVariables",
    "t",
    "fragmentRef",
    "fragmentRefs",
    "fragmentRefSelector",
    "operationType",
];

pub fn get_safe_key(original_key: &String) -> (String, Option<String>) {
    if DISALLOWED_IDENTIFIERS.contains(&original_key.as_str()) {
        (format!("{}_", original_key), Some(original_key.to_string()))
    } else {
        (original_key.to_string(), None)
    }
}

pub fn instruction_to_key_value_pair(instruction: &ConverterInstructions) -> (String, String) {
    match &instruction {
        &ConverterInstructions::ConvertNullableProp => (String::from("n"), String::from("")),
        &ConverterInstructions::ConvertNullableArrayContents => {
            (String::from("na"), String::from(""))
        }
        &ConverterInstructions::ConvertUnion(union_record_name) => {
            (String::from("u"), union_record_name.to_string())
        }
        &ConverterInstructions::ConvertCustomField(converter_name) => {
            (String::from("c"), converter_name.to_string())
        }
        &ConverterInstructions::RootObject(object_name) => {
            (String::from("r"), object_name.to_string())
        }
        &ConverterInstructions::ConvertTopLevelNodeField(type_name) => {
            (String::from("tnf"), type_name.to_string())
        }
        &ConverterInstructions::HasFragments => (String::from("f"), String::from("")),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn uncapitalize_strings() {
        assert_eq!(
            uncapitalize_string(&String::from("WayPoint")),
            "wayPoint".to_string()
        );
    }

    #[test]
    fn classify_rescript_value_string_tests() {
        assert_eq!(
            classify_rescript_value_string(&String::from("Some.Module.Here")),
            RescriptCustomTypeValue::Module
        );
        assert_eq!(
            classify_rescript_value_string(&String::from("SomeModule")),
            RescriptCustomTypeValue::Module
        );
        assert_eq!(
            classify_rescript_value_string(&String::from("Some.Module.Here.withType")),
            RescriptCustomTypeValue::Type
        );
        assert_eq!(
            classify_rescript_value_string(&String::from("withType")),
            RescriptCustomTypeValue::Type
        );
    }
}

pub fn is_plural(node: &FragmentDefinition) -> bool {
    RelayDirective::find(&node.directives).map_or(false, |relay_directive| relay_directive.plural)
}
