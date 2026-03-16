use std::collections::BTreeMap;
use std::collections::HashMap;
use std::collections::HashSet;
use std::path::PathBuf;
use std::sync::Arc;

use clap::Parser;
use common::ConsoleLogger;
use graphql_ir::FragmentDefinition;
use graphql_ir::FragmentDefinitionName;
use graphql_ir::Selection;
use intern::Lookup;
use relay_compiler::get_programs;
use relay_compiler::ProjectName;
use schema::Field;
use schema::FieldID;
use schema::SDLSchema;
use schema::Schema;
use schema::Type;
use serde::Serialize;

use crate::errors::Error;
use crate::{get_config, set_project_flag};

#[derive(Parser)]
#[clap(rename_all = "snake_case", about = "Schema analysis helpers.")]
pub struct AnalyzeCommand {
    /// Schema analysis commands.
    #[clap(subcommand)]
    command: AnalyzeSubcommand,
}

#[derive(clap::Subcommand)]
enum AnalyzeSubcommand {
    /// Find unused schema fields in Relay operations.
    #[clap(name = "schema-dce")]
    SchemaDce(AnalyzeSchemaDCECommand),
}

#[derive(Parser)]
#[clap(
    rename_all = "camel_case",
    about = "Find unused schema fields in Relay operations."
)]
pub struct AnalyzeSchemaDCECommand {
    /// Analyze only this project. You can pass this argument multiple times.
    /// Currently, only single-project configs are supported.
    #[clap(name = "project", long, short)]
    projects: Vec<String>,

    /// Analyze using this config file. If not provided, searches for a config in
    /// package.json under the `relay` key or `relay.config.json` files among other up
    /// from the current working directory.
    config: Option<PathBuf>,

    /// Emit JSON output.
    #[clap(long)]
    json: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeSchemaDceTypeReport {
    type_name: String,
    type_description: String,
    type_referenced: bool,
    dead_fields: Vec<String>,
    dead_union_members: Vec<String>,
    #[serde(skip)]
    existing_field_count: usize,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeSchemaDceReport {
    project: String,
    dead_fields: Vec<AnalyzeSchemaDceTypeReport>,
    dead_field_count: usize,
    dead_union_member_count: usize,
}

pub async fn handle_analyze_command(command: AnalyzeCommand) -> Result<(), Error> {
    match command.command {
        AnalyzeSubcommand::SchemaDce(command) => {
            handle_analyze_schema_dce_command(command).await
        }
    }
}

fn ensure_single_project_config(config: &relay_compiler::config::Config) -> Result<ProjectName, Error> {
    if config.projects.len() != 1 {
        return Err(Error::AnalyzeError {
            details: "The analyze command currently only supports single-project configurations."
                .into(),
        });
    }

    let project_name = config
        .projects
        .keys()
        .next()
        .cloned()
        .ok_or_else(|| Error::AnalyzeError {
            details: "No project found in config.".into(),
        })?;
    Ok(project_name)
}

async fn handle_analyze_schema_dce_command(
    command: AnalyzeSchemaDCECommand,
) -> Result<(), Error> {
    let mut config = get_config(command.config)?;
    let project_name = ensure_single_project_config(&config)?;
    let json = command.json;
    set_project_flag(&mut config, command.projects)?;

    let (programs_by_project, _, _config) = get_programs(config, Arc::new(ConsoleLogger)).await;
    if programs_by_project.is_empty() {
        return Err(Error::AnalyzeError {
            details: "No programs were produced by analyze.".to_string(),
        });
    }

    let program = programs_by_project
        .get(&project_name)
        .ok_or_else(|| Error::AnalyzeError {
            details: format!("Project {project_name} was not built for analyze."),
        })?;
    analyze_project_dead_fields(project_name, program.as_ref(), json)?;
    Ok(())
}

fn collect_referenced_field_ids_and_types(
    program: &relay_transforms::Programs,
) -> (
    HashSet<FieldID>,
    HashSet<String>,
    HashMap<String, HashSet<String>>,
) {
    let mut referenced_fields = HashSet::default();
    let mut referenced_types: HashSet<String> = HashSet::default();
    let mut referenced_union_members: HashMap<String, HashSet<String>> = HashMap::default();
    let mut fragments_by_name: HashMap<FragmentDefinitionName, &FragmentDefinition> =
        HashMap::default();

    let schema = &program.source.schema;

    for fragment in program.source.fragments() {
        let name = fragment.name.item;
        fragments_by_name.insert(name, fragment);

        referenced_types.insert(schema.get_type_name(fragment.type_condition).to_string());
    }

    for operation in program.source.operations() {
        referenced_types.insert(schema.get_type_name(operation.type_).to_string());
    }

    let mut visited_fragments: HashSet<(FragmentDefinitionName, Type)> = HashSet::default();
    for operation in program.source.operations() {
        let mut selection_types = vec![operation.type_];
        collect_referenced_field_ids_from_selections(
            &operation.selections,
            schema,
            &fragments_by_name,
            &mut referenced_types,
            &mut referenced_fields,
            &mut selection_types,
            &mut referenced_union_members,
            &mut visited_fragments,
        );
    }

    (
        referenced_fields,
        referenced_types,
        referenced_union_members,
    )
}

fn collect_referenced_field_ids_from_selections(
    selections: &[Selection],
    schema: &SDLSchema,
    fragments_by_name: &HashMap<FragmentDefinitionName, &FragmentDefinition>,
    referenced_types: &mut HashSet<String>,
    referenced_fields: &mut HashSet<FieldID>,
    selection_types: &mut Vec<Type>,
    referenced_union_members: &mut HashMap<String, HashSet<String>>,
    visited_fragments: &mut HashSet<(FragmentDefinitionName, Type)>,
) {
    for selection in selections {
        match selection {
            Selection::ScalarField(scalar_field) => {
                referenced_fields.insert(scalar_field.definition.item);
            }
            Selection::LinkedField(linked_field) => {
                let field = schema.field(linked_field.definition.item);
                let field_type = field.type_.inner();
                if let Type::Union(union_id) = field_type {
                    referenced_types
                        .insert(schema.get_type_name(Type::Union(union_id)).to_string());
                }
                referenced_fields.insert(linked_field.definition.item);
                selection_types.push(field_type);
                collect_referenced_field_ids_from_selections(
                    &linked_field.selections,
                    schema,
                    fragments_by_name,
                    referenced_types,
                    referenced_fields,
                    selection_types,
                    referenced_union_members,
                    visited_fragments,
                );
                selection_types.pop();
            }
            Selection::FragmentSpread(fragment_spread) => {
                let fragment_name = fragment_spread.fragment.item;
                if let Some(fragment) = fragments_by_name.get(&fragment_name) {
                    let parent_type = selection_types.last().copied();
                    let type_condition = fragment.type_condition;
                    referenced_types.insert(schema.get_type_name(type_condition).to_string());
                    if let Some(parent_type) = parent_type {
                        mark_referenced_union_member(
                            schema,
                            parent_type,
                            type_condition,
                            referenced_union_members,
                        );
                    }
                    let key = (fragment_name, parent_type.unwrap_or_else(|| type_condition));
                    if visited_fragments.insert(key) {
                        selection_types.push(type_condition);
                        collect_referenced_field_ids_from_selections(
                            &fragment.selections,
                            schema,
                            fragments_by_name,
                            referenced_types,
                            referenced_fields,
                            selection_types,
                            referenced_union_members,
                            visited_fragments,
                        );
                        selection_types.pop();
                    }
                }
            }
            Selection::InlineFragment(inline_fragment) => {
                if let Some(type_condition) = inline_fragment.type_condition {
                    referenced_types.insert(schema.get_type_name(type_condition).to_string());
                    if let Some(parent_type) = selection_types.last().copied() {
                        mark_referenced_union_member(
                            schema,
                            parent_type,
                            type_condition,
                            referenced_union_members,
                        );
                    }
                    selection_types.push(type_condition);
                    collect_referenced_field_ids_from_selections(
                        &inline_fragment.selections,
                        schema,
                        fragments_by_name,
                        referenced_types,
                        referenced_fields,
                        selection_types,
                        referenced_union_members,
                        visited_fragments,
                    );
                    selection_types.pop();
                } else {
                    collect_referenced_field_ids_from_selections(
                        &inline_fragment.selections,
                        schema,
                        fragments_by_name,
                        referenced_types,
                        referenced_fields,
                        selection_types,
                        referenced_union_members,
                        visited_fragments,
                    );
                }
            }
            Selection::Condition(condition) => {
                collect_referenced_field_ids_from_selections(
                    &condition.selections,
                    schema,
                    fragments_by_name,
                    referenced_types,
                    referenced_fields,
                    selection_types,
                    referenced_union_members,
                    visited_fragments,
                );
            }
        }
    }
}

fn mark_referenced_union_member(
    schema: &SDLSchema,
    parent_type: Type,
    member_type: Type,
    referenced_union_members: &mut HashMap<String, HashSet<String>>,
) {
    match (parent_type, member_type) {
        (Type::Union(union_id), Type::Object(object_id)) => {
            if schema.union(union_id).members.contains(&object_id) {
                referenced_union_members
                    .entry(schema.get_type_name(Type::Union(union_id)).to_string())
                    .or_default()
                    .insert(schema.get_type_name(Type::Object(object_id)).to_string());
            }
        }
        _ => {}
    }
}

fn should_ignore_internal_field(field_name: &str) -> bool {
    field_name == "id" || field_name.starts_with("__")
}

fn analyze_project_dead_fields(
    project_name: ProjectName,
    programs: &relay_transforms::Programs,
    json: bool,
) -> Result<(), Error> {
    let (referenced_fields, mut referenced_types, referenced_union_members) =
        collect_referenced_field_ids_and_types(programs);
    let schema = &programs.source.schema;

    for field_id in referenced_fields.iter() {
        let field = schema.field(*field_id);
        if let Some(parent_type) = field.parent_type {
            referenced_types.insert(schema.get_type_name(parent_type).to_string());
        }
    }

    let mut dead_fields_by_type: BTreeMap<String, AnalyzeSchemaDceTypeReport> = BTreeMap::new();

    for object in schema.objects() {
        let type_name = object.name.item.lookup().to_string();
        let type_description = if object.is_extension {
            "schema extension object".to_owned()
        } else {
            "object".to_owned()
        };
        let mut dead_fields: Vec<String> = Vec::new();
        let mut existing_field_count = 0usize;
        let dead_union_members: Vec<String> = Vec::new();
        let type_referenced = referenced_types.contains(&type_name);

        for field_id in &object.fields {
            let field: &Field = schema.field(*field_id);
            let field_name = field.name.item.lookup().to_string();
            if should_ignore_internal_field(&field_name) {
                continue;
            }
            if let Some(parent_type) = field.parent_type {
                existing_field_count += 1;
                debug_assert_eq!(
                    schema.get_type_name(parent_type).lookup().to_string(),
                    type_name
                );
                if referenced_fields.contains(field_id) {
                    continue;
                }
                dead_fields.push(field_name);
            }
        }

        if !dead_fields.is_empty() || !type_referenced {
            dead_fields_by_type.insert(
                type_name.to_string(),
                AnalyzeSchemaDceTypeReport {
                    type_name: type_name.to_string(),
                    type_referenced,
                    type_description: type_description.to_string(),
                    dead_fields,
                    dead_union_members,
                    existing_field_count,
                },
            );
        }
    }

    for interface in schema.interfaces() {
        let type_name = interface.name.item.lookup().to_string();
        let type_description = if interface.is_extension {
            "schema extension interface".to_owned()
        } else {
            "interface".to_owned()
        };
        let mut dead_fields: Vec<String> = Vec::new();
        let mut existing_field_count = 0usize;
        let dead_union_members: Vec<String> = Vec::new();
        let type_referenced = referenced_types.contains(&type_name);

        for field_id in &interface.fields {
            let field: &Field = schema.field(*field_id);
            let field_name = field.name.item.lookup().to_string();
            if should_ignore_internal_field(&field_name) {
                continue;
            }
            if let Some(parent_type) = field.parent_type {
                existing_field_count += 1;
                if referenced_fields.contains(field_id) {
                    continue;
                }
                debug_assert_eq!(
                    schema.get_type_name(parent_type).lookup().to_string(),
                    type_name
                );
                dead_fields.push(field_name);
            }
        }

        if !dead_fields.is_empty() || !type_referenced {
            dead_fields_by_type.insert(
                type_name.to_string(),
                AnalyzeSchemaDceTypeReport {
                    type_name: type_name.to_string(),
                    type_referenced,
                    type_description: type_description.to_string(),
                    dead_fields,
                    dead_union_members,
                    existing_field_count,
                },
            );
        }
    }

    for union in schema.unions() {
        let type_name = union.name.item.lookup().to_string();
        let type_description = if union.is_extension {
            "schema extension union".to_owned()
        } else {
            "union".to_owned()
        };
        let selected_members = referenced_union_members
            .get(&type_name)
            .cloned()
            .unwrap_or_default();
        let mut dead_union_members: Vec<String> = union
            .members
            .iter()
            .map(|member_id| schema.get_type_name(Type::Object(*member_id)).to_string())
            .filter(|member_name| !selected_members.contains(member_name))
            .collect();
        let type_referenced = referenced_types.contains(&type_name);

        if !dead_union_members.is_empty() || !type_referenced {
            dead_union_members.sort_unstable();
            dead_fields_by_type.insert(
                type_name.to_string(),
                AnalyzeSchemaDceTypeReport {
                    type_name: type_name.to_string(),
                    type_referenced,
                    type_description: type_description.to_string(),
                    dead_fields: Vec::new(),
                    dead_union_members,
                    existing_field_count: 0,
                },
            );
        }
    }

    let mut report = AnalyzeSchemaDceReport {
        project: project_name.to_string(),
        dead_fields: dead_fields_by_type
            .into_values()
            .map(|mut entry| {
                entry.dead_fields.sort_unstable();
                entry.dead_union_members.sort_unstable();
                entry
            })
            .collect(),
        dead_field_count: 0,
        dead_union_member_count: 0,
    };

    report.dead_field_count = report
        .dead_fields
        .iter()
        .map(|entry| entry.dead_fields.len())
        .sum();
    report.dead_union_member_count = report
        .dead_fields
        .iter()
        .map(|entry| entry.dead_union_members.len())
        .sum();

    if json {
        let json_output =
            serde_json::to_string_pretty(&report).map_err(|err| Error::AnalyzeError {
                details: format!("Unable to serialize analyze output: {err}"),
            })?;
        println!("{}", json_output);
    } else {
        print_analyze_schema_dce_text_report(report)
    }

    Ok(())
}

fn print_analyze_schema_dce_text_report(report: AnalyzeSchemaDceReport) {
    if report.dead_fields.is_empty() {
        println!(
            "Project {}: no dead schema fields or union members found",
            report.project
        );
        return;
    }

    println!(
        "Project {}: dead schema items by type ({} dead field(s), {} unselected union member(s), {} dead type(s))",
        report.project,
        report.dead_field_count,
        report.dead_union_member_count,
        report.dead_fields.len()
    );
    for entry in report.dead_fields {
        if entry.type_referenced {
            println!("  {} ({})", entry.type_name, entry.type_description);
        } else {
            println!(
                "  {} ({}): not referenced by any operation",
                entry.type_name, entry.type_description
            );
        }

        if entry.type_referenced && !entry.dead_fields.is_empty() {
            println!(
                "    Dead fields ({}/{}):",
                entry.dead_fields.len(),
                entry.existing_field_count
            );
            for field in &entry.dead_fields {
                println!("      {field}");
            }
        }

        if entry.type_referenced && !entry.dead_union_members.is_empty() {
            println!("    Unselected union members:");
            for member in &entry.dead_union_members {
                println!("      {member}");
            }
        }
    }
}
