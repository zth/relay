use common::SourceLocationKey;
use graphql_ir::FragmentDefinition;
use lazy_static::lazy_static;
use regex::Regex;
use relay_transforms::RelayDirective;
use serde::Serialize;
use std::{
    fmt::Write,
    ops::RangeTo,
    process::{Command, Stdio},
};

#[derive(Serialize, Debug)]
pub struct RescriptRelayConnectionConfig {
    pub key: String,
    pub at_object_path: Vec<String>,
    pub field_name: String,
}

#[derive(Serialize, Debug)]
pub struct RescriptRelayOperationType {
    pub operation: String,
    pub operation_value: Option<String>,
    pub fragment_value: Option<(String, bool)>,
}

#[derive(Serialize, Debug)]
pub struct RescriptRelayOperationConfig {
    pub content: String,
    pub operation_type: RescriptRelayOperationType,
}

pub fn generate_rescript_types(config_type: RescriptRelayOperationConfig) -> String {
    match serde_json::to_string(&config_type) {
        Ok(config) => {
            let cmd = Command::new("./RescriptRelayBin.exe")
                .arg("generate-from-flow")
                .stdout(Stdio::piped())
                .stdin(Stdio::piped())
                .spawn()
                .expect("Failed to spawn external command");

            std::io::Write::write_all(&mut cmd.stdin.unwrap(), config.as_bytes())
                .expect("Could not run external command.");

            let mut res = String::new();
            std::io::Read::read_to_string(&mut cmd.stdout.unwrap(), &mut res).unwrap();

            res
        }
        Err(_) => panic!("Could not build ReasonRelay config."),
    }
}

pub fn is_plural(node: &FragmentDefinition) -> bool {
    RelayDirective::find(&node.directives).map_or(false, |relay_directive| relay_directive.plural)
}

pub fn rescript_find_references_graphql_nodes(concrete_text: &str) -> Vec<String> {
    lazy_static! {
        static ref RE: Regex = Regex::new(r"rescript_graphql_node_([A-Za-z0-9_]*)").unwrap();
        static ref PREFIX_RANGE: RangeTo<usize> = RangeTo {
            end: String::from("rescript_graphql_node_").len()
        };
    }

    let res: Vec<String> = RE
        .find_iter(concrete_text)
        .filter_map(|graphql_module_name| {
            let mut full_matched_name: String = graphql_module_name.as_str().parse().ok().unwrap();
            String::replace_range(&mut full_matched_name, *PREFIX_RANGE, "");
            Some(full_matched_name)
        })
        .collect();

    res
}

pub fn rescript_make_operation_type_and_node_text(concrete_text: &str) -> String {
    lazy_static! {
        static ref PREFIX: String = String::from("rescript_graphql_node_");
    }

    let mut str = String::new();

    let refrenced_graphql_nodes = rescript_find_references_graphql_nodes(&concrete_text);

    if refrenced_graphql_nodes.len() == 0 {
        writeln!(
            str,
            "let node: operationType = %raw(json`{}`)",
            &concrete_text
        )
        .unwrap()
    } else {
        // Write arg names
        writeln!(
            str,
            "%%private(let makeNode = ({}): operationType => {{",
            refrenced_graphql_nodes
                .iter()
                .map(|module_name| format!("{}{}", *PREFIX, module_name))
                .collect::<Vec<String>>()
                .join(", ")
        )
        .unwrap();

        // Write ignores
        writeln!(
            str,
            "{}",
            refrenced_graphql_nodes
                .iter()
                .map(|module_name| format!("  ignore({}{})", *PREFIX, module_name))
                .collect::<Vec<String>>()
                .join("\n")
        )
        .unwrap();

        // Print artifact and close fn
        writeln!(str, "  %raw(json`{}`)\n}})", &concrete_text).unwrap();

        // Write node via makeNode and pass all referenced variables
        writeln!(
            str,
            "let node: operationType = makeNode({})",
            refrenced_graphql_nodes
                .iter()
                .map(|module_name| format!("{}_graphql.node", module_name))
                .collect::<Vec<String>>()
                .join(", ")
        )
        .unwrap();
    }

    str
}

// Write a @sourceLoc annotation pointing to where this thing was found
pub fn rescript_get_source_loc_text(source_file: &SourceLocationKey) -> String {
    match source_file {
        SourceLocationKey::Standalone { path } | SourceLocationKey::Embedded { path, index: _ } => {
            format!(
                "/* @sourceLoc {} */",
                std::path::Path::new(&path.to_string())
                    .file_name()
                    .unwrap()
                    .to_string_lossy()
            )
        }
        SourceLocationKey::Generated => String::from(""),
    }
}

pub fn rescript_get_comments_for_generated() -> String {
    String::from("/* @generated */\n%%raw(\"/* @generated */\")")
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn find_used_additional_operations() {
        assert_eq!(
            vec!["ComponentRefetchQuery"],
            rescript_find_references_graphql_nodes(
                r#"{
            "argumentDefinitions": [],
            "kind": "Fragment",
            "metadata": {
              "refetch": {
                "connection": null,
                "fragmentPathInResult": [
                  "node"
                ],
                "operation": rescript_graphql_node_ComponentRefetchQuery,
                "identifierField": "id"
              }
            },
            "name": "Component_node",
            "selections": [
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "id",
                "storageKey": null
              }
            ],
            "type": "Node",
            "abstractKey": "__isNode"
          }"#
            )
        );
    }
}
