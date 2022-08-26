use std::fmt::Write;

use common::SourceLocationKey;
use graphql_ir::reexport::Intern;
use relay_config::ProjectConfig;
use relay_transforms::Programs;
use relay_typegen::rescript_utils::{get_safe_key, print_type_reference};
use schema::{SDLSchema, Schema};

use crate::{path_for_artifact, Artifact};

pub(crate) fn rescript_generate_extra_artifacts(
    project_config: &ProjectConfig,
    schema: &SDLSchema,
    _programs: &Programs,
    _artifacts: &[Artifact],
) -> Vec<Artifact> {
    let dummy_source_file = SourceLocationKey::Generated;

    let mut content = String::from("/* @generated */\n");

    // Write the input object types
    let mut has_written_initial_input_obj = false;
    schema.input_objects().for_each(|input_obj| {
        if let Some(desc) = input_obj.description {
            writeln!(content, "/** {} */", desc).unwrap();
        }

        writeln!(
            content,
            "{} input_{} = {{",
            if has_written_initial_input_obj {
                "and"
            } else {
                "type"
            },
            input_obj.name.item
        )
        .unwrap();

        input_obj.fields.iter().for_each(|field| {
            let (key, maybe_original_key) = get_safe_key(&field.name.to_string());

            writeln!(
                content,
                "  {}{}: {},",
                (match maybe_original_key {
                    Some(original_key) => format!("@as(\"{}\") ", original_key),
                    None => String::from(""),
                }),
                key,
                print_type_reference(&field.type_, &schema)
            )
            .unwrap();
        });

        writeln!(content, "}}").unwrap();

        if has_written_initial_input_obj == false {
            has_written_initial_input_obj = true;
        }
    });

    // Write object makers
    schema.input_objects().for_each(|input_obj| {
        writeln!(content, "@obj external make_{}: (", input_obj.name.item).unwrap();

        input_obj.fields.iter().for_each(|field| {
            let (key, maybe_original_key) = get_safe_key(&field.name.to_string());

            writeln!(
                content,
                "  ~{}: {},",
                (match maybe_original_key {
                    Some(original_key) => format!("_{}", original_key),
                    None => key,
                }),
                print_type_reference(&field.type_, &schema)
            )
            .unwrap();
        });

        writeln!(content, ") => input_{} = \"\"", input_obj.name.item).unwrap();
    });

    vec![Artifact {
        source_definition_names: vec![],
        path: path_for_artifact(
            project_config,
            dummy_source_file,
            "RelaySchemaAssets".intern(),
        ),
        source_file: dummy_source_file,
        content: crate::ArtifactContent::Generic {
            content: content.as_bytes().to_vec(),
        },
    }]
}
