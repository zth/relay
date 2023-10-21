use std::fmt::Write;

use common::SourceLocationKey;
use graphql_ir::reexport::Intern;
use relay_config::ProjectConfig;
use relay_transforms::Programs;
use relay_typegen::rescript_utils::capitalize_string;
use relay_typegen::rescript_utils::get_safe_key;
use relay_typegen::rescript_utils::print_type_reference;
use schema::SDLSchema;
use schema::Schema;
use schema::TypeReference;

use crate::Artifact;
use crate::config::Config;

pub(crate) fn rescript_generate_extra_artifacts(
    _config: &Config,
    project_config: &ProjectConfig,
    schema: &SDLSchema,
    _programs: &Programs,
    _artifacts: &[Artifact],
) -> Vec<Artifact> {
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
            "@live @unboxed\ntype enum_{}_input = ",
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
                    false
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
                    true
                )
            )
            .unwrap();
        });

        writeln!(content, "}}").unwrap();

        if has_written_initial_input_obj == false {
            has_written_initial_input_obj = true;
        }
    });

    vec![Artifact {
        artifact_source_keys: vec![],
        path: project_config.path_for_artifact(dummy_source_file, "RelaySchemaAssets".intern()),
        source_file: dummy_source_file,
        content: crate::ArtifactContent::Generic {
            content: content.as_bytes().to_vec(),
        },
    }]
}
