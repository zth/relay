use std::fmt::Result;
use std::fmt::Write;
use std::ops::Add;

use common::ScalarName;
use common::WithLocation;
use docblock_shared::RELAY_RESOLVER_WEAK_OBJECT_DIRECTIVE;
use graphql_ir::Argument;
use graphql_ir::ConstantValue;
use graphql_ir::FragmentDefinition;
use graphql_ir::OperationDefinition;
use graphql_ir::ProvidedVariableMetadata;
use graphql_ir::Value;
use graphql_ir::Variable;
use graphql_ir::VariableDefinition;
use graphql_ir::reexport::Intern;
use graphql_ir::reexport::StringKey;
use itertools::Itertools;
use log::warn;
use relay_config::CustomType;
use relay_config::CustomTypeImport;
use relay_config::TypegenConfig;
use relay_transforms::RelayDirective;
use schema::SDLSchema;
use schema::Schema;
use schema::Type;
use schema::TypeReference;

use crate::rescript::DefinitionType;
use crate::rescript::NullabilityMode;
use crate::rescript::ReScriptPrinter;
use crate::rescript_ast::AstToStringNeedsConversion;
use crate::rescript_ast::Context;
use crate::rescript_ast::ConverterInstructions;
use crate::rescript_ast::FragmentReference;
use crate::rescript_ast::FullEnum;
use crate::rescript_ast::ProvidedVariable;
use crate::rescript_relay_visitor::CustomScalarsMap;
use crate::rescript_relay_visitor::RescriptRelayOperationMetaData;
use crate::rescript_relay_visitor::find_assets_in_fragment;
use crate::rescript_relay_visitor::find_assets_in_operation;
use crate::writer::AST;
use crate::writer::Prop;
use crate::writer::StringLiteral;

pub fn uncapitalize_string(str: &String) -> String {
    str[..1].to_ascii_lowercase().add(&str[1..])
}

pub fn capitalize_string(str: &String) -> String {
    str[..1].to_ascii_uppercase().add(&str[1..])
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

pub fn extract_fragments_from_fragment_spread(ast: &AST) -> Vec<FragmentReference> {
    match &ast {
        AST::FragmentReference(fragment_names) => fragment_names
            .iter()
            .map(|name| {
                let (is_aliased, fragment_name) = if name.to_string().starts_with("$ALIAS$") {
                    (true, name.to_string()[7..].to_string())
                } else {
                    (false, name.to_string())
                };

                FragmentReference {
                    fragment_name,
                    is_aliased,
                }
            })
            .collect(),
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
pub fn classify_top_level_object_type_ast(
    ast: &AST,
) -> Option<(bool, ClassifiedTopLevelObjectType<'_>)> {
    let (nullable, unwrapped_ast) = unwrap_ast(ast);

    match &unwrapped_ast {
        &AST::ExactObject(props) => Some((nullable, ClassifiedTopLevelObjectType::Object(&props))),
        &AST::Union(members) => {
            if members.len() == 1 {
                match members.get(0) {
                    Some(AST::ExactObject(props)) => {
                        Some((nullable, ClassifiedTopLevelObjectType::Object(props)))
                    }
                    _ => None,
                }
            } else {
                Some((nullable, ClassifiedTopLevelObjectType::Union(members)))
            }
        }
        &AST::ReadOnlyArray(inner_ast) => {
            match classify_top_level_object_type_ast(inner_ast.as_ref()) {
                Some((array_item_nullable, ClassifiedTopLevelObjectType::Object(props))) => Some((
                    array_item_nullable,
                    ClassifiedTopLevelObjectType::ArrayWithObject(&props),
                )),
                Some((array_item_nullable, ClassifiedTopLevelObjectType::Union(ast))) => Some((
                    array_item_nullable,
                    ClassifiedTopLevelObjectType::ArrayWithUnion(&ast),
                )),
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

pub fn get_rescript_relay_meta_data(
    schema: &SDLSchema,
    typegen_definition: &DefinitionType,
    typegen_config: &TypegenConfig,
) -> RescriptRelayOperationMetaData {
    match &typegen_definition {
        DefinitionType::Fragment(definition) => find_assets_in_fragment(
            &definition,
            &schema,
            typegen_config.custom_scalar_types.clone(),
        ),
        DefinitionType::Operation((definition, _)) => find_assets_in_operation(
            &definition,
            &schema,
            typegen_config.custom_scalar_types.clone(),
        ),
    }
}

pub fn is_first_char_uppercase(s: &String) -> bool {
    if let Some(first_char) = s.chars().next() {
        return first_char.is_uppercase();
    } else {
        return false;
    }
}

const DISALLOWED_IDENTIFIERS: &'static [&'static str] = &[
    "and",
    "as",
    "assert",
    "constraint",
    "else",
    "exception",
    "external",
    "false",
    "for",
    "if",
    "in",
    "include",
    "lazy",
    "let",
    "module",
    "mutable",
    "of",
    "open",
    "rec",
    "switch",
    "true",
    "try",
    "type",
    "when",
    "while",
    "with",
    "private",
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
    "updatableFragmentRefs",
    "fragmentRefSelector",
    "operationType",
];

pub fn is_legal_key(key: &String) -> bool {
    DISALLOWED_IDENTIFIERS.contains(&key.as_str())
}

pub fn get_safe_key(original_key: &String) -> (String, Option<String>) {
    if is_first_char_uppercase(&original_key) {
        let uncapitalized = uncapitalize_string(&original_key);
        if is_legal_key(&uncapitalized) {
            (
                format!("{}_", uncapitalized),
                Some(original_key.to_string()),
            )
        } else {
            (uncapitalized, Some(original_key.to_string()))
        }
    } else {
        if is_legal_key(&original_key) {
            (format!("{}_", original_key), Some(original_key.to_string()))
        } else {
            (original_key.to_string(), None)
        }
    }
}

pub fn instruction_to_key_value_pair(instruction: &ConverterInstructions) -> (String, String) {
    match &instruction {
        &ConverterInstructions::ConvertUnion(union_record_name) => {
            (String::from("u"), union_record_name.to_string())
        }
        &ConverterInstructions::ConvertCustomField(converter_name, false) => {
            (String::from("c"), converter_name.to_string())
        }
        &ConverterInstructions::ConvertCustomField(converter_name, true) => {
            (String::from("ca"), converter_name.to_string())
        }
        &ConverterInstructions::RootObject(object_name) => {
            (String::from("r"), object_name.to_string())
        }
        &ConverterInstructions::HasFragments => (String::from("f"), String::from("")),
        &ConverterInstructions::BlockTraversal(is_array) => (
            String::from("b"),
            String::from(if *is_array { "a" } else { "" }),
        ),
    }
}

pub fn get_custom_scalar_name(
    custom_scalar_types: &CustomScalarsMap,
    custom_scalar: &str,
) -> String {
    match custom_scalar_types.get(&ScalarName(custom_scalar.to_string().intern())) {
        None => custom_scalar.to_string(),
        Some(CustomType::Name(name) | CustomType::Path(CustomTypeImport { name, .. })) => {
            name.to_string()
        }
    }
}

pub fn get_custom_scalar_raw_typenames(custom_scalar_types: &CustomScalarsMap) -> Vec<String> {
    custom_scalar_types
        .iter()
        .filter_map(|(_, v)| match &v {
            CustomType::Name(name) => Some(name.to_string()),
            CustomType::Path(_) => None,
        })
        .collect_vec()
}

fn print_wrapped_in_some(str: &String, print_as_optional: bool) -> String {
    if print_as_optional {
        format!("Some({})", str)
    } else {
        format!("{}", str)
    }
}

pub fn print_opt(str: &String, optional: bool, nullability_mode: &NullabilityMode) -> String {
    if optional {
        match &nullability_mode {
            NullabilityMode::Option => format!("option<{}>", str),
            NullabilityMode::Nullable => format!("Js.Null.t<{}>", str),
            NullabilityMode::NullAndUndefined => format!("Js.Nullable.t<{}>", str),
        }
    } else {
        format!("{}", str)
    }
}

// Printer helpers
pub fn print_constant_value(
    value: &ConstantValue,
    print_as_optional: bool,
    wrap_in_arg: bool,
    is_in_args_body: bool,
) -> String {
    match value {
        ConstantValue::Int(i) => print_wrapped_in_some(&i.to_string(), print_as_optional),
        ConstantValue::Float(f) => print_wrapped_in_some(&f.to_string(), print_as_optional),
        ConstantValue::String(s) => {
            print_wrapped_in_some(&format!("\"{}\"", s.to_string()), print_as_optional)
        }
        ConstantValue::Boolean(b) => print_wrapped_in_some(&b.to_string(), print_as_optional),
        ConstantValue::Null() => print_wrapped_in_some(&String::from("Js.null"), print_as_optional),
        ConstantValue::Enum(s) => {
            // It's fine to print enum values as string here if we're in the args body, since it's not important this refers to the correct variant anyway.
            if is_in_args_body {
                print_wrapped_in_some(&format!("\"{}\"", s.to_string()), print_as_optional)
            } else {
                print_wrapped_in_some(
                    &format!("{}", capitalize_string(&s.to_string())),
                    print_as_optional,
                )
            }
        }
        ConstantValue::List(values) => print_wrapped_in_some(
            &format!(
                "[{}]",
                values
                    .iter()
                    .map(|v| if wrap_in_arg {
                        format!(
                            "RescriptRelay_Internal.Arg({})",
                            print_constant_value(
                                v,
                                print_as_optional,
                                wrap_in_arg,
                                is_in_args_body
                            )
                        )
                    } else {
                        print_constant_value(v, print_as_optional, wrap_in_arg, is_in_args_body)
                    })
                    .join(", ")
            ),
            print_as_optional,
        ),
        ConstantValue::Object(arguments) => print_wrapped_in_some(
            &format!(
                "{{{}}}",
                arguments
                    .iter()
                    .map(|arg| {
                        if wrap_in_arg {
                            format!(
                                "\"{}\": {}",
                                arg.name.item,
                                print_constant_value(
                                    &arg.value.item,
                                    print_as_optional,
                                    wrap_in_arg,
                                    is_in_args_body
                                )
                            )
                        } else {
                            format!(
                                "{}: {}",
                                arg.name.item,
                                print_constant_value(
                                    &arg.value.item,
                                    print_as_optional,
                                    wrap_in_arg,
                                    is_in_args_body
                                )
                            )
                        }
                    })
                    .join(", "),
            ),
            print_as_optional,
        ),
    }
}

pub fn print_type_reference(
    typ: &TypeReference<Type>,
    schema: &SDLSchema,
    custom_scalar_types: &CustomScalarsMap,
    nullable: bool,
    prefix_with_schema_module: bool,
    nullability_mode: &NullabilityMode,
    enum_as_inputs: bool,
) -> String {
    match typ {
        TypeReference::Named(named_type) => print_opt(
            &match named_type {
                Type::Enum(id) => {
                    let enum_ = schema.enum_(*id);
                    format!(
                        "{}enum_{}{}",
                        if prefix_with_schema_module {
                            "RelaySchemaAssets_graphql."
                        } else {
                            ""
                        },
                        enum_.name.item,
                        if enum_as_inputs || enum_.is_extension {
                            "_input"
                        } else {
                            ""
                        }
                    )
                }
                Type::InputObject(id) => {
                    let obj = schema.input_object(*id);
                    format!(
                        "{}input_{}{}",
                        if prefix_with_schema_module {
                            "RelaySchemaAssets_graphql."
                        } else {
                            ""
                        },
                        obj.name.item,
                        match &nullability_mode {
                            NullabilityMode::Nullable => "_nullable",
                            _ => "",
                        }
                    )
                }
                Type::Scalar(id) => format!("{}", match schema
                    .scalar(*id)
                    .name
                    .item
                    .to_string()
                    .as_str()
                {
                    "Boolean" => String::from("bool"),
                    "Int" => String::from("int"),
                    "Float" => String::from("float"),
                    "String" | "ID" => String::from("string"),
                    custom_scalar => {
                        let is_custom_scalar = custom_scalar_types
                            .get(&ScalarName(custom_scalar.to_string().intern()))
                            .is_some();

                        if is_custom_scalar {
                            let custom_scalar_name =
                                get_custom_scalar_name(&custom_scalar_types, &custom_scalar);

                            match classify_rescript_value_string(&custom_scalar_name) {
                                RescriptCustomTypeValue::Module => {
                                    format!("{}.t", custom_scalar_name)
                                }
                                RescriptCustomTypeValue::Type => custom_scalar_name.to_string(),
                            }
                        } else {
                            String::from("RescriptRelay.any")
                        }
                    }
                }),
                Type::Object(id) => {
                    let object = schema.object(*id);
                    let weak = object
                        .directives
                        .iter()
                        .find(|d| d.name == *RELAY_RESOLVER_WEAK_OBJECT_DIRECTIVE)
                        .is_some();

                    if weak {
                        format!("Relay{}Model.t", object.name.item)
                    } else if object.is_extension {
                        format!("RescriptRelay.dataIdObject")
                    } else {
                        format!("RescriptRelay.dataId")
                    }
                }
                _ => String::from("RescriptRelay.any"),
            },
            nullable,
            &nullability_mode,
        ),
        TypeReference::NonNull(typ) => format!(
            "{}",
            print_type_reference(
                &typ,
                &schema,
                &custom_scalar_types,
                false,
                prefix_with_schema_module,
                &nullability_mode,
                enum_as_inputs
            )
        ),
        TypeReference::List(typ) => print_opt(
            &format!(
                "array<{}>",
                print_type_reference(
                    &typ,
                    &schema,
                    &custom_scalar_types,
                    true,
                    prefix_with_schema_module,
                    &nullability_mode,
                    enum_as_inputs
                )
            ),
            nullable,
            &nullability_mode,
        ),
    }
}

pub fn print_value(
    value: &Value,
    print_as_optional: bool,
    wrap_in_arg: bool,
    is_in_args_body: bool,
) -> String {
    match value {
        Value::Constant(constant_value) => print_constant_value(
            &constant_value,
            print_as_optional,
            wrap_in_arg,
            is_in_args_body,
        ),
        Value::Variable(variable) => variable.name.item.to_string(),
        Value::List(values) => format!(
            "[{}]",
            values
                .iter()
                .map(|v| if wrap_in_arg {
                    format!(
                        "RescriptRelay_Internal.Arg({})",
                        print_value(v, print_as_optional, wrap_in_arg, is_in_args_body)
                    )
                } else {
                    print_value(v, print_as_optional, wrap_in_arg, is_in_args_body)
                })
                .join(", ")
        ),
        Value::Object(arguments) => format!(
            "{{{}}}",
            arguments
                .iter()
                .map(|arg| {
                    format!(
                        "\"{}\": {}",
                        arg.name.item.to_string(),
                        print_value(
                            &arg.value.item,
                            print_as_optional,
                            wrap_in_arg,
                            is_in_args_body
                        )
                    )
                })
                .join(", ")
        ),
    }
}

pub fn find_all_connection_variables(
    value: &Value,
    found_variables: &mut Vec<(Variable, Option<WithLocation<ConstantValue>>)>,
    fragment_variable_definitions: &Vec<VariableDefinition>,
) -> () {
    match value {
        Value::Variable(variable) => {
            // For some reason, variables found here might not actually have the
            // type information we expect them to. This is probably because what
            // we're getting here is what the _field_ defines, whereas we're
            // interested in what the _fragment_ defines. For example, if we
            // have a nullable argument on the _field_, but the variable passed
            // into that field via the connection fragment is non-nullable, then
            // a connection can only ever be constructed with a non-nullable
            // value for that variable. Hence, when building a connection ID, we
            // always need the user to pass _something_ there.
            //
            // Because of this, we prefer the variable from
            // "argumentDefinitions"
            // (connection_config.fragment_variable_definitions).
            let already_has_variable = found_variables
                .iter()
                .find(|(v, _)| v.name.item == variable.name.item)
                .is_some();

            if !already_has_variable {
                found_variables.push(
                    match fragment_variable_definitions
                        .iter()
                        .find(|v| v.name.item == variable.name.item)
                    {
                        None => (variable.to_owned(), None),
                        Some(v) =>
                        // Construct a synthetic variable here from the definition
                        {
                            (
                                Variable {
                                    name: v.name,
                                    type_: match (&v.type_, v.default_value.as_ref()) {
                                        // Another special case is when the variable is
                                        // optional, but there's a default value. In
                                        // that case, we should treat the variable as
                                        // non-optional, since it would always have a
                                        // value when the connection key is created.
                                        (
                                            TypeReference::List(_) | TypeReference::Named(_),
                                            Some(_),
                                        ) => TypeReference::NonNull(Box::new(v.type_.to_owned())),
                                        _ => v.type_.to_owned(),
                                    },
                                },
                                v.default_value.to_owned(),
                            )
                        }
                    },
                );
            }
        }
        Value::Object(arguments) => arguments.iter().for_each(|arg| {
            find_all_connection_variables(
                &arg.value.item,
                found_variables,
                &fragment_variable_definitions,
            )
        }),
        Value::Constant(_) => (),
        Value::List(values) => values.iter().for_each(|value| {
            find_all_connection_variables(&value, found_variables, &fragment_variable_definitions)
        }),
    }
}

pub fn dig_type_ref(typ: &TypeReference<Type>) -> &Type {
    match typ {
        TypeReference::Named(named_typ) => named_typ,
        TypeReference::List(typ) => dig_type_ref(typ),
        TypeReference::NonNull(typ) => dig_type_ref(typ),
    }
}

pub fn get_connection_key_maker(
    indentation: usize,
    connection_key_arguments: &Vec<Argument>,
    fragment_variable_definitions: &Vec<VariableDefinition>,
    key: &String,
    schema: &SDLSchema,
    custom_scalar_types: &CustomScalarsMap,
) -> String {
    let mut str = String::from("");
    let mut all_variables = vec![];

    // Collect all variables in the pattern
    connection_key_arguments.iter().for_each(|arg| {
        find_all_connection_variables(
            &arg.value.item,
            &mut all_variables,
            &fragment_variable_definitions,
        )
    });

    let mut local_indentation = indentation;

    write_indentation(&mut str, local_indentation).unwrap();
    write!(
        str,
        "%%private(\n  @live @module(\"relay-runtime\") @scope(\"ConnectionHandler\")\n  external internal_makeConnectionId: (RescriptRelay.dataId, @as(\"{}\") _, 'arguments) => RescriptRelay.dataId = \"getConnectionID\"\n)\n\n",
        key
    )
    .unwrap();

    write_indentation(&mut str, local_indentation).unwrap();
    writeln!(str, "@live").unwrap();

    write_indentation(&mut str, local_indentation).unwrap();
    writeln!(
        str,
        "let makeConnectionId = (connectionParentDataId: RescriptRelay.dataId, {}) => {{",
        all_variables
            .iter()
            .map(|(variable, default_value)| {
                // Setting a default value as null means we'll want to treat
                // this entire variable definition as Js.null, so that the null
                // default value works type wise.
                let has_default_value_null = match &default_value {
                    Some(WithLocation {
                        item: ConstantValue::Null(),
                        ..
                    }) => true,
                    _ => false,
                };

                format!(
                    "~{}: {}{}",
                    variable.name.item,
                    if has_default_value_null {
                        format!(
                            "Js.null<{}>",
                            print_type_reference(
                                &variable.type_,
                                &schema,
                                &custom_scalar_types,
                                true,
                                true,
                                &NullabilityMode::Option,
                                false
                            )
                        )
                    } else {
                        print_type_reference(
                            &variable.type_,
                            &schema,
                            &custom_scalar_types,
                            true,
                            true,
                            &NullabilityMode::Option,
                            false,
                        )
                    },
                    match (&default_value, &variable.type_) {
                        (Some(default_value), _) =>
                            format!("={}", match dig_type_ref(&variable.type_) {
                                Type::InputObject(_) => format!(
                                    "{}",
                                    print_constant_value(&default_value.item, false, false, false)
                                ),
                                _ => print_constant_value(&default_value.item, false, false, false),
                            }),
                        (None, TypeReference::List(_) | TypeReference::Named(_)) =>
                            String::from("=?"),
                        (None, TypeReference::NonNull(_)) => String::from(""),
                    }
                )
            })
            .join(", "),
    )
    .unwrap();

    local_indentation += 1;

    /*
     * We need to handle 2 things here for each variable:
     *
     * 1. If the variable is a custom scalar, we need to serialize it so it matches the raw value the store will expect.
     * 2. If the variable isn't optional, we need to wrap it with `Some()`. This is for simplicity with regards to any
     *    constant values also part of the connection id pattern. In order to not have to keep track of what is and isn't
     *    optional to make types match, we ensure everything is always optional as the args object is produced.
     *
     * We also need to special case Js.null<t> here.
     */

    all_variables.iter().for_each(|(variable, default_value)| {
        let is_optional = match variable.type_ {
            TypeReference::NonNull(_) => false,
            TypeReference::List(_) | TypeReference::Named(_) => true,
        };

        let has_default_value_null = match &default_value {
            Some(WithLocation {
                item: ConstantValue::Null(),
                ..
            }) => true,
            _ => false,
        };

        let is_custom_scalar = match dig_type_ref(&variable.type_) {
            Type::Scalar(id) => match schema.scalar(*id).name.item.to_string().as_str() {
                "Boolean" | "Int" | "Float" | "String" | "ID" => None,
                custom_scalar => {
                    let custom_scalar_name =
                        get_custom_scalar_name(&custom_scalar_types, &custom_scalar.to_string());
                    match classify_rescript_value_string(&custom_scalar_name) {
                        RescriptCustomTypeValue::Module => {
                            Some((variable.name.item.to_string(), custom_scalar_name))
                        }
                        RescriptCustomTypeValue::Type => None,
                    }
                }
            },
            _ => None,
        };

        if has_default_value_null {
            write_indentation(&mut str, local_indentation).unwrap();
            writeln!(
                str,
                "let {} = {}->Js.Null.toOption",
                variable.name.item, variable.name.item,
            )
            .unwrap();
        }

        if let Some((variable_name, custom_scalar_module_name)) = is_custom_scalar {
            write_indentation(&mut str, local_indentation).unwrap();
            if is_optional || has_default_value_null {
                writeln!(
                    str,
                    "let {} = switch {} {{ | None => None | Some(v) => Some({}.serialize(v)) }}",
                    variable_name, variable_name, custom_scalar_module_name
                )
                .unwrap();
            } else {
                writeln!(
                    str,
                    "let {} = Some({}.serialize({}))",
                    variable_name, custom_scalar_module_name, variable_name
                )
                .unwrap();
            }
        } else {
            if !is_optional && !has_default_value_null {
                write_indentation(&mut str, local_indentation).unwrap();
                writeln!(
                    str,
                    "let {} = Some({})",
                    variable.name.item, variable.name.item
                )
                .unwrap();
            }
        }
    });

    write_indentation(&mut str, local_indentation).unwrap();
    if connection_key_arguments.len() > 0 {
        writeln!(
            str,
            "let args = {{{}}}",
            connection_key_arguments
                .iter()
                .map(|arg| {
                    format!(
                        "\"{}\": {}",
                        arg.name.item,
                        print_value(&arg.value.item, true, true, true)
                    )
                })
                .join(", ")
        )
        .unwrap();
    } else {
        writeln!(str, "let args = ()").unwrap()
    }

    write_indentation(&mut str, local_indentation).unwrap();
    writeln!(
        str,
        "internal_makeConnectionId(connectionParentDataId, args)"
    )
    .unwrap();

    local_indentation -= 1;
    write_indentation(&mut str, local_indentation).unwrap();
    writeln!(str, "}}").unwrap();

    str
}

pub fn find_provided_variables(
    normalization_operation: &OperationDefinition,
) -> Option<Vec<(String, String)>> {
    let provided_variables = normalization_operation
        .variable_definitions
        .iter()
        .filter_map(|def| {
            let provider_module = ProvidedVariableMetadata::find(&def.directives)?.module_name;
            Some((def.name.item.to_string(), provider_module.to_string()))
        })
        .collect::<Vec<_>>();

    if provided_variables.is_empty() {
        None
    } else {
        Some(provided_variables)
    }
}

// This figures out what type identifiers found in the code actually is, by
// matching the identifier name against all found enums and input objects.
pub enum ClassifiedIdentifier<'a> {
    Enum(&'a FullEnum),

    // The record name of the input object
    InputObject((String, String)),

    RawIdentifier(String),
}

fn value_is_custom_scalar(identifier: &StringKey, custom_scalars: &CustomScalarsMap) -> bool {
    custom_scalars
        .into_iter()
        .find(
            |(_custom_scalar_graphql_name, custom_scalar_mapped_rescript_name)| {
                match custom_scalar_mapped_rescript_name {
                    CustomType::Name(name) => &name == &identifier,
                    CustomType::Path(_) => false,
                }
            },
        )
        .is_some()
}

// This classifies an identifier, meaning it looks up whether its an enum or an
// input object we know of locally in the current context.
pub fn classify_identifier<'a>(
    state: &'a mut ReScriptPrinter,
    identifier: &'a StringKey,
    context: &Context,
) -> ClassifiedIdentifier<'a> {
    let identifier_as_string = identifier.to_string();
    let identifier_uncapitalized = uncapitalize_string(&identifier_as_string);

    // We need to give int and float special treatment here, because the way
    // we've implemented support for them is by overriding `number` in the
    // mapper of scalar types, and leveraging `RawIdentifer` to pass them along
    // to the type generation. This is because the original Relay typegen is
    // designed with Flow and TS in mind, that doesn't have int/float, but
    // rather just number.
    if identifier == &"int".intern() || identifier == &"float".intern() {
        ClassifiedIdentifier::RawIdentifier(identifier_as_string)
    } else if let Some(full_enum) = state
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
        ClassifiedIdentifier::InputObject((
            input_object.record_name.to_string(),
            identifier_as_string.to_string(),
        ))
    } else {
        // Input objects are a bit special, since references to them can appear
        // before they're actually defined, if they're recursive. So, if we're
        // in the context of printing an input object, and what we find isn't a
        // custom scalar, we can go ahead an assume it's an input object. Note:
        // This should probably be switched out in favor of a more robust
        // implementation at some point, that more explicitly deals with the
        // fact that input objects might need to be "filled in" after first
        // appearing as a reference.
        match context {
            &Context::RootObject(_) => {
                match value_is_custom_scalar(&identifier, &state.operation_meta_data.custom_scalars)
                {
                    false => ClassifiedIdentifier::InputObject((
                        identifier_uncapitalized,
                        identifier_as_string,
                    )),
                    true => ClassifiedIdentifier::RawIdentifier(identifier_as_string),
                }
            }
            _ => ClassifiedIdentifier::RawIdentifier(identifier_as_string),
        }
    }
}

pub fn ast_to_string<'a>(
    ast: &AST,
    state: &'a mut ReScriptPrinter,
    context: &Context,
    needs_conversion: &mut Option<AstToStringNeedsConversion>,
    found_in_array: bool,
) -> String {
    match &ast {
        AST::Boolean => String::from("bool"),
        AST::String => String::from("string"),
        AST::StringLiteral(StringLiteral(string_literal)) => {
            format!("[| #{}]", string_literal)
        }
        AST::ReadOnlyArray(inner_type) => format!(
            "array<{}>",
            ast_to_string(inner_type.as_ref(), state, &context, needs_conversion, true)
        ),
        AST::NonNullable(ast) => ast_to_string(ast, state, &context, needs_conversion, false),
        AST::Nullable(ast) => format!(
            "option<{}>",
            ast_to_string(ast, state, &context, needs_conversion, false)
        ),
        AST::RawType(identifier) | AST::Identifier(identifier) => {
            match classify_identifier(state, identifier, &context) {
                ClassifiedIdentifier::Enum(full_enum) => {
                    format!("RelaySchemaAssets_graphql.enum_{}_input", full_enum.name)
                }
                ClassifiedIdentifier::InputObject((_, full_identifier_name)) => {
                    *needs_conversion = Some(AstToStringNeedsConversion::InputObject(
                        full_identifier_name.clone(),
                    ));
                    format!("RelaySchemaAssets_graphql.input_{}", full_identifier_name)
                }
                ClassifiedIdentifier::RawIdentifier(identifier) => {
                    match classify_rescript_value_string(&identifier) {
                        RescriptCustomTypeValue::Module => {
                            *needs_conversion = Some(AstToStringNeedsConversion::CustomScalar(
                                identifier.clone(),
                                found_in_array,
                            ));
                            format!("{}.t", identifier)
                        }
                        RescriptCustomTypeValue::Type => identifier.to_string(),
                    }
                }
            }
        }
        _ => String::from("RescriptRelay.any"),
    }
}

pub fn provided_variable_needs_conversion(
    key: &String,
    provided_variables: &Option<Vec<ProvidedVariable>>,
) -> bool {
    match &provided_variables {
        None => false,
        Some(provided_variables) => provided_variables
            .iter()
            .find(|v| &v.key == key && v.needs_conversion.is_some())
            .is_some(),
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
