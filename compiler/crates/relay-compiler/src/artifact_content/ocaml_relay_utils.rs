use common::SourceLocationKey;
use lazy_static::lazy_static;
use regex::Regex;
use std::{fmt::Write, ops::RangeTo};

#[derive(Debug, PartialEq, Eq)]
pub enum ImportType {
    GraphQLNode(String),
    ModuleImport(String),
    ProvidedVariables,
}

pub fn ocaml_find_code_import_references(concrete_text: &str) -> Vec<ImportType> {
    lazy_static! {
        static ref RE_GRAPHQL_NODE: Regex =
            Regex::new(r"ocaml_graphql_node_([A-Za-z0-9_]*)").unwrap();
        static ref PREFIX_RANGE_GRAPHQL_NODE: RangeTo<usize> = RangeTo {
            end: String::from("ocaml_graphql_node_").len()
        };
        static ref RE_MODULE_IMPORT: Regex = Regex::new(r"ocaml_module_([A-Za-z0-9_]*)").unwrap();
        static ref PREFIX_RANGE_MODULE_IMPORT: RangeTo<usize> = RangeTo {
            end: String::from("ocaml_module_").len()
        };
    }

    let mut results: Vec<ImportType> = vec![];

    RE_GRAPHQL_NODE
        .find_iter(concrete_text)
        .for_each(|graphql_module_name| {
            let mut full_matched_name: String = graphql_module_name.as_str().parse().ok().unwrap();
            String::replace_range(&mut full_matched_name, *PREFIX_RANGE_GRAPHQL_NODE, "");
            results.push(ImportType::GraphQLNode(full_matched_name));
        });

    RE_MODULE_IMPORT
        .find_iter(concrete_text)
        .for_each(|module_import_name| {
            let mut full_matched_name: String = module_import_name.as_str().parse().ok().unwrap();
            String::replace_range(&mut full_matched_name, *PREFIX_RANGE_MODULE_IMPORT, "");
            results.push(ImportType::ModuleImport(full_matched_name))
        });

    results
}

pub fn ocaml_make_operation_type_and_node_text(
    concrete_text: &str,
    has_provided_variables: bool,
) -> String {
    lazy_static! {
        static ref PREFIX_GRAPHQL_IMPORT: String = String::from("ocaml_graphql_node_");
        static ref PREFIX_CODE_IMPORT: String = String::from("ocaml_module_");
    }

    let mut str = String::new();

    let mut referenced_imports = ocaml_find_code_import_references(&concrete_text);

    if has_provided_variables {
        referenced_imports.push(ImportType::ProvidedVariables)
    }

    if referenced_imports.len() == 0 {
        writeln!(
            str,
            "let node: operationType = [%mel.raw {{json| {} |json}}]",
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
                        &ImportType::GraphQLNode(_) => "ocaml_graphql_node_",
                        &ImportType::ModuleImport(_) => "ocaml_module_",
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
                        &ImportType::GraphQLNode(_) => "ocaml_graphql_node_",
                        &ImportType::ModuleImport(_) => "ocaml_module_",
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
    String::from("(* @generated *)\n[%%mel.raw \"/* @generated */\"]")
}
