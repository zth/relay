use std::{
    io::{Read, Write},
    process::{Command, Stdio},
};

use graphql_ir::FragmentDefinition;
use relay_transforms::RelayDirective;
use serde::Serialize;

#[derive(Serialize)]
pub struct ReasonRelayConnectionConfig {
    pub key: String,
    pub at_object_path: Vec<String>,
    pub field_name: String,
}

#[derive(Serialize)]
pub struct ReasonRelayOperationType {
    pub operation: String,
    pub operation_value: Option<String>,
    pub fragment_value: Option<(String, bool)>,
}

#[derive(Serialize)]
pub struct ReasonRelayOperationConfig {
    pub content: String,
    pub operation_type: ReasonRelayOperationType,
    pub operation_node: String,
    pub operation_hash: Option<String>,
    pub operation_request_id: Option<String>,
    pub raw_js: String,
}

pub fn generate_rescript_types(config_type: ReasonRelayOperationConfig) -> Vec<u8> {
    match serde_json::to_string(&config_type) {
        Ok(config) => {
            let cmd = Command::new("./ReasonRelayBin.exe")
                .arg("generate-from-flow")
                .stdout(Stdio::piped())
                .stdin(Stdio::piped())
                .spawn()
                .expect("Failed to spawn external command");

            Write::write_all(&mut cmd.stdin.unwrap(), config.as_bytes())
                .expect("Could not run external command.");

            let mut buf = vec![];
            Read::read_to_end(&mut cmd.stdout.unwrap(), &mut buf).unwrap();

            buf
        }
        Err(_) => panic!("Could not build ReasonRelay config."),
    }
}

pub fn is_plural(node: &FragmentDefinition) -> bool {
    RelayDirective::find(&node.directives).map_or(false, |relay_directive| relay_directive.plural)
}
