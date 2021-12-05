use graphql_ir::FragmentDefinition;
use relay_transforms::RelayDirective;
use serde::Serialize;
use std::process::{Command, Stdio};

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
    pub operation_node: String,
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
