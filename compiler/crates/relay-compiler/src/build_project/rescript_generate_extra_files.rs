use std::fmt::Write;

use common::SourceLocationKey;
use graphql_ir::reexport::Intern;
use relay_config::ProjectConfig;
use relay_transforms::Programs;
use relay_transforms::is_operation_preloadable;
use relay_typegen::rescript::NullabilityMode;
use relay_typegen::rescript_utils::capitalize_string;
use relay_typegen::rescript_utils::get_safe_key;
use relay_typegen::rescript_utils::print_type_reference;
use schema::SDLSchema;
use schema::Schema;
use schema::TypeReference;

use crate::Artifact;
use crate::ArtifactContent;
use crate::build_project::generate_preloadable_query_parameters_artifact;
use crate::config::Config;

pub(crate) fn rescript_generate_extra_artifacts(
    _config: &Config,
    project_config: &ProjectConfig,
    schema: &SDLSchema,
    _programs: &Programs,
    artifacts: &[Artifact],
) -> Vec<Artifact> {
    // Preloaded operations
    let mut extra_artifacts: Vec<Artifact> = artifacts
    .iter()
    .map(|artifact| match &artifact.content {
        ArtifactContent::Operation {
            normalization_operation,
            typegen_operation,
            id_and_text_hash,
            ..
        } => {
            if !is_operation_preloadable(&normalization_operation) {
                return None;
            }

            Some(generate_preloadable_query_parameters_artifact(
                project_config,
                typegen_operation,
                normalization_operation,
                id_and_text_hash,
                artifact.artifact_source_keys.clone(),
                artifact.source_file,
            ))
        }
        _ => None,
    })
    .filter_map(|artifact| artifact)
    .collect();

    let dummy_source_file = SourceLocationKey::Generated;

    let mut content = String::from("/* @generated */\n@@warning(\"-30\")\n\n");

    // Write all enums
    schema.enums().for_each(|e| {
        if let Some(desc) = e.description {
            writeln!(content, "/** {} */", desc).unwrap();
        }

        writeln!(content, "@live @unboxed\ntype enum_{} = ", e.name.item).unwrap();
        e.values.iter().for_each(|v| {
            let capitalized = capitalize_string(&v.value.to_string()).intern();
            if capitalized == v.value {
                writeln!(content, "  | {}", v.value).unwrap();
            } else {
                writeln!(content, "  | @as(\"{}\") {}", v.value, capitalized).unwrap();
            }
        });
        writeln!(content, "  | FutureAddedValue(string)").unwrap();
        writeln!(content, "\n").unwrap();

        if let Some(desc) = e.description {
            writeln!(content, "/** {} */", desc).unwrap();
        }
        writeln!(
            content,
            "@live{}\ntype enum_{}_input = ",
            if e.values.len() > 1 {
                " @unboxed"
            } else {
                ""
            },
            e.name.item
        )
        .unwrap();
        e.values.iter().for_each(|v| {
            let capitalized = capitalize_string(&v.value.to_string()).intern();
            if capitalized == v.value {
                writeln!(content, "  | {}", v.value).unwrap();
            } else {
                writeln!(content, "  | @as(\"{}\") {}", v.value, capitalized).unwrap();
            }
        });
        writeln!(content, "\n").unwrap();
    });

    // Write the input object types
    let mut has_written_initial_input_obj = false;
    schema.input_objects().for_each(|input_obj| {
        // Write the regular types
        if let Some(desc) = input_obj.description {
            writeln!(content, "/** {} */", desc).unwrap();
        }

        let is_input_union = input_obj.directives.iter().find(|directive| {
            directive.name.0.eq(&"oneOf".intern())
        }).is_some();

        if is_input_union {
            // The non-nullable version
            writeln!(
                content,
                "{} input_{} = ",
                if has_written_initial_input_obj {
                    "\n@live\n@tag(\"__$inputUnion\")\nand"
                } else {
                    "@live\n@tag(\"__$inputUnion\")\ntype rec"
                },
                input_obj.name.item
            )
            .unwrap();

            input_obj.fields.iter().for_each(|field| {
                writeln!(
                    content, 
                    "| @as(\"{}\") {}({})", 
                    field.name.0, 
                    capitalize_string(&field.name.0.to_string()),
                    print_type_reference(
                        &field.type_,
                        &schema,
                        &project_config.typegen_config.custom_scalar_types,
                        false,
                        false,
                        &NullabilityMode::Option,
                        true
                    )
                ).unwrap();
            });

            // And the nullable version
            writeln!(
                content,
                "{} input_{}_nullable = ",
                if has_written_initial_input_obj {
                    "\n@live\n@tag(\"__$inputUnion\")\nand"
                } else {
                    "@live\n@tag(\"__$inputUnion\")\ntype rec"
                },
                input_obj.name.item
            )
            .unwrap();

            input_obj.fields.iter().for_each(|field| {
                writeln!(
                    content, 
                    "| @as(\"{}\") {}({})", 
                    field.name.0, 
                    capitalize_string(&field.name.0.to_string()),
                    print_type_reference(
                        &field.type_,
                        &schema,
                        &project_config.typegen_config.custom_scalar_types,
                        false,
                        false,
                        &NullabilityMode::Nullable,
                        true
                    )
                ).unwrap();
            });

        } else {       

            writeln!(
                content,
                "{} input_{} = {{",
                if has_written_initial_input_obj {
                    "\n@live\nand"
                } else {
                    "@live\ntype rec"
                },
                input_obj.name.item
            )
            .unwrap();

            input_obj.fields.iter().for_each(|field| {
                let (key, maybe_original_key) = get_safe_key(&field.name.to_string());

                writeln!(
                    content,
                    "  {}{}{}: {},",
                    (match maybe_original_key {
                        Some(original_key) => format!("@as(\"{}\") ", original_key),
                        None => String::from(""),
                    }),
                    key,
                    match &field.type_ {
                        &TypeReference::NonNull(_) => "",
                        _ => "?",
                    },
                    print_type_reference(
                        &field.type_,
                        &schema,
                        &project_config.typegen_config.custom_scalar_types,
                        false,
                        false,
                        &NullabilityMode::Option,
                        true
                        
                    )
                )
                .unwrap();
            });

            writeln!(content, "}}").unwrap();

            if has_written_initial_input_obj == false {
                has_written_initial_input_obj = true;
            }

            // Write the nullable type
            if let Some(desc) = input_obj.description {
                writeln!(content, "/** {} */", desc).unwrap();
            }

            writeln!(
                content,
                "{} input_{}_nullable = {{",
                if has_written_initial_input_obj {
                    "\n@live\nand"
                } else {
                    "@live\ntype rec"
                },
                input_obj.name.item
            )
            .unwrap();

            input_obj.fields.iter().for_each(|field| {
                let (key, maybe_original_key) = get_safe_key(&field.name.to_string());

                let is_nullable = match &field.type_ {
                    TypeReference::NonNull(_) => false,
                    _ => true,
                };

                writeln!(
                    content,
                    "  {}{}{}: {},",
                    (match maybe_original_key {
                        Some(original_key) => format!("@as(\"{}\") ", original_key),
                        None => String::from(""),
                    }),
                    key,
                    if is_nullable { "?" } else { "" },
                    print_type_reference(
                        &field.type_,
                        &schema,
                        &project_config.typegen_config.custom_scalar_types,
                        true,
                        false,
                        &NullabilityMode::Nullable,
                        true
                    )
                )
                .unwrap();
            });

            writeln!(content, "}}").unwrap();

            if has_written_initial_input_obj == false {
                has_written_initial_input_obj = true;
            }
    }
    });

    let schema_assets_artifact = Artifact {
        artifact_source_keys: vec![],
        path: project_config.path_for_artifact(dummy_source_file, "RelaySchemaAssets".intern()),
        source_file: dummy_source_file,
        content: crate::ArtifactContent::Generic {
            content: content.as_bytes().to_vec(),
        },
    };

    extra_artifacts.push(schema_assets_artifact);

    extra_artifacts
}
