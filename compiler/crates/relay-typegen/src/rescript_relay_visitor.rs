/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

use graphql_ir::{
    ConstantValue, Directive, Field, LinkedField, ScalarField, Value, Variable, Visitor,
};
use intern::string_key::{Intern, StringKey};
use lazy_static::lazy_static;
use schema::SDLSchema;

#[derive(Debug)]
pub struct RescriptRelayConnectionConfig {
    pub key: String,
    pub at_object_path: Vec<String>,
    pub field_name: String,
}

#[derive(Debug)]
pub struct RescriptRelayOperationMetaData {
    pub connection_config: Option<RescriptRelayConnectionConfig>,
    pub variables_with_connection_data_ids: Vec<String>,
}

pub struct RescriptRelayVisitor<'a> {
    schema: &'a SDLSchema,
    current_path: Vec<String>,
    state: &'a mut RescriptRelayOperationMetaData,
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
        }
    }
}

lazy_static! {
    static ref APPEND_EDGE: StringKey = "appendEdge".intern();
    static ref APPEND_NODE: StringKey = "appendNode".intern();
    static ref DELETE_EDGE: StringKey = "deleteEdge".intern();
    static ref PREPEND_EDGE: StringKey = "prependEdge".intern();
    static ref PREPEND_NODE: StringKey = "prependNode".intern();
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
                self.state.connection_config = Some(RescriptRelayConnectionConfig {
                    key,
                    at_object_path: self.current_path.clone(),
                    field_name: field.alias_or_name(self.schema).to_string(),
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
