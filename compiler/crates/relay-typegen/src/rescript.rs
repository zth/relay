/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

use fnv::FnvHashSet;
use graphql_ir::reexport::StringKey;
use graphql_ir::{FragmentDefinition, OperationDefinition};
use graphql_syntax::OperationKind;
use itertools::Itertools;
use log::{debug, warn};

use crate::rescript_ast::*;
use crate::rescript_relay_visitor::RescriptRelayOperationMetaData;
use crate::rescript_utils::*;
use crate::writer::{Prop, Writer, AST};
use std::collections::HashMap;
use std::fmt::{Result, Write};

// Fragments in Relay can be on either an abstract type (union/interface) or on
// a concrete type (object). It can also be plural, meaning it's an array. This
// enum allows us to keep track of what the current fragment we're looking at
// is, and output types accordingly.
#[derive(Debug)]
enum TopLevelFragmentType {
    Object(Object),
    Union(Union),
    ArrayWithObject(Object),
    ArrayWithUnion(Union),
}

// The current operation type definition type, as given to us by the Relay
// compiler.
#[derive(Debug)]
pub enum DefinitionType {
    Fragment(FragmentDefinition),
    Operation(OperationDefinition),
}

#[derive(Debug)]
pub struct ReScriptPrinter {
    // All encountered enums.
    enums: Vec<FullEnum>,

    // All encountered regular objects.
    objects: Vec<Object>,

    // All encountered input objects. These are recursive by default.
    input_objects: Vec<Object>,

    // All encountered unions.
    unions: Vec<Union>,

    // If there's a definition for variables (can be found in anything but fragments) in this artifact.
    variables: Option<Object>,

    // This is available for anything but fragments. The bool is whether the
    // response is nullable or not. Nullability of responses happen when the
    // @required directive bubbles the nullability all the way up to the
    // response top level.
    response: Option<(bool, Object)>,

    // The @raw_response_type annotation on operations will populate this. It
    // holds a type that represents the full, raw response Relay expects from
    // the server, and is primarily used for optimistic updates.
    raw_response: Option<Object>,

    // If this is a fragment, its structure will be here. The bool is whether
    // the fragment is nullable or not. Nullability of fragments happen when the
    // @required directive bubbles the nullability all the way up to the
    // fragment top level.
    fragment: Option<(bool, TopLevelFragmentType)>,

    // The raw typegen definition fed to us by the Relay compiler. Useful for
    // looking up things not communicated directly by the AST representing the
    // types the compiler also feeds us.
    typegen_definition: DefinitionType,

    // This holds all conversion instructions we've found when traversing the
    // full types and artifact. Read more in the file for conversion
    // instructions.
    conversion_instructions: Vec<InstructionContainer>,

    // This holds meta data for this current operation, which we extract in "rescript_relay_visitor".
    operation_meta_data: RescriptRelayOperationMetaData,
}

// This figures out what type identifiers found in the code actually is, by
// matching the identifier name against all found enums and input objects.
enum ClassifiedIdentifier<'a> {
    Enum(&'a FullEnum),
    InputObject(&'a Object),
    RawIdentifier(String),
}

// This classifies an identifier, meaning it looks up whether its an enum or an
// input object we know of locally in the current context.
fn classify_identifier<'a>(
    state: &'a mut ReScriptPrinter,
    identifier: &'a StringKey,
) -> ClassifiedIdentifier<'a> {
    let identifier_as_string = identifier.to_string();
    let identifier_uncapitalized = uncapitalize_string(&identifier_as_string);

    if let Some(full_enum) = state
        .enums
        .iter()
        .find(|full_enum| full_enum.name == identifier_as_string)
    {
        ClassifiedIdentifier::Enum(full_enum)
    } else if let Some(input_object) = state
        .input_objects
        .iter()
        .find(|input_object| input_object.record_name == identifier_uncapitalized)
    {
        ClassifiedIdentifier::InputObject(input_object)
    } else {
        ClassifiedIdentifier::RawIdentifier(identifier_as_string)
    }
}

// Turns an AST element into a prop value.
fn ast_to_prop_value(
    state: &mut ReScriptPrinter,
    current_path: Vec<String>,
    ast: &AST,
    key: &String,
    optional: bool,
    found_in_union: bool,
    found_in_array: bool,
    context: &Context,
) -> Option<PropValue> {
    let (nullable, value) = unwrap_ast(ast);
    let is_nullable = nullable || optional;

    // Since array re-uses this function to figure out the array contents, we
    // don't need to add the conversion instruction for nullability again here
    // if we're in an array, since that's handled by
    // ConvertNullableArrayContents.
    if is_nullable && !found_in_array {
        let mut nullable_path = current_path.to_vec();
        nullable_path.push(key.to_string());

        state.conversion_instructions.push(InstructionContainer {
            context: context.clone(),
            at_path: nullable_path,
            instruction: ConverterInstructions::ConvertNullableProp,
        });
    }

    // Ensure that the key is safe, meaning it's not an illegal identifier in
    // ReScript. If it is, we'll need to map it via the @as decorator when we
    // print the types.
    let (safe_key, original_key) = get_safe_key(key);

    // We do special treatment for any variable definition in
    // mutations/subscriptions which is passed into `connections` of a
    // store updater directive (like @appendNode, @deleteEdge, etc).
    // Anytime we encounter that, we turn that array<string> into
    // array<RescriptRelay.dataId>, because that's what it actually is
    // in its underlying form, a data id. So, this little weird thing
    // handles that.
    if context == &Context::Variables
        && found_in_array
        && current_path.len() == 1 // Path length on 1 means that we're on the top level
        && state
            .operation_meta_data
            .variables_with_connection_data_ids
            .contains(key)
    {
        return Some(PropValue {
            key: safe_key,
            original_key,
            comment: None,
            nullable: is_nullable,
            prop_type: Box::new(PropType::DataId),
        });
    }

    match value {
        AST::Boolean => Some(PropValue {
            key: safe_key,
            original_key,
            comment: None,
            nullable: is_nullable,
            prop_type: Box::new(PropType::Scalar(ScalarValues::Boolean)),
        }),
        AST::String => Some(PropValue {
            key: safe_key,
            original_key,
            comment: None,
            nullable: is_nullable,
            prop_type: Box::new(PropType::Scalar(ScalarValues::String)),
        }),
        AST::Number => Some(PropValue {
            key: safe_key,
            original_key,
            comment: None,
            nullable: is_nullable,
            prop_type: Box::new(PropType::Scalar(ScalarValues::Float)),
        }),
        AST::Any => Some(PropValue {
            key: safe_key,
            original_key,
            comment: None,
            nullable: is_nullable,
            prop_type: Box::new(PropType::Scalar(ScalarValues::Any)),
        }),
        AST::StringLiteral(literal) => Some(PropValue {
            key: safe_key,
            original_key,
            comment: None,
            nullable: is_nullable,
            prop_type: Box::new(PropType::StringLiteral(literal.to_string())),
        }),
        AST::ReadOnlyArray(ast) => {
            // We know that this is a list, and we know
            // if it's nullable or not. Time to figure
            // out what it contains!
            match ast_to_prop_value(
                state,
                current_path.to_vec(),
                ast.as_ref(),
                key,
                // It's important that we reset the optional value here, since
                // we don't yet know whether the array _contents_ are optional
                // or not.
                false,
                found_in_union,
                true,
                context,
            ) {
                None => {
                    warn!("Could not extract type from array. This should not happen.");
                    None
                }
                Some(prop_value) => {
                    if prop_value.nullable {
                        let mut nullable_path = current_path.to_vec();
                        nullable_path.push(key.to_string());
                        state.conversion_instructions.push(InstructionContainer {
                            context: context.clone(),
                            at_path: nullable_path,
                            instruction: ConverterInstructions::ConvertNullableArrayContents,
                        });
                    }

                    Some(PropValue {
                        key: safe_key,
                        original_key,
                        comment: None,
                        nullable: is_nullable,
                        prop_type: Box::new(PropType::Array((
                            prop_value.nullable,
                            prop_value.prop_type,
                        ))),
                    })
                }
            }
        }
        AST::ExactObject(props) => {
            let mut new_at_path = current_path.clone();
            new_at_path.push(key.to_string());
            let record_name = path_to_name(&new_at_path);

            let obj = Object {
                at_path: new_at_path.clone(),
                record_name: record_name.clone(),
                comment: None,
                values: get_object_props(state, &new_at_path, props, found_in_union, context),
                found_in_union,
            };

            state.objects.push(obj);

            Some(PropValue {
                key: safe_key,
                original_key,
                comment: None,
                nullable: is_nullable,
                prop_type: Box::new(PropType::RecordReference(record_name.clone())),
            })
        }
        AST::Union(members) => {
            let mut new_at_path = current_path.clone();
            new_at_path.push(key.to_string());

            // The following applies only when using the top level node field in
            // combination with selecting fields on a _single_ type only. So
            // node(id: $id) { ... on User { ... } }.
            // ---
            // We do a bit of special treatment of the top level node interface
            // field here, since it's a widely used, cache-enhanced way of
            // pulling out single entities. However, when using it for that
            // purpose, it's annoying to have to pattern match on an actual type
            // (that's the only thing you'll want anyway). So, since we know
            // what type you're after, we collapse that one member union into an
            // option, and do the conversion automatically for the developer,
            // behind the scenes.
            if key.as_str() == "node" && members.len() == 2 {
                if let Some((typename, props)) = get_first_union_member_ast_and_typename(&members) {
                    let object = Object {
                        at_path: new_at_path.clone(),
                        comment: None,
                        found_in_union: false,
                        record_name: path_to_name(&new_at_path),
                        values: get_object_props(state, &new_at_path, props, false, context),
                    };

                    let object_record_name = object.record_name.to_string();

                    state.conversion_instructions.push(InstructionContainer {
                        context: context.clone(),
                        at_path: new_at_path.clone(),
                        instruction: ConverterInstructions::ConvertTopLevelNodeField(typename),
                    });

                    state.objects.push(object);

                    return Some(PropValue {
                        key: safe_key,
                        original_key,
                        comment: None,
                        nullable: is_nullable,
                        prop_type: Box::new(PropType::RecordReference(object_record_name.clone())),
                    });
                }
            }

            // If it's not the top level node interface (with a single fragment
            // spread selection), proceed treating it like a regular union.
            let union_members = extract_union_members(state, &new_at_path, members, context);

            let union_record_name = path_to_name(&new_at_path);
            let union = Union {
                at_path: new_at_path.clone(),
                record_name: union_record_name.to_string(),
                comment: None,
                members: union_members,
            };

            state.unions.push(union);

            state.conversion_instructions.push(InstructionContainer {
                context: context.clone(),
                at_path: new_at_path.clone(),
                instruction: ConverterInstructions::ConvertUnion(union_record_name.to_string()),
            });

            Some(PropValue {
                key: safe_key,
                original_key,
                comment: None,
                nullable: is_nullable,
                prop_type: Box::new(PropType::UnionReference(union_record_name.to_string())),
            })
        }
        AST::RawType(identifier) | AST::Identifier(identifier) => {
            let result = match classify_identifier(state, identifier) {
                ClassifiedIdentifier::Enum(full_enum) => Some(PropValue {
                    key: safe_key,
                    original_key,
                    comment: None,
                    nullable: is_nullable,
                    prop_type: Box::new(PropType::Enum(full_enum.name.to_string())),
                }),
                ClassifiedIdentifier::InputObject(input_object) => {
                    let mut new_at_path = current_path.clone();
                    new_at_path.push(key.to_string());

                    Some(PropValue {
                        key: safe_key,
                        original_key,
                        comment: None,
                        nullable: is_nullable,
                        prop_type: Box::new(PropType::InputObjectReference(
                            input_object.record_name.to_string(),
                        )),
                    })
                }
                ClassifiedIdentifier::RawIdentifier(identifier) => {
                    let mut new_at_path = current_path.clone();
                    new_at_path.push(key.to_string());

                    // Add a conversion instruction if this is a custom type
                    // that's mapped as a ReScript module (meaning it's supposed
                    // to be autoconverted by RescriptRelay).
                    match classify_rescript_value_string(&identifier) {
                        RescriptCustomTypeValue::Module => {
                            state.conversion_instructions.push(InstructionContainer {
                                context: context.clone(),
                                at_path: new_at_path,
                                instruction: ConverterInstructions::ConvertCustomField(
                                    identifier.to_string(),
                                ),
                            })
                        }
                        RescriptCustomTypeValue::Type => (),
                    }

                    Some(PropValue {
                        key: safe_key,
                        original_key,
                        comment: None,
                        nullable: is_nullable,
                        prop_type: Box::new(PropType::RawIdentifier(identifier)),
                    })
                }
            };

            // We make sure that any input object reference is picked up here,
            // and has an appropriate conversion instruction added for it.
            match &result {
                None => (),
                Some(prop_value) => match &prop_value.prop_type.as_ref() {
                    &PropType::InputObjectReference(record_name) => {
                        let mut new_at_path = current_path.clone();
                        new_at_path.push(key.to_string());

                        state.conversion_instructions.push(InstructionContainer {
                            context: context.clone(),
                            at_path: new_at_path.clone(),
                            instruction: ConverterInstructions::RootObject(record_name.to_string()),
                        });
                    }
                    _ => (),
                },
            }

            result
        }
        AST::OtherTypename | AST::Local3DPayload(_, _) | AST::ActorChangePoint(_) => {
            // These are ignored for now, but might be supported in the future.
            None
        }
        _ => None,
    }
}

fn get_first_union_member_ast_and_typename(members: &Vec<AST>) -> Option<(String, &Vec<Prop>)> {
    members.iter().find_map(|member| match member {
        AST::ExactObject(props) => {
            // The type of each union member is inside of the
            // __typename string literal, so we need to look for
            // that
            props.iter().find_map(|prop| match &prop {
                &Prop::GetterSetterPair(_) | &Prop::Spread(_) => None,
                &Prop::KeyValuePair(key_value_pair) => {
                    match (&key_value_pair.key.to_string()[..], &key_value_pair.value) {
                        ("__typename", AST::StringLiteral(typename)) => {
                            Some((typename.to_string(), props))
                        }
                        _ => None,
                    }
                }
            })
        }
        _ => None,
    })
}

fn extract_union_members(
    state: &mut ReScriptPrinter,
    current_path: &Vec<String>,
    members: &Vec<AST>,
    context: &Context,
) -> Vec<UnionMember> {
    let union_members: Vec<UnionMember> = members
        .iter()
        .filter_map(|member| match member {
            AST::ExactObject(props) => {
                // The type of each union member is inside of the
                // __typename string literal, so we need to look for
                // that
                let union_member_typename = props.iter().find_map(|prop| match &prop {
                    &Prop::GetterSetterPair(_) | &Prop::Spread(_) => None,
                    &Prop::KeyValuePair(key_value_pair) => {
                        match (&key_value_pair.key.to_string()[..], &key_value_pair.value) {
                            ("__typename", AST::StringLiteral(typename)) => {
                                Some(typename.to_string())
                            }
                            _ => None,
                        }
                    }
                });

                if let Some(member_type) = union_member_typename {
                    let mut new_unioned_path = current_path.clone();
                    new_unioned_path.push(member_type.to_string());

                    let member_fields =
                        get_object_props(state, &new_unioned_path, props, true, context);

                    let union_member_record_name = path_to_name(&new_unioned_path);
                    let union_member_shape = Object {
                        at_path: new_unioned_path.clone(),
                        comment: None,
                        record_name: union_member_record_name.to_string(),
                        values: member_fields,
                        found_in_union: true,
                    };

                    state.objects.push(union_member_shape);

                    Some(UnionMember {
                        typename: member_type,
                        member_record_name: union_member_record_name.to_string(),
                    })
                } else {
                    None
                }
            }
            _ => None,
        })
        .collect();

    union_members
}

fn get_object_props(
    state: &mut ReScriptPrinter,
    current_path: &Vec<String>,
    props: &Vec<Prop>,
    found_in_union: bool,
    context: &Context,
) -> Vec<PropValue> {
    props
        .iter()
        .filter_map(|prop| match &prop {
            &Prop::Spread(_) | &Prop::GetterSetterPair(_) => {
                // Handle when we understand what this actually is
                None
            }
            &Prop::KeyValuePair(key_value_pair) => {
                let key = key_value_pair.key.to_string();

                match &key[..] {
                    "__id" => {
                        // Anything named `__id` is an internal Relay store id, which we
                        // have our own type for in RescriptRelay
                        // (RescriptRelay.dataId). So, we can safely assume that
                        // anything named __id should be a dataId.
                        Some(PropValue {
                            key: String::from("__id"),
                            original_key: None,
                            comment: None,
                            nullable: key_value_pair.optional,
                            prop_type: Box::new(PropType::DataId),
                        })
                    }
                    "$fragmentSpreads" => {
                        // `$fragmentSpreads` is what the Relay compiler outputs
                        // as a prop containing all of the fragment spreads an
                        // object has on it. We call that `fragmentRefs` in
                        // RescriptRelay, so rename to that and print
                        // accordingly.

                        // Add a conversion instruction for this path
                        state.conversion_instructions.push(InstructionContainer {
                            context: context.clone(),
                            at_path: current_path.clone(),
                            instruction: ConverterInstructions::HasFragments,
                        });

                        Some(PropValue {
                            key: String::from("fragmentRefs"),
                            original_key: None,
                            comment: None,
                            nullable: false,
                            prop_type: Box::new(PropType::FragmentSpreads(
                                extract_fragments_from_fragment_spread(&key_value_pair.value),
                            )),
                        })
                    }
                    _ => {
                        if key.as_str().starts_with("$") {
                            // Internal Relay types typically come prefixed with
                            // "&". Ignore those unless we have an explicit
                            // strategy to handle them.
                            debug!("Internal prop found: {}", key);
                            None
                        } else {
                            ast_to_prop_value(
                                state,
                                current_path.clone(),
                                &key_value_pair.value,
                                &key,
                                key_value_pair.optional,
                                found_in_union,
                                false,
                                context,
                            )
                        }
                    }
                }
            }
        })
        .collect()
}

fn write_enum_definitions(str: &mut String, indentation: usize, full_enum: &FullEnum) -> Result {
    // We start by printing a private version of this enum. Using this enum will
    // enforce, at the type level, that you handle the fall-through case. This
    // version of the enum is the version that the enum is represented as
    // whenever it's *coming from the server*, because anytime an enum comes
    // from the server, it might've changed, and you should handle that.
    write_indentation(str, indentation).unwrap();
    writeln!(
        str,
        "type enum_{} = private {}",
        full_enum.name,
        get_enum_definition_body(&full_enum, indentation, true)
    )
    .unwrap();

    // Next, we'll output an enum suffixed with "input". This enum is *closed*,
    // meaning it won't force you to handle fall through cases. This version of
    // the enum is used whenever the enum appears in inputs.
    write_indentation(str, indentation).unwrap();
    writeln!(
        str,
        "type enum_{}_input = {}",
        full_enum.name,
        get_enum_definition_body(&full_enum, indentation, false)
    )
    .unwrap();

    writeln!(str, "\n").unwrap();

    Ok(())
}

fn get_object_prop_value(
    state: &Box<ReScriptPrinter>,
    prop_value: &PropType,
    context: &Context,
    indentation: usize,
) -> String {
    match &prop_value {
        &PropType::DataId => String::from("RescriptRelay.dataId"),
        &PropType::Enum(enum_name) => match &context {
            Context::Variables => {
                match state
                    .enums
                    .iter()
                    .find(|full_enum| full_enum.name == enum_name.to_string())
                {
                    None => {
                        warn!("Did not find enum");
                        String::from("invalid_enum")
                    }
                    Some(full_enum) => format!(
                        "{}",
                        get_enum_definition_body(full_enum, indentation, false)
                    ),
                }
            }
            _ => format!("enum_{}", enum_name),
        },
        &PropType::StringLiteral(literal) => format!("[ | #{}]", literal),
        &PropType::InputObjectReference(input_object_name) => input_object_name.to_string(),
        &PropType::RecordReference(record_name) => record_name.to_string(),
        &PropType::UnionReference(union_record_name) => union_record_name.to_string(),
        &PropType::RawIdentifier(raw_identifier) => {
            match classify_rescript_value_string(&raw_identifier) {
                RescriptCustomTypeValue::Type => raw_identifier.to_string(),
                RescriptCustomTypeValue::Module => format!("{}.t", raw_identifier),
            }
        }
        &PropType::Scalar(scalar_value) => match scalar_value {
            &ScalarValues::Any => String::from("RescriptRelay.any"),
            &ScalarValues::Boolean => String::from("bool"),
            &ScalarValues::Float => String::from("float"),
            &ScalarValues::String => String::from("string"),
        },
        &PropType::Array((nullable, inner_list_type)) => {
            let mut str = String::from("array<");

            if nullable.to_owned() == true {
                write!(str, "option<").unwrap();
            }

            write!(
                str,
                "{}",
                get_object_prop_value(state, inner_list_type.as_ref(), &context, indentation),
            )
            .unwrap();

            if nullable.to_owned() == true {
                write!(str, ">").unwrap();
            }

            write!(str, ">").unwrap();

            str
        }
        &PropType::FragmentSpreads(fragment_names) => {
            let mut str = String::from("RescriptRelay.fragmentRefs<[");
            fragment_names
                .iter()
                .for_each(|fragment_name| write!(str, " | #{}", fragment_name).unwrap());

            write!(str, "]>").unwrap();
            str
        }
    }
}

fn write_object_maker(
    str: &mut String,
    indentation: usize,
    definition: &Object,
    name: String,
    target_type: String,
) -> Result {
    write_indentation(str, indentation).unwrap();
    write!(str, "let {} = (", name).unwrap();

    let num_props = definition.values.len();

    if num_props == 0 {
        writeln!(str, ") => ()").unwrap();
        return Ok(());
    } else {
        writeln!(str, "").unwrap();
    }

    let mut has_nullable = false;

    definition
        .values
        .iter()
        .enumerate()
        .for_each(|(index, prop_value)| {
            write_indentation(str, indentation + 1).unwrap();
            write!(str, "~{}", prop_value.key).unwrap();

            if prop_value.nullable {
                has_nullable = true;
                write!(str, "=?").unwrap();
            }

            writeln!(
                str,
                "{}",
                // Always trail comma if there's a nullable, since having
                // nullables means we'll need to print unit at the end of the
                // list.
                if index + 1 == num_props && !has_nullable {
                    ""
                } else {
                    ","
                }
            )
            .unwrap();
        });

    // Print unit if there's any nullable present
    if has_nullable {
        write_indentation(str, indentation + 1).unwrap();
        writeln!(str, "()").unwrap();
    }

    write_indentation(str, indentation).unwrap();
    writeln!(str, "): {} => {{", target_type).unwrap();

    // Print the fn body connecting all params
    definition
        .values
        .iter()
        .enumerate()
        .for_each(|(index, prop_value)| {
            write_indentation(str, indentation + 1).unwrap();
            write!(str, "{}: {}", prop_value.key, prop_value.key).unwrap();
            writeln!(str, "{}", if index + 1 == num_props { "" } else { "," }).unwrap();
        });

    write_indentation(str, indentation).unwrap();
    writeln!(str, "}}").unwrap();

    Ok(())
}

fn write_enum_to_string_functions(
    str: &mut String,
    indentation: usize,
    full_enum: &FullEnum,
) -> Result {
    write_indentation(str, indentation).unwrap();
    writeln!(
        str,
        "external {}_toString: enum_{} => string = \"%identity\"",
        uncapitalize_string(&full_enum.name),
        full_enum.name
    )
    .unwrap();
    write_indentation(str, indentation).unwrap();
    writeln!(
        str,
        "external {}_input_toString: enum_{}_input => string = \"%identity\"",
        uncapitalize_string(&full_enum.name),
        full_enum.name
    )
    .unwrap();

    Ok(())
}

fn write_union_definition_body(str: &mut String, indentation: usize, union: &Union) -> Result {
    writeln!(str, "[").unwrap();

    for member in &union.members {
        write_indentation(str, indentation + 1).unwrap();
        writeln!(
            str,
            "| #{}({})",
            member.typename.to_string(),
            member.member_record_name.to_string()
        )
        .unwrap();
    }

    write_indentation(str, indentation + 1).unwrap();
    writeln!(str, "| #UnselectedUnionMember(string)").unwrap();

    write_indentation(str, indentation).unwrap();
    writeln!(str, "]\n").unwrap();

    Ok(())
}

fn write_union_definition(
    str: &mut String,
    indentation: usize,
    union: &Union,
    override_name: Option<String>,
    print_mode: &ObjectPrintMode,
) -> Result {
    let name = match override_name {
        None => union.record_name.to_string(),
        Some(name) => name,
    };

    write_indentation(str, indentation).unwrap();
    write_record_type_start(str, &print_mode, &name).unwrap();
    write_union_definition_body(str, indentation, &union).unwrap();
    Ok(())
}

fn write_instruction_json_object(
    str: &mut String,
    key: &String,
    instructions: &Vec<&InstructionContainer>,
) -> Result {
    write!(str, "\"{}\":{{", key).unwrap();

    // Move all instructions into a hash map by path.
    let mut by_path = HashMap::new();
    instructions.iter().for_each(|instruction_container| {
        let path_name = conversion_instruction_path_to_name(&instruction_container.at_path);
        match by_path.get_mut(&path_name) {
            None => {
                by_path.insert(
                    conversion_instruction_path_to_name(&instruction_container.at_path),
                    vec![instruction_container.instruction.clone()],
                );
                ()
            }
            Some(existing_instructions) => {
                existing_instructions.push(instruction_container.instruction.clone())
            }
        }
    });

    let num_by_path = by_path.len();

    by_path
        .iter()
        .sorted_by(|(path_a, _), (path_b, _)| path_b.cmp(&path_a))
        .enumerate()
        .for_each(|(index, (path_name, instructions))| {
            write!(str, "\"{}\":{{", path_name).unwrap();

            let num_instructions = instructions.len();

            instructions
                .iter()
                .sorted_by(|instr_a, instr_b| {
                    let (key_a, _) = instruction_to_key_value_pair(&instr_a);
                    let (key_b, _) = instruction_to_key_value_pair(&instr_b);

                    key_b.cmp(&key_a)
                })
                .enumerate()
                .for_each(|(index, instruction)| {
                    let (key, value) = instruction_to_key_value_pair(&instruction);

                    write!(str, "\"{}\":\"{}\"", key, value).unwrap();

                    if num_instructions != index + 1 {
                        write!(str, ",").unwrap();
                    }
                });

            // Close this instruction
            write!(str, "}}").unwrap();

            if num_by_path != index + 1 {
                write!(str, ",").unwrap();
            }
        });

    // Close this instruction
    write!(str, "}}").unwrap();

    Ok(())
}

// This produces the conversion instructions JSON object.
fn get_conversion_instructions(
    state: &Box<ReScriptPrinter>,
    conversion_instructions: &Vec<&InstructionContainer>,
    root_object_names: Vec<&String>,
) -> String {
    if conversion_instructions.len() == 0 {
        String::from("{}")
    } else {
        let mut str = String::from("{");

        // Print any root objects
        root_object_names.iter().for_each(|name| {
            write_instruction_json_object(
                &mut str,
                name,
                &state
                    .conversion_instructions
                    .iter()
                    .filter(
                        |instruction_container| match &instruction_container.context {
                            Context::RootObject(root_object_name) => {
                                root_object_name.to_string() == name.to_string()
                            }
                            _ => false,
                        },
                    )
                    .collect_vec(),
            )
            .unwrap();
            write!(str, ",").unwrap();
        });

        // Write the root itself
        write_instruction_json_object(&mut str, &String::from("__root"), conversion_instructions)
            .unwrap();

        // Close full obj
        write!(str, "}}").unwrap();

        str
    }
}

// This writes the converter map, used to convert things like custom scalars and
// unions.
fn write_converter_map(
    str: &mut String,
    indentation: usize,
    instructions: &Vec<&InstructionContainer>,
    name: &String,
    direction: ConversionDirection,
) -> Result {
    write_indentation(str, indentation).unwrap();
    write!(str, "let {}ConverterMap = ", name).unwrap();

    let mut has_instructions = false;
    let mut printed_instruction_keys = vec![];

    instructions.iter().for_each(|instruction_container| {
        match &instruction_container.instruction {
            ConverterInstructions::ConvertUnion(union_name) => {
                if !has_instructions {
                    has_instructions = true;
                    writeln!(str, "{{").unwrap();
                }

                if printed_instruction_keys.contains(union_name) {
                    return;
                } else {
                    printed_instruction_keys.push(union_name.to_string());
                }

                write_indentation(str, indentation + 1).unwrap();
                writeln!(
                    str,
                    "\"{}\": {},",
                    union_name,
                    format!(
                        "{}_{}",
                        match direction {
                            ConversionDirection::Wrap => "wrap",
                            ConversionDirection::Unwrap => "unwrap",
                        },
                        union_name,
                    ),
                )
                .unwrap();
            }
            ConverterInstructions::ConvertCustomField(custom_field_name) => {
                if !has_instructions {
                    has_instructions = true;
                    writeln!(str, "{{").unwrap();
                }

                if printed_instruction_keys.contains(custom_field_name) {
                    return;
                } else {
                    printed_instruction_keys.push(custom_field_name.to_string());
                }

                write_indentation(str, indentation + 1).unwrap();
                writeln!(
                    str,
                    "\"{}\": {},",
                    custom_field_name,
                    match classify_rescript_value_string(&custom_field_name) {
                        RescriptCustomTypeValue::Type => custom_field_name.to_string(),
                        RescriptCustomTypeValue::Module => format!(
                            "{}.{}",
                            custom_field_name,
                            match direction {
                                ConversionDirection::Wrap => "serialize",
                                ConversionDirection::Unwrap => "parse",
                            }
                        ),
                    },
                )
                .unwrap();
            }
            _ => (),
        };
    });

    if has_instructions {
        write_indentation(str, indentation).unwrap();
        writeln!(str, "}}").unwrap();
    } else {
        writeln!(str, "()").unwrap()
    }

    Ok(())
}

// This writes "internal assets", which primarily is converters for going
// between JS and ReScript runtime value representations. It's a total mess
// right now and needs to be refactored, but I'll leave it like this for the
// initial iteration of moving the typegen from OCaml to Rust.
fn write_internal_assets(
    str: &mut String,
    indentation: usize,
    state: &Box<ReScriptPrinter>,
    target_context: Context,
    name: String,
    include_raw: bool,
    direction: ConversionDirection,
    nullable_type: NullableType,
) -> Result {
    let root_name = root_name_from_context(&target_context);

    if include_raw {
        write_indentation(str, indentation).unwrap();
        writeln!(str, "type {}Raw", name).unwrap();
    }

    write_indentation(str, indentation).unwrap();
    writeln!(
        str,
        "let {}Converter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(",
        name
    )
    .unwrap();

    write_indentation(str, indentation + 1).unwrap();

    // All conversion instructions applicable to this context.
    let target_conversion_instructions: Vec<&InstructionContainer> = state
        .conversion_instructions
        .iter()
        .filter(|instr| &instr.at_path[0] == root_name.as_str())
        .collect();

    // Map out all root objects (ie input objects) used in this conversion
    // setup. This is because they are recursive, and thus needs to be treated
    // separately.
    let mut root_objects = FnvHashSet::default();

    target_conversion_instructions
        .iter()
        .for_each(
            |instruction_container| match &instruction_container.instruction {
                ConverterInstructions::RootObject(root_object_name) => {
                    root_objects.insert(root_object_name);
                }
                _ => (),
            },
        );

    writeln!(
        str,
        "json`{}`",
        get_conversion_instructions(
            state,
            &target_conversion_instructions,
            root_objects.into_iter().collect_vec()
        )
    )
    .unwrap();

    write_indentation(str, indentation).unwrap();
    writeln!(str, ")").unwrap();

    // Converters are either unions (that needs to be wrapped/unwrapped), or
    // custom scalars _that are ReScript modules_, and therefore should be
    // autoconverted.
    let converters: Vec<&InstructionContainer> = target_conversion_instructions
        .into_iter()
        .filter(|instruction_container| {
            match &instruction_container.instruction {
                ConverterInstructions::ConvertCustomField(field_name) => {
                    // Try and infer what type of ReScript value this is
                    match classify_rescript_value_string(&field_name) {
                        RescriptCustomTypeValue::Type => false,
                        RescriptCustomTypeValue::Module => true,
                    }
                }
                ConverterInstructions::ConvertUnion(_) => true,
                _ => false,
            }
        })
        .collect();

    write_converter_map(str, indentation, &converters, &name, direction).unwrap();

    write_indentation(str, indentation).unwrap();
    writeln!(
        str,
        "let convert{} = v => v->RescriptRelay.convertObj(",
        uppercase_first_letter(name.as_str())
    )
    .unwrap();

    write_indentation(str, indentation + 1).unwrap();
    writeln!(str, "{}Converter,", name).unwrap();
    write_indentation(str, indentation + 1).unwrap();
    writeln!(str, "{}ConverterMap,", name).unwrap();
    write_indentation(str, indentation + 1).unwrap();
    writeln!(
        str,
        "{}",
        match nullable_type {
            NullableType::Undefined => "Js.undefined",
            NullableType::Null => "Js.null",
        }
    )
    .unwrap();
    write_indentation(str, indentation).unwrap();
    writeln!(str, ")").unwrap();

    Ok(())
}

fn write_union_converters(str: &mut String, indentation: usize, union: &Union) -> Result {
    // Print the unwrap fn first. This is what turns the "raw" value coming from
    // Relay into a ReScript union.
    write_indentation(str, indentation).unwrap();
    writeln!(
        str,
        "let unwrap_{}: {{. \"__typename\": string }} => [",
        union.record_name
    )
    .unwrap();

    for member in &union.members {
        write_indentation(str, indentation + 1).unwrap();
        writeln!(
            str,
            "| #{}(Types.{})",
            member.typename.to_string(),
            member.member_record_name.to_string()
        )
        .unwrap();
    }

    write_indentation(str, indentation + 1).unwrap();
    writeln!(str, "| #UnselectedUnionMember(string)").unwrap();

    write_indentation(str, indentation).unwrap();
    writeln!(str, "] = u => switch u[\"__typename\"] {{").unwrap();

    for member in &union.members {
        write_indentation(str, indentation + 1).unwrap();
        writeln!(
            str,
            "| \"{}\" => #{}(u->Obj.magic)",
            member.typename.to_string(),
            member.typename.to_string(),
        )
        .unwrap();
    }

    write_indentation(str, indentation + 1).unwrap();
    writeln!(str, "| v => #UnselectedUnionMember(v)").unwrap();

    write_indentation(str, indentation).unwrap();
    writeln!(str, "}}\n").unwrap();

    // This prints the wrap function, which turns the ReScript union back into
    // its "raw" format.
    write_indentation(str, indentation).unwrap();
    writeln!(str, "let wrap_{}: [", union.record_name).unwrap();

    for member in &union.members {
        write_indentation(str, indentation + 1).unwrap();
        writeln!(
            str,
            "| #{}(Types.{})",
            member.typename.to_string(),
            member.member_record_name.to_string()
        )
        .unwrap();
    }

    write_indentation(str, indentation + 1).unwrap();
    writeln!(str, "| #UnselectedUnionMember(string)").unwrap();

    write_indentation(str, indentation).unwrap();
    writeln!(str, "] => {{. \"__typename\": string }} = v => switch v {{",).unwrap();

    for member in &union.members {
        write_indentation(str, indentation + 1).unwrap();
        writeln!(str, "| #{}(v) => v->Obj.magic", member.typename.to_string(),).unwrap();
    }

    write_indentation(str, indentation + 1).unwrap();
    writeln!(str, "| #UnselectedUnionMember(v) => {{\"__typename\": v}}").unwrap();

    write_indentation(str, indentation).unwrap();
    writeln!(str, "}}").unwrap();

    Ok(())
}

enum ObjectPrintMode {
    Standalone,
    StartOfRecursiveChain,
    PartOfRecursiveChain,
}

fn write_record_type_start(
    str: &mut String,
    print_mode: &ObjectPrintMode,
    name: &String,
) -> Result {
    match print_mode {
        ObjectPrintMode::Standalone => {
            write!(str, "type {} = ", name).unwrap();
        }
        ObjectPrintMode::StartOfRecursiveChain => {
            write!(str, "type rec {} = ", name).unwrap();
        }
        ObjectPrintMode::PartOfRecursiveChain => {
            write!(str, "and {} = ", name).unwrap();
        }
    };

    Ok(())
}

fn write_object_definition(
    state: &Box<ReScriptPrinter>,
    str: &mut String,
    indentation: usize,
    object: &Object,
    print_mode: ObjectPrintMode,
    override_name: Option<String>,
    context: &Context,
) -> Result {
    write_indentation(str, indentation).unwrap();
    let name = match override_name {
        None => object.record_name.to_string(),
        Some(name) => name,
    };

    write_record_type_start(str, &print_mode, &name).unwrap();

    let num_props = object.values.len();

    // Print this type as "unit" if it's empty
    if num_props == 0 {
        writeln!(str, "unit").unwrap();
        return Ok(());
    } else {
        writeln!(str, "{{").unwrap();
    }

    let in_object_indentation = indentation + 1;

    object.values.iter().for_each(|prop| {
        write_indentation(str, in_object_indentation).unwrap();
        writeln!(
            str,
            "{}{}: {},",
            // If original_key is set, that means that the key here has been
            // transformed (as it was probably an illegal identifier in
            // ReScript). When that happens, we print the @as decorator to deal
            // with the illegal identifier, while not having to rename the
            // underlying key itself.
            match &prop.original_key {
                None => String::from(""),
                Some(original_key) => format!("@as(\"{}\") ", original_key),
            },
            prop.key,
            match prop.nullable {
                true => format!(
                    "option<{}>",
                    get_object_prop_value(state, &prop.prop_type, &context, indentation)
                ),
                false => format!(
                    "{}",
                    get_object_prop_value(state, &prop.prop_type, &context, indentation)
                ),
            }
        )
        .unwrap()
    });

    write_indentation(str, indentation).unwrap();
    writeln!(str, "}}").unwrap();

    Ok(())
}

fn write_fragment_definition(
    state: &Box<ReScriptPrinter>,
    str: &mut String,
    indentation: usize,
    fragment: &TopLevelFragmentType,
    context: &Context,
    nullable: bool,
) -> Result {
    match &fragment {
        &TopLevelFragmentType::Object(obj) => {
            if nullable {
                write_object_definition(
                    state,
                    str,
                    indentation,
                    obj,
                    ObjectPrintMode::Standalone,
                    Some(String::from("fragment_t")),
                    &context,
                )
                .unwrap();

                write_indentation(str, indentation).unwrap();
                writeln!(str, "type fragment = option<fragment_t>").unwrap()
            } else {
                write_object_definition(
                    state,
                    str,
                    indentation,
                    obj,
                    ObjectPrintMode::Standalone,
                    None,
                    &context,
                )
                .unwrap();
            }
        }
        &TopLevelFragmentType::ArrayWithObject(obj) => {
            write_object_definition(
                state,
                str,
                indentation,
                obj,
                ObjectPrintMode::Standalone,
                Some(String::from("fragment_t")),
                &context,
            )
            .unwrap();
            write_indentation(str, indentation).unwrap();
            if nullable {
                writeln!(str, "type fragment = array<option<fragment_t>>").unwrap()
            } else {
                writeln!(str, "type fragment = array<fragment_t>").unwrap()
            }
        }
        &TopLevelFragmentType::Union(union) => {
            if nullable {
                write_union_definition(
                    str,
                    indentation,
                    &union,
                    Some(String::from("fragment_t")),
                    &ObjectPrintMode::Standalone,
                )
                .unwrap();
                write_indentation(str, indentation).unwrap();
                writeln!(str, "type fragment = option<fragment_t>").unwrap()
            } else {
                write_union_definition(
                    str,
                    indentation,
                    &union,
                    None,
                    &ObjectPrintMode::Standalone,
                )
                .unwrap();
            }
        }
        &TopLevelFragmentType::ArrayWithUnion(union) => {
            write_union_definition(
                str,
                indentation,
                union,
                Some(String::from("fragment_t")),
                &ObjectPrintMode::Standalone,
            )
            .unwrap();
            write_indentation(str, indentation).unwrap();
            if nullable {
                writeln!(str, "type fragment = array<option<fragment_t>>").unwrap()
            } else {
                writeln!(str, "type fragment = array<fragment_t>").unwrap()
            }
        }
    }

    Ok(())
}

fn find_object_with_record_name<'a>(
    record_name: &'a String,
    state: &'a Box<ReScriptPrinter>,
) -> Option<&'a Object> {
    state
        .objects
        .iter()
        .find(|object| object.record_name == record_name.to_string())
}

fn find_prop_at_key<'a>(
    object_with_connection: &'a Object,
    key_name: &'a String,
) -> Option<&'a PropValue> {
    object_with_connection.values.iter().find_map(|prop| {
        if prop.key.to_string() == key_name.to_string() {
            Some(prop)
        } else {
            None
        }
    })
}

fn find_prop_obj_at_key<'a>(
    state: &'a Box<ReScriptPrinter>,
    object_with_connection: &'a Object,
    key_name: &'a String,
) -> Option<(bool, &'a Object)> {
    if let Some((nullable, record_name)) =
        object_with_connection
            .values
            .iter()
            .find_map(|prop| match prop.prop_type.as_ref() {
                PropType::RecordReference(connection_prop_record_name) => {
                    if prop.key.to_string() == key_name.to_string() {
                        Some((prop.nullable, connection_prop_record_name))
                    } else {
                        None
                    }
                }
                _ => None,
            })
    {
        match find_object_with_record_name(&record_name, state) {
            None => None,
            Some(obj) => Some((nullable, obj)),
        }
    } else {
        None
    }
}

fn find_edges<'a>(object_with_edges: &'a Object) -> Option<(bool, bool, String)> {
    object_with_edges
        .values
        .iter()
        .find_map(|prop| match &prop.prop_type.as_ref() {
            PropType::Array((edges_nullable, edges_prop)) => {
                if prop.key.to_string().as_str() == "edges" {
                    match &edges_prop.as_ref() {
                        PropType::RecordReference(edges_record_name) => Some((
                            prop.nullable,
                            edges_nullable.to_owned(),
                            edges_record_name.to_string(),
                        )),
                        _ => None,
                    }
                } else {
                    None
                }
            }
            _ => None,
        })
}

// This writes the "getConnectionNodes" function.
fn write_get_connection_nodes_function(
    str: &mut String,
    indentation: usize,
    state: &Box<ReScriptPrinter>,
    connection_field_name: &String,
    object_with_connection: &Object,
) -> Result {
    // Find the connection prop in this container object.
    if let Some((connection_nullable, connection_obj)) =
        find_prop_obj_at_key(state, &object_with_connection, &connection_field_name)
    {
        // Find the edges
        if let Some((edges_prop_nullable, edges_nullable, edges_obj_type_name)) =
            find_edges(&connection_obj)
        {
            match find_object_with_record_name(&edges_obj_type_name, state) {
                None => {
                    warn!("Could not find edges object.")
                }
                Some(edges_object) => {
                    // Find the node
                    match find_prop_at_key(&edges_object, &String::from("node")) {
                        None => warn!("Could not find node"),
                        Some(prop_value) => {
                            let (node_nullable, node_type_name) =
                                match &prop_value.prop_type.as_ref() {
                                    PropType::RecordReference(node_record_reference) => {
                                        (prop_value.nullable, node_record_reference.to_string())
                                    }
                                    PropType::UnionReference(node_union_reference) => {
                                        (prop_value.nullable, node_union_reference.to_string())
                                    }
                                    _ => {
                                        warn!("Unexpected node type");
                                        (prop_value.nullable, String::from("invalid_node_type"))
                                    }
                                };

                            // We've got all we need, let's print the function itself
                            let mut local_indentation = indentation;
                            write_indentation(str, local_indentation).unwrap();
                            write!(str, "let getConnectionNodes: ").unwrap();

                            if connection_nullable {
                                write!(str, "option<").unwrap()
                            }

                            write!(str, "{}", connection_obj.record_name.to_string()).unwrap();

                            if connection_nullable {
                                write!(str, ">").unwrap();
                            }

                            write!(str, " => array<{}> = ", node_type_name).unwrap();

                            writeln!(str, "connection => ").unwrap();

                            let mut ending_str = String::new();

                            if connection_nullable {
                                local_indentation += 1;
                                write_indentation(str, local_indentation).unwrap();
                                writeln!(str, "switch connection {{").unwrap();

                                write_indentation(&mut ending_str, local_indentation).unwrap();
                                writeln!(ending_str, "}}").unwrap();

                                local_indentation += 1;

                                write_indentation(str, local_indentation).unwrap();
                                writeln!(str, "| None => []").unwrap();
                                write_indentation(str, local_indentation).unwrap();
                                writeln!(str, "| Some(connection) => ").unwrap();
                            }

                            if edges_prop_nullable {
                                local_indentation += 1;
                                write_indentation(str, local_indentation).unwrap();
                                writeln!(str, "switch connection.edges {{").unwrap();

                                write_indentation(&mut ending_str, local_indentation).unwrap();
                                writeln!(ending_str, "}}").unwrap();

                                local_indentation += 1;

                                write_indentation(str, local_indentation).unwrap();
                                writeln!(str, "| None => []").unwrap();
                                write_indentation(str, local_indentation).unwrap();
                                writeln!(str, "| Some(edges) => edges").unwrap();
                            } else {
                                write_indentation(str, local_indentation).unwrap();
                                writeln!(str, "connection.edges").unwrap();
                            }

                            local_indentation += 1;
                            if edges_nullable {
                                write_indentation(str, local_indentation).unwrap();
                                writeln!(str, "->Belt.Array.keepMap(edge => switch edge {{")
                                    .unwrap();

                                write_indentation(&mut ending_str, local_indentation).unwrap();
                                writeln!(ending_str, "}})").unwrap();

                                local_indentation += 1;

                                write_indentation(str, local_indentation).unwrap();
                                writeln!(str, "| None => None").unwrap();
                                write_indentation(str, local_indentation).unwrap();
                                write!(str, "| Some(edge) => ").unwrap();
                            } else {
                                write_indentation(str, local_indentation).unwrap();
                                writeln!(str, "->Belt.Array.keepMap(edge => ").unwrap();

                                write_indentation(&mut ending_str, local_indentation).unwrap();
                                writeln!(ending_str, ")").unwrap();
                            }

                            if node_nullable {
                                write!(str, "edge.node").unwrap();
                            } else {
                                write!(str, "Some(edge.node)").unwrap();
                            }

                            // Write the end string to the result when we're done
                            write!(
                                str,
                                "{}\n\n",
                                ending_str.as_str().split('\n').rev().join("\n")
                            )
                            .unwrap();
                        }
                    }
                }
            }
        }
    }

    Ok(())
}

fn warn_about_unimplemented_feature(definition_type: &DefinitionType, context: String) {
    warn!("'{}' (context: '{}') produced a type that RescriptRelay does not understand. Please open an issue on the repo https://github.com/zth/rescript-relay and describe what you were doing as this happened.", match &definition_type {
        DefinitionType::Fragment(fragment_definition) => fragment_definition.name.item,
        DefinitionType::Operation(operation_definition) => operation_definition.name.item
    }, context);
}

impl Writer for ReScriptPrinter {
    // This is what does the actual printing of types. It does that by working
    // its way through the state produced by "write_export_type", which turns
    // the AST the Relay compiler feeds us into a state we can use to generate
    // the ReScript types we need.
    fn into_string(self: Box<Self>) -> String {
        let mut generated_types = String::new();
        let mut indentation: usize = 0;

        // Print the Types module. This will contain most of the type
        // defintions.
        writeln!(generated_types, "module Types = {{").unwrap();

        indentation += 1;
        write_indentation(&mut generated_types, indentation).unwrap();

        writeln!(generated_types, "@@ocaml.warning(\"-30\")\n").unwrap();

        // Print enums
        self.enums
            .iter()
            .unique_by(|full_enum| &full_enum.name)
            .for_each(|full_enum| {
                write_enum_definitions(&mut generated_types, indentation, &full_enum).unwrap()
            });

        // Print input objects. These are standalone (but recursive since they
        // can refer to themselves), and needs to be printed first as the rest
        // of the types might use them.
        self.input_objects
            .iter()
            .unique_by(|input_object| &input_object.record_name)
            .enumerate()
            .for_each(|(index, input_object)| {
                write_object_definition(
                    &self,
                    &mut generated_types,
                    indentation,
                    &input_object,
                    match index {
                        0 => ObjectPrintMode::StartOfRecursiveChain,
                        _ => ObjectPrintMode::PartOfRecursiveChain,
                    },
                    None,
                    &Context::RootObject(input_object.record_name.to_string()),
                )
                .unwrap()
            });

        // Print object types that originate from unions. This is because these
        // definitions need to come before the actual union definitions, which
        // use them.
        let objects_from_unions: Vec<&Object> = self
            .objects
            .iter()
            .unique_by(|object| &object.record_name)
            .filter(|object| object.found_in_union)
            .collect();

        objects_from_unions
            .iter()
            .enumerate()
            .for_each(|(index, object)| {
                write_object_definition(
                    &self,
                    &mut generated_types,
                    indentation,
                    &object,
                    match index {
                        0 => ObjectPrintMode::StartOfRecursiveChain,
                        _ => ObjectPrintMode::PartOfRecursiveChain,
                    },
                    None,
                    &Context::NotRelevant,
                )
                .unwrap()
            });

        // Print union definitions.
        self.unions
            .iter()
            .unique_by(|union| &union.record_name)
            .for_each(|union| {
                write_union_definition(
                    &mut generated_types,
                    indentation,
                    &union,
                    None,
                    if objects_from_unions.len() > 0 {
                        &ObjectPrintMode::PartOfRecursiveChain
                    } else {
                        &ObjectPrintMode::Standalone
                    },
                )
                .unwrap()
            });

        // Print object types that do not originate from unions.
        self.objects
            .iter()
            .unique_by(|object| &object.record_name)
            .filter(|object| !object.found_in_union)
            .enumerate()
            .for_each(|(index, object)| {
                write_object_definition(
                    &self,
                    &mut generated_types,
                    indentation,
                    &object,
                    match index {
                        0 => ObjectPrintMode::StartOfRecursiveChain,
                        _ => ObjectPrintMode::PartOfRecursiveChain,
                    },
                    None,
                    &Context::NotRelevant,
                )
                .unwrap()
            });

        // Print the fragment definition
        if let Some((nullable, fragment)) = &self.fragment {
            write_fragment_definition(
                &self,
                &mut generated_types,
                indentation,
                &fragment,
                &Context::Fragment,
                nullable.to_owned(),
            )
            .unwrap()
        }

        // Print the response and raw response (if wanted)
        if let Some((nullable, response)) = &self.response {
            if *nullable {
                write_object_definition(
                    &self,
                    &mut generated_types,
                    indentation,
                    &response,
                    ObjectPrintMode::Standalone,
                    Some(String::from("response_t")),
                    &Context::Response,
                )
                .unwrap();
                write_indentation(&mut generated_types, indentation).unwrap();
                writeln!(generated_types, "type response = option<response_t>").unwrap()
            } else {
                write_object_definition(
                    &self,
                    &mut generated_types,
                    indentation,
                    &response,
                    ObjectPrintMode::Standalone,
                    None,
                    &Context::Response,
                )
                .unwrap();
            }

            // This prints the rawResponse, which the Relay compiler outputs if
            // you annotate a query with @raw_response_type. The rawResponse is
            // essentially a type corresponding to exactly what Relay expects
            // the server to return. This makes it suitable for things like
            // optimistic responses etc.
            //
            // Because of how the typings work, we'll bind `rawResponse` to the
            // actual `response` if it's not requested. Doing this means the
            // rest of the RescriptRelay code can always refer to rawResponse
            // for certain things, even if the rawResponse has been produced or
            // not. This is necessary since the general RescriptRelay code won't
            // know whether the rawResponse type is there or not, since it's
            // conditional and not always there.
            match &self.raw_response {
                Some(raw_response) => write_object_definition(
                    &self,
                    &mut generated_types,
                    indentation,
                    &raw_response,
                    ObjectPrintMode::Standalone,
                    None,
                    &Context::RawResponse,
                )
                .unwrap(),
                None => {
                    write_indentation(&mut generated_types, indentation).unwrap();
                    writeln!(
                        generated_types,
                        "type rawResponse = {}",
                        // We point to the full, non nullable type if response
                        // was nullable, as it might be nullable only because of
                        // @required, and we don't care about that when using
                        // the raw response.
                        if *nullable { "response_t" } else { "response" }
                    )
                    .unwrap()
                }
            }
        }

        // Print the variables
        if let Some(variables) = &self.variables {
            write_object_definition(
                &self,
                &mut generated_types,
                indentation,
                &variables,
                ObjectPrintMode::Standalone,
                None,
                &Context::Variables,
            )
            .unwrap();

            // And, if we're in a query, print the refetch variables assets as
            // well.
            match &self.typegen_definition {
                &DefinitionType::Operation(OperationDefinition {
                    kind: OperationKind::Query,
                    ..
                }) => {
                    // Refetch variables are the regular variables, but with all
                    // top level fields forced to be optional. Note: This is not
                    // 100% and we'll need to revisit this at a later point in
                    // order to support sending actual "null" values here.
                    let variables_as_refetch_variables = Object {
                        comment: None,
                        at_path: vec![String::from("variables")],
                        found_in_union: false,
                        record_name: String::from("refetchVariables"),
                        values: variables
                            .values
                            .iter()
                            .map(|prop_value| PropValue {
                                nullable: true,
                                comment: prop_value.comment.clone(),
                                key: prop_value.key.clone(),
                                original_key: prop_value.original_key.clone(),
                                prop_type: prop_value.prop_type.clone(),
                            })
                            .collect(),
                    };

                    write_object_definition(
                        &self,
                        &mut generated_types,
                        indentation,
                        &variables_as_refetch_variables,
                        ObjectPrintMode::Standalone,
                        Some(String::from("refetchVariables")),
                        &Context::Variables,
                    )
                    .unwrap();

                    write_object_maker(
                        &mut generated_types,
                        indentation,
                        &variables_as_refetch_variables,
                        String::from("makeRefetchVariables"),
                        String::from("refetchVariables"),
                    )
                    .unwrap()
                }
                _ => (),
            }
        }

        indentation -= 1;
        write_indentation(&mut generated_types, indentation).unwrap();
        writeln!(generated_types, "}}\n").unwrap();

        // Print union converters for the fragment itself, if the fragment is on a union.
        match &self.fragment {
            Some((
                _,
                TopLevelFragmentType::Union(fragment_union)
                | TopLevelFragmentType::ArrayWithUnion(fragment_union),
            )) => {
                write_union_converters(&mut generated_types, indentation, &fragment_union).unwrap();
            }
            Some((
                _,
                TopLevelFragmentType::Object(_) | TopLevelFragmentType::ArrayWithObject(_),
            ))
            | None => (),
        }

        // Print union converters
        self.unions
            .iter()
            .unique_by(|union| &union.record_name)
            .for_each(|union| {
                write_union_converters(&mut generated_types, indentation, &union).unwrap()
            });

        // Print internal module. This module holds a bunch of things needed for
        // conversions etc, but that we want to keep in its own module. Mostly
        // just to reiterate that things found in here are indeed internal, and
        // shouldn't be used on their own.
        write_indentation(&mut generated_types, indentation).unwrap();
        writeln!(generated_types, "module Internal = {{").unwrap();
        indentation += 1;

        match &self.fragment {
            Some(_) => {
                write_internal_assets(
                    &mut generated_types,
                    indentation,
                    &self,
                    Context::Fragment,
                    String::from("fragment"),
                    true,
                    ConversionDirection::Unwrap,
                    NullableType::Undefined,
                )
                .unwrap();
            }
            None => (),
        };

        match &self.variables {
            Some(_) => {
                write_internal_assets(
                    &mut generated_types,
                    indentation,
                    &self,
                    Context::Variables,
                    String::from("variables"),
                    false,
                    ConversionDirection::Wrap,
                    NullableType::Undefined,
                )
                .unwrap();
            }
            None => (),
        };

        // The rest of the internal assets is a bit of a mess. Will fix
        // eventually. But, essentially, this part is about printing assets for
        // converting back and forth between response/rawResponse etc. We
        // convert _to_ ReScript values whenever we want to use the values in
        // ReScript (like when rendering React), and _from_ ReScript to regular
        // JS when we for example pass variables as we load queries, produce
        // optimistic responses, or similar. In short, any time a value goes
        // back into Relay from ReScript.
        match (&self.response, &self.typegen_definition) {
            (Some(_), DefinitionType::Operation(op)) => {
                match &op.kind {
                    OperationKind::Query | OperationKind::Mutation => {
                        write_internal_assets(
                            &mut generated_types,
                            indentation,
                            &self,
                            Context::Response,
                            String::from("wrapResponse"),
                            true,
                            ConversionDirection::Wrap,
                            NullableType::Null,
                        )
                        .unwrap();
                    }
                    OperationKind::Subscription => (),
                }

                write_internal_assets(
                    &mut generated_types,
                    indentation,
                    &self,
                    Context::Response,
                    String::from("response"),
                    true,
                    ConversionDirection::Unwrap,
                    NullableType::Undefined,
                )
                .unwrap();
            }
            _ => (),
        };

        match (&self.response, &self.raw_response, &self.typegen_definition) {
            (Some(_), Some(_), DefinitionType::Operation(op)) => {
                match &op.kind {
                    OperationKind::Query | OperationKind::Mutation => {
                        write_internal_assets(
                            &mut generated_types,
                            indentation,
                            &self,
                            Context::RawResponse,
                            String::from("wrapRawResponse"),
                            true,
                            ConversionDirection::Wrap,
                            NullableType::Null,
                        )
                        .unwrap();
                    }
                    OperationKind::Subscription => (),
                }

                write_internal_assets(
                    &mut generated_types,
                    indentation,
                    &self,
                    Context::RawResponse,
                    String::from("rawResponse"),
                    true,
                    ConversionDirection::Unwrap,
                    NullableType::Undefined,
                )
                .unwrap();
            }
            (Some(_), None, DefinitionType::Operation(op)) => {
                match &op.kind {
                    OperationKind::Query | OperationKind::Mutation => {
                        write_indentation(&mut generated_types, indentation).unwrap();
                        writeln!(generated_types, "type wrapRawResponseRaw = wrapResponseRaw")
                            .unwrap();
                        write_indentation(&mut generated_types, indentation).unwrap();
                        writeln!(
                            generated_types,
                            "let convertWrapRawResponse = convertWrapResponse"
                        )
                        .unwrap();
                    }
                    OperationKind::Subscription => (),
                }

                write_indentation(&mut generated_types, indentation).unwrap();
                writeln!(generated_types, "type rawResponseRaw = responseRaw").unwrap();
                write_indentation(&mut generated_types, indentation).unwrap();
                writeln!(generated_types, "let convertRawResponse = convertResponse").unwrap();
            }
            _ => (),
        };

        indentation -= 1;
        write_indentation(&mut generated_types, indentation).unwrap();
        writeln!(generated_types, "}}").unwrap();

        // This prints assets for helping to unwrap Relay fragments in a type
        // safe way via ReScript.
        match &self.typegen_definition {
            DefinitionType::Fragment(fragment_definition) => {
                let plural = is_plural(fragment_definition);

                write_indentation(&mut generated_types, indentation).unwrap();
                writeln!(
                    generated_types,
                    "\ntype t\ntype fragmentRef\nexternal getFragmentRef:"
                )
                .unwrap();
                write_indentation(&mut generated_types, indentation + 1).unwrap();
                writeln!(
                    generated_types,
                    "{}RescriptRelay.fragmentRefs<[> | #{}]>{} => fragmentRef = \"%identity\"\n",
                    if plural { "array<" } else { "" },
                    fragment_definition.name.item,
                    if plural { ">" } else { "" }
                )
                .unwrap();
            }
            DefinitionType::Operation(operation_definition) => match operation_definition.kind {
                OperationKind::Query => {
                    write_indentation(&mut generated_types, indentation).unwrap();
                    writeln!(generated_types, "").unwrap();
                    write_indentation(&mut generated_types, indentation).unwrap();
                    writeln!(generated_types, "type queryRef").unwrap();
                    write_indentation(&mut generated_types, indentation).unwrap();
                    writeln!(generated_types, "").unwrap();
                }
                OperationKind::Mutation | OperationKind::Subscription => (),
            },
        }

        // Print utils module. This holds any utils needed (that the developer
        // might also want to access, so not internal here).
        write_indentation(&mut generated_types, indentation).unwrap();
        writeln!(generated_types, "module Utils = {{").unwrap();

        indentation += 1;
        write_indentation(&mut generated_types, indentation).unwrap();
        writeln!(generated_types, "@@ocaml.warning(\"-33\")").unwrap();
        write_indentation(&mut generated_types, indentation).unwrap();
        writeln!(generated_types, "open Types").unwrap();

        self.enums
            .iter()
            .unique_by(|full_enum| &full_enum.name)
            .for_each(|full_enum| {
                write_enum_to_string_functions(&mut generated_types, indentation, &full_enum)
                    .unwrap()
            });

        // Let's write some connection helpers! These are emitted anytime
        // there's an @connection directive present in a fragment. They're all
        // about simplifying using connections.
        match &self.operation_meta_data.connection_config {
            None => (),
            Some(connection_config) => {
                // First, lets print the connection key as string
                write_indentation(&mut generated_types, indentation).unwrap();
                writeln!(generated_types, "@inline").unwrap();
                write_indentation(&mut generated_types, indentation).unwrap();
                writeln!(
                    generated_types,
                    "let connectionKey = \"{}\"\n\n",
                    connection_config.key
                )
                .unwrap();

                // Now, print the getConnectionNodes helper. This can target a
                // connection that's either in a nested object somewhere, or
                // directly on the fragment.
                match (&self.fragment, connection_config.at_object_path.len()) {
                    (Some((_, TopLevelFragmentType::Object(fragment))), 1) => {
                        // Only one element means it's on the fragment, since
                        // @connection only appears on fragments, and the prefix
                        // "fragment" will be here in the path.
                        write_get_connection_nodes_function(
                            &mut generated_types,
                            indentation,
                            &self,
                            &connection_config.field_name,
                            &fragment,
                        )
                        .unwrap()
                    }
                    (Some((_, TopLevelFragmentType::Object(_))), _) => {
                        // More elements means this is an object somewhere else
                        // in the response. So, we'll need to find it.
                        match find_object_with_record_name(
                            &path_to_name(&connection_config.at_object_path),
                            &self,
                        ) {
                            None => (),
                            Some(obj) => write_get_connection_nodes_function(
                                &mut generated_types,
                                indentation,
                                &self,
                                &connection_config.field_name,
                                &obj,
                            )
                            .unwrap(),
                        }
                    }
                    _ => (),
                }
            }
        }

        // This prints a bunch of object maker helpers for input objects, and
        // variables. In a future, these should probably not be emitted by
        // default, but rather behind a dedicated RescriptRelay directive or
        // similar.
        self.input_objects.iter().for_each(|input_object| {
            write_object_maker(
                &mut generated_types,
                indentation,
                input_object,
                format!("make_{}", input_object.record_name),
                input_object.record_name.to_string(),
            )
            .unwrap();
        });

        match &self.variables {
            None => (),
            Some(variables_definition) => {
                write_object_maker(
                    &mut generated_types,
                    indentation,
                    variables_definition,
                    String::from("makeVariables"),
                    String::from("variables"),
                )
                .unwrap();
            }
        }

        // Print a maker for optimistic responses
        match (&self.typegen_definition, &self.raw_response) {
            (DefinitionType::Operation(def), Some(raw_response)) => {
                if def.kind == OperationKind::Mutation {
                    write_object_maker(
                        &mut generated_types,
                        indentation,
                        raw_response,
                        String::from("makeOptimisticResponse"),
                        String::from("rawResponse"),
                    )
                    .unwrap();

                    // Also print object makers for each object from the raw response
                    self.objects
                        .iter()
                        .filter(|obj| obj.at_path[0].as_str() == "rawResponse")
                        .for_each(|obj| {
                            write_object_maker(
                                &mut generated_types,
                                indentation,
                                obj,
                                format!("make_{}", obj.record_name),
                                obj.record_name.to_string(),
                            )
                            .unwrap();
                        });
                }
            }
            _ => (),
        }

        indentation -= 1;
        write_indentation(&mut generated_types, indentation).unwrap();
        writeln!(generated_types, "}}").unwrap();

        generated_types
    }

    // This here is fed anything that the Relay compiler wants to "export"
    // typewise from the current artifact. We take the AST fed here, make out
    // what it represents, and then construct our own state for this artifact,
    // that holds everything we need to print ReScript types.
    fn write_export_type(&mut self, name: &str, value: &AST) -> Result {
        // The Relay compiler emits all actual data types (the response for
        // operations, the raw response if requested, the fragment data for
        // fragments, and variables) as <Identifier>$<type>. So, here we look
        // for those key top level objects and treat them specially.
        if name.ends_with("$data") {
            match classify_top_level_object_type_ast(&value) {
                Some((nullable, ClassifiedTopLevelObjectType::Object(props))) => {
                    let context = match &self.typegen_definition {
                        DefinitionType::Fragment(_) => Context::Fragment,
                        _ => Context::Response,
                    };

                    let current_path = vec![root_name_from_context(&context)];

                    let record_name = path_to_name(&current_path);
                    let main_data_type = Object {
                        at_path: current_path.clone(),
                        comment: None,
                        record_name: record_name.to_string(),
                        values: get_object_props(self, &current_path, &props, false, &context),
                        found_in_union: false,
                    };

                    if nullable {
                        self.conversion_instructions.push(InstructionContainer {
                            context: context.clone(),
                            at_path: current_path.clone(),
                            instruction: ConverterInstructions::ConvertNullableProp,
                        });
                    }

                    match &self.typegen_definition {
                        DefinitionType::Fragment(_) => {
                            self.fragment =
                                Some((nullable, TopLevelFragmentType::Object(main_data_type)));
                        }
                        _ => {
                            self.response = Some((nullable, main_data_type));
                        }
                    };

                    Ok(())
                }
                Some((nullable, ClassifiedTopLevelObjectType::ArrayWithObject(props))) => {
                    let context = match &self.typegen_definition {
                        DefinitionType::Fragment(_) => Context::Fragment,
                        _ => Context::Response,
                    };
                    let current_path = vec![root_name_from_context(&context)];

                    let record_name = path_to_name(&current_path);
                    let fragment_type = Object {
                        at_path: current_path.clone(),
                        comment: None,
                        record_name: record_name.to_string(),
                        values: get_object_props(self, &current_path, &props, false, &context),
                        found_in_union: false,
                    };

                    if nullable {
                        self.conversion_instructions.push(InstructionContainer {
                            context: context.clone(),
                            at_path: current_path.clone(),
                            instruction: ConverterInstructions::ConvertNullableArrayContents,
                        });
                    }

                    self.fragment = Some((
                        nullable,
                        TopLevelFragmentType::ArrayWithObject(fragment_type),
                    ));
                    Ok(())
                }
                Some((nullable, ClassifiedTopLevelObjectType::Union(members_raw))) => {
                    let context = Context::Fragment;

                    let current_path = vec![root_name_from_context(&context)];
                    let record_name = path_to_name(&current_path);
                    let union_members =
                        extract_union_members(self, &current_path, members_raw, &context);
                    let fragment_union_type = Union {
                        at_path: current_path.clone(),
                        comment: None,
                        record_name: record_name.to_string(),
                        members: union_members,
                    };

                    if nullable {
                        self.conversion_instructions.push(InstructionContainer {
                            context: context.clone(),
                            at_path: current_path.clone(),
                            instruction: ConverterInstructions::ConvertNullableProp,
                        });
                    }

                    self.conversion_instructions.push(InstructionContainer {
                        context: context.clone(),
                        at_path: current_path.clone(),
                        instruction: ConverterInstructions::ConvertUnion(String::from("fragment")),
                    });

                    self.fragment =
                        Some((nullable, TopLevelFragmentType::Union(fragment_union_type)));
                    Ok(())
                }
                Some((nullable, ClassifiedTopLevelObjectType::ArrayWithUnion(members_raw))) => {
                    let context = Context::Fragment;

                    let current_path = vec![root_name_from_context(&context)];
                    let record_name = path_to_name(&current_path);
                    let union_members =
                        extract_union_members(self, &current_path, members_raw, &context);
                    let fragment_union_type = Union {
                        at_path: current_path.clone(),
                        comment: None,
                        record_name: record_name.to_string(),
                        members: union_members,
                    };

                    self.conversion_instructions.push(InstructionContainer {
                        context: context.clone(),
                        at_path: current_path.clone(),
                        instruction: ConverterInstructions::ConvertUnion(String::from("fragment")),
                    });

                    if nullable {
                        self.conversion_instructions.push(InstructionContainer {
                            context: context.clone(),
                            at_path: current_path.clone(),
                            instruction: ConverterInstructions::ConvertNullableArrayContents,
                        });
                    }

                    self.fragment = Some((
                        nullable,
                        TopLevelFragmentType::ArrayWithUnion(fragment_union_type),
                    ));
                    Ok(())
                }
                None => {
                    warn_about_unimplemented_feature(
                        &self.typegen_definition,
                        String::from("unknown top level data"),
                    );
                    Ok(())
                }
            }
        } else if name.ends_with("$variables") {
            match classify_top_level_object_type_ast(&value) {
                Some((_nullable, ClassifiedTopLevelObjectType::Object(props))) => {
                    let context = Context::Variables;
                    let current_path = vec![root_name_from_context(&context)];

                    let obj = Object {
                        at_path: current_path.clone(),
                        comment: None,
                        record_name: path_to_name(&current_path),
                        values: get_object_props(self, &current_path, &props, false, &context),
                        found_in_union: false,
                    };

                    self.variables = Some(obj);
                    Ok(())
                }
                _ => {
                    warn_about_unimplemented_feature(
                        &self.typegen_definition,
                        String::from("variables"),
                    );
                    Ok(())
                }
            }
        } else if name.ends_with("$rawResponse") {
            match classify_top_level_object_type_ast(&value) {
                Some((_nullable, ClassifiedTopLevelObjectType::Object(props))) => {
                    let context = Context::RawResponse;
                    let current_path = vec![root_name_from_context(&context)];

                    let obj = Object {
                        at_path: current_path.clone(),
                        comment: None,
                        record_name: path_to_name(&current_path),
                        values: get_object_props(self, &current_path, &props, false, &context),
                        found_in_union: false,
                    };

                    self.raw_response = Some(obj);
                    Ok(())
                }
                _ => {
                    warn_about_unimplemented_feature(
                        &self.typegen_definition,
                        String::from("rawResponse"),
                    );
                    Ok(())
                }
            }
        } else {
            // If the thing we're fed is neither of the above, it's either an
            // input object, or an enum. We'll map that out accordingly below.
            match &value {
                AST::ExactObject(props) => {
                    let root_object_name = uncapitalize_string(&name.to_string());
                    let context = Context::RootObject(root_object_name.clone());

                    let path = vec![root_name_from_context(&context)];
                    let obj = Object {
                        comment: None,
                        values: get_object_props(self, &path, &props, false, &context),
                        at_path: path.clone(),
                        record_name: path_to_name(&path),
                        found_in_union: false,
                    };
                    self.input_objects.push(obj);
                }
                AST::Union(members) => {
                    let enum_values = members
                        .iter()
                        .filter_map(|value| match value {
                            AST::StringLiteral(enum_value) => {
                                // The Relay compiler adds `%future added value`
                                // members to enums, as a way of telling you
                                // that "this might change in the future, so
                                // account for that". We handle that via the
                                // type system in ReScript instead, so no need
                                // to keep that member here.
                                if enum_value.to_string().as_str() != "%future added value" {
                                    Some(enum_value.to_string())
                                } else {
                                    None
                                }
                            }
                            _ => None,
                        })
                        .collect();

                    let full_enum = FullEnum {
                        name: name.to_string(),
                        values: enum_values,
                    };

                    self.enums.push(full_enum);
                }
                _ => (),
            };
            Ok(())
        }
    }

    fn write_import_module_default(&mut self, _name: &str, _from: &str) -> Result {
        Ok(())
    }

    fn write_import_type(&mut self, _types: &[&str], _from: &str) -> Result {
        Ok(())
    }

    fn write_import_fragment_type(&mut self, _types: &[&str], _from: &str) -> Result {
        Ok(())
    }

    fn write_export_fragment_type(&mut self, _old_name: &str, _new_name: &str) -> Result {
        Ok(())
    }

    fn write_export_fragment_types(
        &mut self,
        _fragment_type_name_1: &str,
        _fragment_type_name_2: &str,
    ) -> Result {
        Ok(())
    }

    fn write_any_type_definition(&mut self, _name: &str) -> Result {
        Ok(())
    }

    fn write(&mut self, _ast: &AST) -> Result {
        Ok(())
    }

    fn get_runtime_fragment_import(&self) -> &'static str {
        ""
    }

    fn write_local_type(&mut self, _name: &str, _ast: &AST) -> Result {
        // TODO: Figure out if we need this.
        warn_about_unimplemented_feature(&self.typegen_definition, String::from("local type"));
        Ok(())
    }
}

impl ReScriptPrinter {
    pub fn new(
        operation_meta_data: RescriptRelayOperationMetaData,
        typegen_definition: DefinitionType,
    ) -> Self {
        Self {
            enums: vec![],
            objects: vec![],
            input_objects: vec![],
            unions: vec![],
            fragment: None,
            raw_response: None,
            response: None,
            variables: None,
            typegen_definition,
            conversion_instructions: vec![],
            operation_meta_data,
        }
    }
}
