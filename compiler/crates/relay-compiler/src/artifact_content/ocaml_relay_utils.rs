use common::SourceLocationKey;
use lazy_static::lazy_static;
use std::{fmt::Write};
use super::rescript_relay_utils::{
    ImportType, rescript_find_code_import_references
};

pub fn ocaml_make_operation_type_and_node_text(
    concrete_text: &str,
    has_provided_variables: bool,
) -> String {
    lazy_static! {
        static ref PREFIX_GRAPHQL_IMPORT: String = String::from("rescript_graphql_node_");
        static ref PREFIX_CODE_IMPORT: String = String::from("rescript_module_");
    }

    let mut str = String::new();

    let mut referenced_imports = rescript_find_code_import_references(&concrete_text);

    if has_provided_variables {
        referenced_imports.push(ImportType::ProvidedVariables)
    }

    if referenced_imports.len() == 0 {
        writeln!(
            str,
            "let node: operationType = [%bs.raw {{json| {} |json}}]",
            &concrete_text
        )
        .unwrap()
    } else {
        // Write arg names
        writeln!(
            str,
            "[%%private let makeNode {}: operationType = ",
            referenced_imports
                .iter()
                .map(|import_type| format!(
                    "{}{}",
                    match &import_type {
                        &ImportType::GraphQLNode(_) => "rescript_graphql_node_",
                        &ImportType::ModuleImport(_) => "rescript_module_",
                        &ImportType::ProvidedVariables => "providedVariablesDefinition",
                    },
                    match &import_type {
                        &ImportType::GraphQLNode(module_name) => module_name,
                        &ImportType::ModuleImport(module_name) => module_name,
                        &ImportType::ProvidedVariables => "",
                    }
                ))
                .collect::<Vec<String>>()
                .join(" ")
        )
        .unwrap();

        // Write ignores
        writeln!(
            str,
            "{}",
            referenced_imports
                .iter()
                .map(|import_type| format!(
                    "  ignore {}{};",
                    match &import_type {
                        &ImportType::GraphQLNode(_) => "rescript_graphql_node_",
                        &ImportType::ModuleImport(_) => "rescript_module_",
                        &ImportType::ProvidedVariables => "providedVariablesDefinition",
                    },
                    match &import_type {
                        &ImportType::GraphQLNode(module_name) => module_name,
                        &ImportType::ModuleImport(module_name) => module_name,
                        &ImportType::ProvidedVariables => "",
                    }
                ))
                .collect::<Vec<String>>()
                .join("\n")
        )
        .unwrap();

        // Print artifact and close fn
        writeln!(str, "  [%raw {{json|{}|json}}]\n]", &concrete_text).unwrap();

        // Write node via makeNode and pass all referenced variables
        writeln!(
            str,
            "let node: operationType = makeNode {}",
            referenced_imports
                .iter()
                .map(|import_type| format!(
                    "{}",
                    match &import_type {
                        &ImportType::GraphQLNode(module_name) =>
                            format!("{}_graphql.node", module_name),
                        &ImportType::ModuleImport(module_name) =>
                            format!("{}.default", module_name),
                        &ImportType::ProvidedVariables =>
                            String::from("providedVariablesDefinition"),
                    },
                ))
                .collect::<Vec<String>>()
                .join(" ")
        )
        .unwrap();
    }

    str
}


// Write a @sourceLoc annotation pointing to where this thing was found
pub fn ocaml_get_source_loc_text(source_file: &SourceLocationKey) -> Option<String> {
    match source_file {
        SourceLocationKey::Embedded { path, .. } | SourceLocationKey::Standalone { path } => {
            Some(format!(
                "(* @sourceLoc {} *)",
                std::path::Path::new(&path.to_string())
                    .file_name()
                    .unwrap()
                    .to_string_lossy()
            ))
        }
        SourceLocationKey::Generated => None,
    }
}

pub fn ocaml_get_comments_for_generated() -> String {
    String::from("(* @generated *)\n[%%bs.raw \"/* @generated */\"]")
}


