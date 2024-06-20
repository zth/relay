use common::SourceLocationKey;
use intern::string_key::Intern;
use lazy_static::lazy_static;
use regex::Regex;
use relay_typegen::rescript_utils::uncapitalize_string;
use std::{fmt::Write, ops::RangeTo};

#[derive(Debug, PartialEq, Eq)]
pub enum ImportType {
    GraphQLNode(String),
    ModuleImport(String, Option<String>),
    ProvidedVariables,
    ResolverDataInjector
}

pub fn rescript_find_code_import_references(concrete_text: &str) -> Vec<ImportType> {
    lazy_static! {
        static ref RE_GRAPHQL_NODE: Regex =
            Regex::new(r"rescript_graphql_node_([A-Za-z0-9_]*)").unwrap();
        static ref PREFIX_RANGE_GRAPHQL_NODE: RangeTo<usize> = RangeTo {
            end: String::from("rescript_graphql_node_").len()
        };
        static ref RE_MODULE_IMPORT: Regex =
            Regex::new(r"rescript_module_([A-Za-z0-9_]*)(?:\.([A-Za-z0-9_]*))?").unwrap();
        static ref PREFIX_RANGE_MODULE_IMPORT: RangeTo<usize> = RangeTo {
            end: String::from("rescript_module_").len()
        };
    }

    let mut results: Vec<ImportType> = vec![];

    RE_GRAPHQL_NODE
        .find_iter(concrete_text)
        .for_each(|graphql_module_name| {
            let mut full_matched_name: String = graphql_module_name.as_str().parse().ok().unwrap();
            String::replace_range(&mut full_matched_name, *PREFIX_RANGE_GRAPHQL_NODE, "");
            let graphql_node = ImportType::GraphQLNode(full_matched_name);
            if !results.contains(&graphql_node) {
                results.push(graphql_node);
            }
        });

    RE_MODULE_IMPORT
        .find_iter(concrete_text)
        .for_each(|module_import_name| {
            let mut full_matched_name: String = module_import_name.as_str().parse().ok().unwrap();
            String::replace_range(&mut full_matched_name, *PREFIX_RANGE_MODULE_IMPORT, "");
            let matched_name: Vec<&str> = full_matched_name.split(".").collect();
            let module_name = matched_name.get(0).unwrap();
            let path = match matched_name.get(1) {
                Some(path) => Some(path.to_string()),
                None => None
            };
            if path.is_some() && !results.contains(&ImportType::ResolverDataInjector) {
                results.push(ImportType::ResolverDataInjector)
            }
            let module_import = ImportType::ModuleImport(module_name.to_string(), path);
            if !results.contains(&module_import) {
                results.push(module_import)
            }

        });

    results
}

pub fn rescript_make_operation_type_and_node_text(
    concrete_text: &str,
    has_provided_variables: bool,
    is_updatable_fragment: bool,
    is_updatable_query: bool,
) -> String {
    lazy_static! {
        static ref PREFIX_GRAPHQL_IMPORT: String = String::from("rescript_graphql_node_");
        static ref PREFIX_CODE_IMPORT: String = String::from("rescript_module_");
    }

    let mut str = String::new();

    let mut referenced_imports = rescript_find_code_import_references(&concrete_text);
    let mut replaced_text = concrete_text.to_string();
    for imp in &referenced_imports {
        match imp {
            ImportType::ModuleImport(module_name, Some(path)) => {
                let replace_this = format!("{}.{}", module_name, path);
                let with_this = format!("{}_{}", module_name, path);
                replaced_text = replaced_text.replace(&replace_this, &with_this);
            },
            _ => ()
        }
    }

    if has_provided_variables {
        referenced_imports.push(ImportType::ProvidedVariables)
    }

    if referenced_imports.len() == 0 {
        writeln!(
            str,
            "let node: operationType = %raw(json` {} `)",
            &replaced_text
        )
        .unwrap()
    } else {
        // Write arg names
        writeln!(
            str,
            "%%private(let makeNode = ({}): operationType => {{",
            referenced_imports
                .iter()
                .map(|import_type| format!(
                    "{}{}",
                    match &import_type {
                        &ImportType::GraphQLNode(_) => "rescript_graphql_node_",
                        &ImportType::ModuleImport(_, _) => "rescript_module_",
                        &ImportType::ProvidedVariables => "providedVariablesDefinition",
                        &ImportType::ResolverDataInjector => "resolverDataInjector"
                    },
                    match &import_type {
                        &ImportType::GraphQLNode(module_name) => module_name.to_owned(),
                        &ImportType::ModuleImport(module_name, path) => {
                            match &path {
                                Some(path) => {
                                    let d = format!("{}_{}", module_name, path);
                                    d
                                },
                                None => module_name.to_owned()
                            }
                        },
                        &ImportType::ProvidedVariables | &ImportType::ResolverDataInjector => "".to_owned(),
                    }
                ))
                .collect::<Vec<String>>()
                .join(", ")
        )
        .unwrap();

        // Write ignores
        writeln!(
            str,
            "{}",
            referenced_imports
                .iter()
                .map(|import_type| format!(
                    "  ignore({}{})",
                    match &import_type {
                        &ImportType::GraphQLNode(_) => "rescript_graphql_node_",
                        &ImportType::ModuleImport(_, _) => "rescript_module_",
                        &ImportType::ProvidedVariables => "providedVariablesDefinition",
                        &ImportType::ResolverDataInjector => "resolverDataInjector",
                    },
                    match &import_type {
                        &ImportType::GraphQLNode(module_name) => module_name.to_owned(),
                        &ImportType::ModuleImport(module_name, path) => {
                            match &path {
                                Some(path) => {
                                    let d = format!("{}_{}", module_name, path);
                                    d
                                },
                                None => module_name.to_owned()
                            }
                        },
                        &ImportType::ProvidedVariables | &ImportType::ResolverDataInjector => "".to_owned(),
                    }
                ))
                .collect::<Vec<String>>()
                .join("\n")
        )
        .unwrap();

        // Print artifact and close fn
        writeln!(str, "  %raw(json`{}`)\n}})", &replaced_text).unwrap();

        // Write node via makeNode and pass all referenced variables
        writeln!(
            str,
            "let node: operationType = makeNode({})",
            referenced_imports
                .iter()
                .map(|import_type| format!(
                    "{}",
                    match &import_type {
                        &ImportType::GraphQLNode(module_name) =>
                            format!("{}_graphql.node", module_name),
                        &ImportType::ModuleImport(module_name, path) =>
                            format!("{}.{}", module_name, match &path {
                                Some(path) => uncapitalize_string(path).intern(),
                                None => "default".intern()
                            }),
                        &ImportType::ProvidedVariables =>
                            String::from("providedVariablesDefinition"),
                        &ImportType::ResolverDataInjector =>
                            String::from("RescriptRelay.resolverDataInjector"),
                    },
                ))
                .collect::<Vec<String>>()
                .join(", ")
        )
        .unwrap();
    }

    // Hook up updatable fragment reader
    if is_updatable_fragment {
        writeln!(str, "\n\nlet readUpdatableFragment = (store, fragmentRefs) => store->readUpdatableFragment(~node, ~fragmentRefs)").unwrap();
    }

    // Hook up updatable query reader
    if is_updatable_query {
        writeln!(str, "\n\nlet readUpdatableQuery = (store, variables: Types.variables) => store->readUpdatableQuery(~node, ~variables=Internal.convertVariables(variables))").unwrap();
    }

    str
}

// Write a @sourceLoc annotation pointing to where this thing was found
pub fn rescript_get_source_loc_text(source_file: &SourceLocationKey) -> Option<String> {
    match source_file {
        SourceLocationKey::Embedded { path, .. } | SourceLocationKey::Standalone { path } => {
            Some(format!(
                "/* @sourceLoc {} */",
                std::path::Path::new(&path.to_string())
                    .file_name()
                    .unwrap()
                    .to_string_lossy()
            ))
        }
        SourceLocationKey::Generated => None,
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
            vec![
                ImportType::GraphQLNode(String::from("ComponentRefetchQuery")),
                ImportType::ModuleImport(String::from("TestRelayResolver"), None)
            ],
            rescript_find_code_import_references(
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
              },
              {
                "alias": null,
                "fragment": {
                  "args": null,
                  "kind": "FragmentSpread",
                  "name": "TestRelayResolver"
                },
                "kind": "RelayResolver",
                "name": "greeting",
                "resolverModule": rescript_module_TestRelayResolver,
                "path": "greeting"
              }
            ],
            "type": "Node",
            "abstractKey": "__isNode"
          }"#
            )
        );
    }
}
