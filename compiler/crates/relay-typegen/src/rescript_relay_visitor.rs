/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

use fnv::FnvBuildHasher;
use graphql_ir::{
    Argument, ConstantValue, Directive, Field, FragmentDefinition, LinkedField, ScalarField, Value,
    Variable, VariableDefinition, Visitor,
};
use indexmap::IndexMap;
use intern::string_key::{Intern, StringKey};
use lazy_static::lazy_static;
use relay_config::CustomScalarType;
use schema::SDLSchema;

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

pub struct RescriptRelayVisitor<'a> {
    schema: &'a SDLSchema,
    current_path: Vec<String>,
    state: &'a mut RescriptRelayOperationMetaData,
    variable_definitions: Vec<VariableDefinition>,
}

impl<'a> RescriptRelayVisitor<'a> {
    pub fn new(
        schema: &'a SDLSchema,
        state: &'a mut RescriptRelayOperationMetaData,
        initial_path: String,
    ) -> Self {
        Self {
            schema,
            current_path: vec![initial_path],
            state,
            variable_definitions: vec![],
        }
    }
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

impl<'a> Visitor for RescriptRelayVisitor<'a> {
    const NAME: &'static str = "RescriptRelayVisitor";
    const VISIT_ARGUMENTS: bool = false;
    const VISIT_DIRECTIVES: bool = false;

    fn visit_fragment(&mut self, fragment: &FragmentDefinition) {
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

        self.state.fragment_directives = rescript_relay_directives;

        if fragment.variable_definitions.len() > 0 {
            self.variable_definitions = fragment
                .variable_definitions
                .iter()
                .map(|v| v.to_owned())
                .collect();
        }

        self.default_visit_fragment(fragment)
    }

    fn visit_scalar_field(&mut self, field: &ScalarField) {
        let delete_edge_directive = field
            .directives
            .iter()
            .find(|directive| directive.name.item == *DELETE_EDGE);

        find_connections_arguments(delete_edge_directive)
            .iter()
            .for_each(|variable_name| {
                self.state
                    .variables_with_connection_data_ids
                    .push(variable_name.to_string())
            });

        field.directives.iter().for_each(|directive| {
            if directive.name.item == *FIELD_DIRECTIVE_ALLOW_UNSAFE_ENUM {
                let mut at_object_path = self.current_path.clone();
                at_object_path.push(field.alias_or_name(self.schema).to_string());

                self.state.field_directives.push(FieldDirectiveContainer {
                    directive: RescriptRelayFieldDirective::AllowUnsafeEnum,
                    at_object_path,
                })
            }
        });

        self.default_visit_scalar_field(field)
    }

    fn visit_linked_field(&mut self, field: &LinkedField) {
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

                self.state.connection_config = Some(RescriptRelayConnectionConfig {
                    connection_id_maker_fn: get_connection_key_maker(
                        1,
                        &relevant_arguments,
                        &self.variable_definitions,
                        &key,
                        &self.schema,
                    ),
                    key,
                    at_object_path: self.current_path.clone(),
                    field_name: field.alias_or_name(self.schema).to_string(),
                    connection_key_arguments: relevant_arguments,
                    fragment_variable_definitions: self.variable_definitions.to_owned(),
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
                self.state
                    .variables_with_connection_data_ids
                    .push(variable_name.to_string())
            });

        find_connections_arguments(node_directive)
            .iter()
            .for_each(|variable_name| {
                self.state
                    .variables_with_connection_data_ids
                    .push(variable_name.to_string())
            });

        self.current_path
            .push(field.alias_or_name(self.schema).to_string());

        self.default_visit_linked_field(field)
    }
}
