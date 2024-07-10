use common::{ArgumentName, DirectiveName, SourceLocationKey};
use graphql_ir::{Directive, FragmentDefinitionName, OperationDefinition, Selection};
use graphql_ir::Field;
use intern::string_key::{Intern, StringKey};
use lazy_static::lazy_static;
use regex::Regex;
use relay_typegen::{rescript_utils::{capitalize_string, uncapitalize_string}, FragmentLocations};
use schema::{SDLSchema, Schema, Type};
use std::{fmt::Write, ops::RangeTo, path::Path};
use common::NamedItem;

use super::content_section::GenericSection;

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

fn make_path(current_path: &Vec<String>, new_element: String) -> Vec<String> {
    [current_path.clone(), vec![new_element]].concat()
}

fn visit_selections_for_codesplits<'a>(
    selections: &Vec<Selection>,
    schema: &'a SDLSchema,
    current_path: Vec<String>,
    codesplits: &mut Vec<(Vec<String>, Vec<(String, Option<(StringKey, bool)>)>)>,
    fragment_locations: &FragmentLocations,
) -> () {
    selections.iter().for_each(|f| match &f {
        Selection::ScalarField(_field) => (),
        Selection::LinkedField(field) => {
            let next_path = make_path(&current_path, field.alias_or_name(schema).to_string());
            extract_auto_codesplits(&field.directives, fragment_locations, codesplits, &next_path);

            visit_selections_for_codesplits(
                &field.selections,
                &schema,
                next_path,
                codesplits,
                fragment_locations
            );
        }
        Selection::InlineFragment(inline_fragment) => {
            let type_name = match &inline_fragment.type_condition {
                Some(Type::Object(id)) => Some(schema.object(*id).name.item.0),
                Some(Type::Interface(id)) => Some(schema.interface(*id).name.item.0),
                Some(Type::Union(id)) => Some(schema.union(*id).name.item.0),
                _ => None,
            };

            match type_name {
                None => {
                    visit_selections_for_codesplits(
                        &inline_fragment.selections,
                        &schema,
                        current_path.clone(),
                        codesplits,
                        fragment_locations
                    )
                },
                Some(type_name) => {
                    let prefix = match &inline_fragment.type_condition {
                        Some(Type::Interface(_)) => "$$i$$",
                        _ => "$$u$$"
                    };

                    let next_path = make_path(&current_path, format!("{}{}", prefix, type_name.to_string()));

                    extract_auto_codesplits(&inline_fragment.directives, fragment_locations, codesplits, &next_path);

                    visit_selections_for_codesplits(
                        &inline_fragment.selections,
                        &schema,
                        next_path,
                        codesplits,
                        fragment_locations
                    )
                }
            }
        }
        Selection::Condition(condition) => {
            visit_selections_for_codesplits(
                &condition.selections,
                &schema,
                current_path.clone(),
                codesplits,
                fragment_locations
            );
        }
        Selection::FragmentSpread(_fragment_spread) => {
            ()
        },
    });
}

fn extract_auto_codesplits(
    directives: &Vec<Directive>, 
    fragment_locations: &FragmentLocations, 
    codesplits: &mut Vec<(Vec<String>, Vec<(String, Option<(StringKey, bool)>)>)>, 
    next_path: &Vec<String>
) {
    if directives.named(DirectiveName("autoCodesplit".intern())).is_some() {
        let mut fragment_names = vec![];

        directives.iter().for_each(|d| {
            if d.name.item.0 == "autoCodesplit".intern() {
                let argument = d.arguments.iter().find(|a| a.name.item == ArgumentName("fragmentName".intern()));
                if argument.is_none() {
                    log::debug!("was none: {:#?} -> {:#?}", next_path, directives)
                } else {
                    let path_to_file = fragment_locations.0.get(&FragmentDefinitionName(argument.unwrap().value.item.expect_string_literal())).unwrap().source_location().path();
                    let filename = Path::new(path_to_file).file_stem().unwrap().to_str().unwrap().to_string();

                    let variable_condition = d.arguments.iter().find(|a| a.name.item == ArgumentName("variableCondition".intern()));
                    let variable_condition_type = d.arguments.iter().find(|a| a.name.item == ArgumentName("variableConditionIsInclude".intern()));

                    fragment_names.push((capitalize_string(&filename), match (variable_condition, variable_condition_type) {
                        (Some(variable_condition), Some(variable_condition_type)) => Some((variable_condition.value.item.expect_string_literal(), variable_condition_type.value.item.expect_constant().unwrap_boolean())),
                        _ => None,

                    }));
                }
                
            }
        });

        codesplits.push((next_path.clone(), fragment_names))
    }
}

pub fn find_codesplits_in_operation<'a>(
    operation: &OperationDefinition,
    schema: &'a SDLSchema,
    fragment_locations: &FragmentLocations,
) -> Vec<(Vec<String>, Vec<(String, Option<(StringKey, bool)>)>)> {
    let mut codesplits = vec![];
    visit_selections_for_codesplits(
        &operation.selections,
        &schema,
        vec![],
        &mut codesplits,
        &fragment_locations
    );

    codesplits
}

fn visit_selections_for_codesplit_components<'a>(
    selections: &Vec<Selection>,
    schema: &'a SDLSchema,
    codesplits: &mut Vec<String>,
    fragment_locations: &FragmentLocations,
) -> () {
    selections.iter().for_each(|f| match &f {
        Selection::ScalarField(_field) => (),
        Selection::LinkedField(field) => {
            visit_selections_for_codesplit_components(
                &field.selections,
                &schema,
                codesplits,
                fragment_locations
            );
        }
        Selection::InlineFragment(inline_fragment) => {
            visit_selections_for_codesplit_components(
                &inline_fragment.selections,
                &schema,
                codesplits,
                fragment_locations
            )
        }
        Selection::Condition(condition) => {
            visit_selections_for_codesplit_components(
                &condition.selections,
                &schema,
                codesplits,
                fragment_locations
            );
        }
        Selection::FragmentSpread(fragment_spread) => {
            if fragment_spread.directives.named(DirectiveName("autoCodesplit".intern())).is_some() {
                let path_to_file = fragment_locations.0.get(&FragmentDefinitionName(fragment_spread.fragment.item.0)).unwrap().source_location().path();
                let filename = capitalize_string(&Path::new(path_to_file).file_stem().unwrap().to_str().unwrap().to_string());
                if !codesplits.contains(&filename) {
                    codesplits.push(capitalize_string(&filename));
                }
            }
        },
    });
}

pub fn find_codesplit_components_in_operation<'a>(
    selections: &Vec<Selection>,
    schema: &'a SDLSchema,
    fragment_locations: &FragmentLocations,
) -> Vec<String> {
    let mut codesplits = vec![];
    visit_selections_for_codesplit_components(
        &selections,
        &schema,
        &mut codesplits,
        &fragment_locations
    );

    codesplits
}

pub fn write_codesplit_components(codesplit_components: Vec<String>, section: &mut GenericSection) {
    if codesplit_components.len() > 0 {
        writeln!(
            section,
            "\nmodule CodesplitComponents = {{",
        ).unwrap();
        codesplit_components.iter().for_each(|c| {
            writeln!(
                section,
                "  module {} = {{\n    let make = React.lazy_(() => Js.import({}.make))\n  }}",
                c, c
            ).unwrap();
        });
        writeln!(
            section,
            "}}\n",
        ).unwrap();
    }
}

pub fn write_codesplits_node_modifier(codesplits: Vec<(Vec<String>, Vec<(String, Option<(StringKey, bool)>)>)>, section: &mut GenericSection) {
    if codesplits.len() > 0 {
        writeln!(
            section,
            "let node = RescriptRelay_Internal.applyCodesplitMetadata(node, ["
        ).unwrap();

        codesplits.iter().for_each(|(path, modules)| {
            let has_conditionals = modules.iter().find(|(_, c)| c.is_some()).is_some();

            writeln!(
                section,
                "  (\"{}\", ({}variables: dict<Js.Json.t>) => {{{}}}), ",
                path.join("."),
                if has_conditionals {
                    format!("")
                } else {
                    format!("_")
                },
                modules.iter().map(|(m, conditional)| {
                    format!(
                        "{}Js.import({}.make)->ignore{}", 
                        match conditional {
                            Some((s, t)) => format!("if variables->Js.Dict.get(\"{}\") === Some(Js.Json.Boolean({})) {{", s, if *t {
                                "true"
                            } else {
                                "false"
                            }),
                            None => format!("")
                        }, 
                        m,
                        if conditional.is_some() {
                            format!("}}")
                        } else {
                            format!("")
                        }
                    )
                }).collect::<Vec<String>>().join("; ")
            ).unwrap();
        });

        writeln!(
            section,
            "])"
        ).unwrap();
    }
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
