/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

use fnv::FnvBuildHasher;
use graphql_ir::{
    Argument, ConstantValue, Directive, Field, FragmentDefinition, OperationDefinition, Selection,
    Value, Variable, VariableDefinition,
};
use indexmap::IndexMap;
use intern::string_key::{Intern, StringKey};
use lazy_static::lazy_static;
use relay_config::CustomScalarType;
use schema::{SDLSchema, Schema, Type};

use crate::rescript_utils::get_connection_key_maker;
type FnvIndexMap<K, V> = IndexMap<K, V, FnvBuildHasher>;
pub type CustomScalarsMap = FnvIndexMap<StringKey, CustomScalarType>;

#[derive(Debug)]
pub struct RescriptRelayConnectionConfig {
    pub key: String,
    pub at_object_path: Vec<String>,
    pub field_name: String,
    pub connection_key_arguments: Vec<Argument>,
    pub fragment_variable_definitions: Vec<VariableDefinition>,
    pub connection_id_maker_fn: String,
}

#[derive(Debug, PartialEq, Eq)]
pub enum RescriptRelayFragmentDirective {
    IgnoreUnused,
}

#[derive(Debug, PartialEq, Eq)]
pub enum RescriptRelayFieldDirective {
    AllowUnsafeEnum,
}

#[derive(Debug, PartialEq, Eq)]
pub struct FieldDirectiveContainer {
    pub at_object_path: Vec<String>,
    pub directive: RescriptRelayFieldDirective,
}

#[derive(Debug)]
pub struct RescriptRelayOperationMetaData {
    pub connection_config: Option<RescriptRelayConnectionConfig>,
    pub variables_with_connection_data_ids: Vec<String>,
    pub custom_scalars: CustomScalarsMap,
    pub fragment_directives: Vec<RescriptRelayFragmentDirective>,
    pub field_directives: Vec<FieldDirectiveContainer>,
}

lazy_static! {
    static ref APPEND_EDGE: StringKey = "appendEdge".intern();
    static ref APPEND_NODE: StringKey = "appendNode".intern();
    static ref DELETE_EDGE: StringKey = "deleteEdge".intern();
    static ref PREPEND_EDGE: StringKey = "prependEdge".intern();
    static ref PREPEND_NODE: StringKey = "prependNode".intern();
    static ref FRAGMENT_DIRECTIVE_IGNORE_UNUSED: StringKey = "rescriptRelayIgnoreUnused".intern();
    static ref FIELD_DIRECTIVE_ALLOW_UNSAFE_ENUM: StringKey =
        "rescriptRelayAllowUnsafeEnum".intern();
}

fn find_connections_arguments(directive: Option<&Directive>) -> Vec<String> {
    let mut variable_names = vec![];

    match directive {
        None => (),
        Some(directive) => {
            directive.arguments.iter().for_each(|argument| {
                if argument.name.item == String::from("connections").intern() {
                    match argument.value.item {
                        Value::Variable(Variable { name, type_: _ }) => {
                            variable_names.push(name.item.to_string())
                        }
                        _ => (),
                    }
                }
            });
            ()
        }
    }

    variable_names
}

fn make_path(current_path: &Vec<String>, new_element: String) -> Vec<String> {
    [current_path.clone(), vec![new_element]].concat()
}

fn visit_selections<'a>(
    selections: &Vec<Selection>,
    schema: &'a SDLSchema,
    operation_meta_data: &mut RescriptRelayOperationMetaData,
    variable_definitions: &Vec<VariableDefinition>,
    custom_scalars: &CustomScalarsMap,
    current_path: Vec<String>,
) -> () {
    selections.iter().for_each(|f| match &f {
        Selection::ScalarField(field) => {
            let delete_edge_directive = field
                .directives
                .iter()
                .find(|directive| directive.name.item == *DELETE_EDGE);

            find_connections_arguments(delete_edge_directive)
                .iter()
                .for_each(|variable_name| {
                    operation_meta_data
                        .variables_with_connection_data_ids
                        .push(variable_name.to_string())
                });

            field.directives.iter().for_each(|directive| {
                if directive.name.item == *FIELD_DIRECTIVE_ALLOW_UNSAFE_ENUM {
                    let mut at_object_path = current_path.clone();
                    at_object_path.push(field.alias_or_name(schema).to_string());

                    operation_meta_data
                        .field_directives
                        .push(FieldDirectiveContainer {
                            directive: RescriptRelayFieldDirective::AllowUnsafeEnum,
                            at_object_path,
                        })
                }
            });
        }
        Selection::LinkedField(field) => {
            // Find connection info
            if let Some(connection_directive) = field
                .directives
                .iter()
                .find(|directive| directive.name.item.to_string() == "connection")
            {
                if let Some(key) = connection_directive.arguments.iter().find_map(|arg| {
                    match (&arg.name.item.to_string()[..], &arg.value.item) {
                        ("key", Value::Constant(ConstantValue::String(key_value))) => {
                            Some(key_value.to_string())
                        }
                        _ => None,
                    }
                }) {
                    let filters = connection_directive.arguments.iter().find_map(|arg| {
                        if arg.name.item.to_string() == "filters" {
                            match &arg.value.item {
                                Value::Constant(ConstantValue::List(items)) => Some(
                                    items
                                        .iter()
                                        .filter_map(|value| match value {
                                            ConstantValue::String(item) => Some(item.to_string()),
                                            _ => None,
                                        })
                                        .collect::<Vec<String>>(),
                                ),
                                _ => None,
                            }
                        } else {
                            None
                        }
                    });

                    let relevant_arguments = field
                        .arguments
                        .iter()
                        .filter(|arg| {
                            if &arg.name.item == &"first".intern()
                                || &arg.name.item == &"last".intern()
                                || &arg.name.item == &"before".intern()
                                || &arg.name.item == &"after".intern()
                            {
                                false
                            } else {
                                match &filters {
                                    None => true,
                                    Some(filters) => filters.contains(&arg.name.item.to_string()),
                                }
                            }
                        })
                        .map(|arg| arg.to_owned())
                        .collect::<Vec<Argument>>();

                    operation_meta_data.connection_config = Some(RescriptRelayConnectionConfig {
                        connection_id_maker_fn: get_connection_key_maker(
                            0,
                            &relevant_arguments,
                            &variable_definitions,
                            &key,
                            &schema,
                            &custom_scalars,
                        ),
                        key,
                        at_object_path: current_path.clone(),
                        field_name: field.alias_or_name(schema).to_string(),
                        connection_key_arguments: relevant_arguments,
                        fragment_variable_definitions: variable_definitions.to_owned(),
                    })
                }
            }

            // Look for $connections
            let edge_directive = field.directives.iter().find(|directive| {
                directive.name.item == *APPEND_EDGE || directive.name.item == *PREPEND_EDGE
            });
            let node_directive = field.directives.iter().find(|directive| {
                directive.name.item == *APPEND_NODE || directive.name.item == *PREPEND_NODE
            });

            find_connections_arguments(edge_directive)
                .iter()
                .for_each(|variable_name| {
                    operation_meta_data
                        .variables_with_connection_data_ids
                        .push(variable_name.to_string())
                });

            find_connections_arguments(node_directive)
                .iter()
                .for_each(|variable_name| {
                    operation_meta_data
                        .variables_with_connection_data_ids
                        .push(variable_name.to_string())
                });

            visit_selections(
                &field.selections,
                &schema,
                operation_meta_data,
                &variable_definitions,
                &custom_scalars,
                make_path(&current_path, field.alias_or_name(schema).to_string()),
            );
        }
        Selection::InlineFragment(inline_fragment) => {
            let type_name = match &inline_fragment.type_condition {
                Some(Type::Object(id)) => Some(schema.object(*id).name),
                Some(Type::Interface(id)) => Some(schema.interface(*id).name),
                Some(Type::Union(id)) => Some(schema.union(*id).name),
                _ => None,
            };

            match type_name {
                None => (),
                Some(type_name) => visit_selections(
                    &inline_fragment.selections,
                    &schema,
                    operation_meta_data,
                    &variable_definitions,
                    &custom_scalars,
                    make_path(&current_path, type_name.item.to_string()),
                ),
            }
        }
        _ => (),
    });
}

pub fn find_assets_in_fragment<'a>(
    fragment: &FragmentDefinition,
    schema: &'a SDLSchema,
    custom_scalars: CustomScalarsMap,
) -> RescriptRelayOperationMetaData {
    let rescript_relay_directives: Vec<RescriptRelayFragmentDirective> = fragment
        .directives
        .iter()
        .filter_map(|directive| {
            if directive.name.item == *FRAGMENT_DIRECTIVE_IGNORE_UNUSED {
                Some(RescriptRelayFragmentDirective::IgnoreUnused)
            } else {
                None
            }
        })
        .collect();

    let mut operation_meta_data = RescriptRelayOperationMetaData {
        connection_config: None,
        custom_scalars: custom_scalars.clone(),
        field_directives: vec![],
        fragment_directives: rescript_relay_directives,
        variables_with_connection_data_ids: vec![],
    };

    let variable_definitions = if fragment.variable_definitions.len() > 0 {
        fragment
            .variable_definitions
            .iter()
            .map(|v| v.to_owned())
            .collect()
    } else {
        vec![]
    };

    visit_selections(
        &fragment.selections,
        &schema,
        &mut operation_meta_data,
        &variable_definitions,
        &custom_scalars,
        vec![String::from("fragment")],
    );

    operation_meta_data
}

pub fn find_assets_in_operation<'a>(
    operation: &OperationDefinition,
    schema: &'a SDLSchema,
    custom_scalars: CustomScalarsMap,
) -> RescriptRelayOperationMetaData {
    let mut operation_meta_data = RescriptRelayOperationMetaData {
        connection_config: None,
        custom_scalars: custom_scalars.clone(),
        field_directives: vec![],
        fragment_directives: vec![],
        variables_with_connection_data_ids: vec![],
    };

    let variable_definitions = vec![];

    visit_selections(
        &operation.selections,
        &schema,
        &mut operation_meta_data,
        &variable_definitions,
        &custom_scalars,
        vec![String::from("response")],
    );

    operation_meta_data
}
