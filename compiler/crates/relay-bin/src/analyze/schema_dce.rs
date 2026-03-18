use std::collections::BTreeMap;
use std::collections::HashMap;
use std::collections::HashSet;
use std::sync::Arc;

use clap::Parser;
use graphql_ir::FragmentDefinition;
use intern::Lookup;
use relay_compiler::get_programs;
use relay_compiler::ProjectName;
use serde::Serialize;
use schema::Field;
use schema::FieldID;
use schema::InterfaceID;
use schema::ObjectID;
use schema::SDLSchema;
use schema::Schema;
use schema::Type;

use crate::errors::Error;
use crate::{get_config, set_project_flag};

use super::utils::{apply_limit, ensure_single_project_config, print_json_report};

#[derive(Parser)]
#[clap(rename_all = "camel_case")]
pub(crate) struct AnalyzeSchemaDceCommand {
    /// Analyze only this project.
    /// This exists for compatibility with multi-project Relay configs.
    #[clap(name = "project", long, short)]
    projects: Vec<String>,

    /// Limit the number of types returned.
    #[clap(long, default_value_t = 100)]
    limit: usize,

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
    total_count: usize,
    total_dead_field_count: usize,
    total_dead_union_member_count: usize,
    limit: usize,
    truncated: bool,
}

pub(crate) async fn handle_analyze_schema_dce_command(
    command: AnalyzeSchemaDceCommand,
) -> Result<(), Error> {
    let mut config = get_config(None)?;
    set_project_flag(&mut config, command.projects)?;
    let project_name = ensure_single_project_config(&config)?;
    let limit = command.limit;
    let json = command.json;

    let (programs_by_project, _, _config) = get_programs(config, Arc::new(common::ConsoleLogger)).await;
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
    analyze_project_dead_fields(project_name, program.as_ref(), limit, json)?;
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
    let mut fragments_by_name: HashMap<graphql_ir::FragmentDefinitionName, &FragmentDefinition> =
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

    let mut visited_fragments: HashSet<(graphql_ir::FragmentDefinitionName, Type)> = HashSet::default();
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
    selections: &[graphql_ir::Selection],
    schema: &SDLSchema,
    fragments_by_name: &HashMap<graphql_ir::FragmentDefinitionName, &FragmentDefinition>,
    referenced_types: &mut HashSet<String>,
    referenced_fields: &mut HashSet<FieldID>,
    selection_types: &mut Vec<Type>,
    referenced_union_members: &mut HashMap<String, HashSet<String>>,
    visited_fragments: &mut HashSet<(graphql_ir::FragmentDefinitionName, Type)>,
) {
    for selection in selections {
        match selection {
            graphql_ir::Selection::ScalarField(scalar_field) => {
                referenced_fields.insert(scalar_field.definition.item);
            }
            graphql_ir::Selection::LinkedField(linked_field) => {
                let field = schema.field(linked_field.definition.item);
                let field_type = field.type_.inner();
                if let Type::Union(union_id) = field_type {
                    referenced_types.insert(schema.get_type_name(Type::Union(union_id)).to_string());
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
            graphql_ir::Selection::FragmentSpread(fragment_spread) => {
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
            graphql_ir::Selection::InlineFragment(inline_fragment) => {
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
            graphql_ir::Selection::Condition(condition) => {
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
    if let Type::Union(union_id) = parent_type {
        for object_id in schema.union(union_id).members.iter().copied() {
            if union_member_matches_type_condition(schema, object_id, member_type) {
                referenced_union_members
                    .entry(schema.get_type_name(Type::Union(union_id)).to_string())
                    .or_default()
                    .insert(schema.get_type_name(Type::Object(object_id)).to_string());
            }
        }
    }
}

fn union_member_matches_type_condition(
    schema: &SDLSchema,
    object_id: ObjectID,
    type_condition: Type,
) -> bool {
    match type_condition {
        Type::Object(type_object_id) => type_object_id == object_id,
        Type::Interface(interface_id) => {
            object_implements_interface(schema, object_id, interface_id)
        }
        Type::Union(union_id) => schema.union(union_id).members.contains(&object_id),
        _ => false,
    }
}

fn object_implements_interface(
    schema: &SDLSchema,
    object_id: ObjectID,
    interface_id: InterfaceID,
) -> bool {
    let mut visited_interfaces: HashSet<InterfaceID> = HashSet::default();
    let mut interface_queue = schema.object(object_id).interfaces.clone();

    while let Some(current_interface_id) = interface_queue.pop() {
        if !visited_interfaces.insert(current_interface_id) {
            continue;
        }
        if current_interface_id == interface_id {
            return true;
        }
        interface_queue.extend(
            schema
                .interface(current_interface_id)
                .interfaces
                .iter()
                .copied(),
        );
    }

    false
}

fn propagate_referenced_interface_field_ids(
    schema: &SDLSchema,
    referenced_fields: &mut HashSet<FieldID>,
) {
    let referenced_interface_fields = referenced_fields
        .iter()
        .copied()
        .filter_map(|field_id| {
            let field = schema.field(field_id);
            match field.parent_type {
                Some(Type::Interface(interface_id)) => Some((interface_id, field.name.item)),
                _ => None,
            }
        })
        .collect::<Vec<_>>();

    for (interface_id, field_name) in referenced_interface_fields {
        let mut visited_interfaces: HashSet<InterfaceID> = HashSet::default();
        let mut interface_queue = vec![interface_id];

        while let Some(current_interface_id) = interface_queue.pop() {
            if !visited_interfaces.insert(current_interface_id) {
                continue;
            }

            let interface = schema.interface(current_interface_id);
            if let Some(field_id) = interface.named_field(field_name, schema) {
                referenced_fields.insert(field_id);
            }

            for object_id in interface.implementing_objects.iter().copied() {
                if let Some(field_id) = schema.object(object_id).named_field(field_name, schema) {
                    referenced_fields.insert(field_id);
                }
            }

            interface_queue.extend(interface.implementing_interfaces.iter().copied());
        }
    }
}

fn should_ignore_internal_field(field_name: &str) -> bool {
    field_name == "id" || field_name.starts_with("__")
}

fn analyze_project_dead_fields(
    project_name: ProjectName,
    programs: &relay_transforms::Programs,
    limit: usize,
    json: bool,
) -> Result<(), Error> {
    let report = build_analyze_schema_dce_report(project_name, programs, limit);

    if json {
        print_json_report(&report)?;
    } else {
        print_analyze_schema_dce_text_report(&report)
    }

    Ok(())
}

fn build_analyze_schema_dce_report(
    project_name: ProjectName,
    programs: &relay_transforms::Programs,
    limit: usize,
) -> AnalyzeSchemaDceReport {
    let schema = &programs.source.schema;
    let (mut referenced_fields, mut referenced_types, referenced_union_members) =
        collect_referenced_field_ids_and_types(programs);

    propagate_referenced_interface_field_ids(schema, &mut referenced_fields);

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

    let dead_fields = dead_fields_by_type
        .into_values()
        .map(|mut entry| {
            entry.dead_fields.sort_unstable();
            entry.dead_union_members.sort_unstable();
            entry
        })
        .collect::<Vec<_>>();
    let total_dead_field_count: usize = dead_fields
        .iter()
        .map(|entry| entry.dead_fields.len())
        .sum();
    let total_dead_union_member_count: usize = dead_fields
        .iter()
        .map(|entry| entry.dead_union_members.len())
        .sum();
    let limited_dead_fields = apply_limit(dead_fields, limit);

    let mut report = AnalyzeSchemaDceReport {
        project: project_name.to_string(),
        dead_fields: limited_dead_fields.entries,
        dead_field_count: 0,
        dead_union_member_count: 0,
        total_count: limited_dead_fields.total_count,
        total_dead_field_count,
        total_dead_union_member_count,
        limit,
        truncated: limited_dead_fields.truncated,
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

    report
}

fn print_analyze_schema_dce_text_report(report: &AnalyzeSchemaDceReport) {
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
    println!(
        "  total dead fields in project: {} ({} shown)",
        report.total_dead_field_count,
        report.dead_field_count
    );
    println!(
        "  total unselected union members in project: {} ({} shown)",
        report.total_dead_union_member_count,
        report.dead_union_member_count
    );
    println!(
        "  total dead type count in project: {}",
        report.total_count
    );
    if report.truncated {
        println!(
            "  showing {} of {} types (use --limit to see more).",
            report.dead_fields.len(),
            report.total_count
        );
    }
    for entry in &report.dead_fields {
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

#[cfg(test)]
mod tests {
    use std::sync::Arc;

    use common::SourceLocationKey;
    use graphql_ir::Program;
    use graphql_ir::build;
    use graphql_syntax::parse_executable;
    use intern::string_key::Intern;
    use relay_transforms::Programs;
    use schema::build_schema_with_extensions;

    use super::*;

    fn build_test_programs(schema_text: &str, document_text: &str) -> Programs {
        let schema = Arc::new(
            build_schema_with_extensions::<_, &str>(
                &[(schema_text, SourceLocationKey::standalone("schema.graphql"))],
                &[],
            )
            .unwrap(),
        );
        let document = parse_executable(
            document_text,
            SourceLocationKey::standalone("query.graphql"),
        )
        .unwrap();
        let ir = build(&schema, &document.definitions).unwrap();
        let source = Arc::new(Program::from_definitions(Arc::clone(&schema), ir));

        Programs {
            source: Arc::clone(&source),
            reader: Arc::clone(&source),
            normalization: Arc::clone(&source),
            operation_text: Arc::clone(&source),
            typegen: Arc::clone(&source),
        }
    }

    fn find_type_report<'a>(
        report: &'a AnalyzeSchemaDceReport,
        type_name: &str,
    ) -> &'a AnalyzeSchemaDceTypeReport {
        report
            .dead_fields
            .iter()
            .find(|entry| entry.type_name == type_name)
            .unwrap_or_else(|| panic!("Expected report entry for type '{type_name}'"))
    }

    #[test]
    fn interface_field_usage_marks_implementing_object_fields_live() {
        let programs = build_test_programs(
            r#"
                interface Node {
                    id: ID!
                    name: String
                }

                type User implements Node {
                    id: ID!
                    name: String
                    age: Int
                }

                type Page implements Node {
                    id: ID!
                    name: String
                    title: String
                }

                type Query {
                    node: Node
                }
            "#,
            r#"
                query TestQuery {
                    node {
                        name
                    }
                }
            "#,
        );

        let report =
            build_analyze_schema_dce_report(ProjectName::from("test".intern()), &programs, 100);

        let user = find_type_report(&report, "User");
        assert_eq!(user.dead_fields, vec!["age"]);
        assert!(user.type_referenced);

        let page = find_type_report(&report, "Page");
        assert_eq!(page.dead_fields, vec!["title"]);
        assert!(page.type_referenced);
    }

    #[test]
    fn interface_refinement_marks_matching_union_members_selected() {
        let programs = build_test_programs(
            r#"
                interface Named {
                    name: String
                }

                type User implements Named {
                    name: String
                }

                type Page implements Named {
                    name: String
                }

                type Comment {
                    body: String
                }

                union SearchResult = User | Page | Comment

                type Query {
                    search: [SearchResult]
                }
            "#,
            r#"
                query TestQuery {
                    search {
                        ... on Named {
                            name
                        }
                    }
                }
            "#,
        );

        let report =
            build_analyze_schema_dce_report(ProjectName::from("test".intern()), &programs, 100);

        let search_result = find_type_report(&report, "SearchResult");
        assert_eq!(search_result.dead_union_members, vec!["Comment"]);
        assert!(search_result.type_referenced);
    }
}
