use std::path::Path;
use std::sync::Arc;

use clap::Parser;
use common::{ConsoleLogger, Location};
use graphql_ir::FragmentDefinition;
use graphql_ir::Visitor;
use intern::string_key::Intern;
use relay_compiler::ProjectName;
use relay_compiler::get_programs;
use relay_lsp::find_field_usages::get_usages;
use schema::Type;
use schema::Schema;
use serde::Serialize;

use crate::errors::Error;
use crate::{get_config, set_project_flag};

use super::utils::{
    apply_limit,
    ensure_single_project_config,
    print_json_report,
    source_line_for_reference,
    source_location_to_analyze_location,
    AnalyzeLocation,
};

#[derive(Parser)]
#[clap(
    rename_all = "camel_case",
    about = "Find references for schema type/field paths."
)]
pub(crate) struct AnalyzeFindReferencesCommand {
    /// A schema path: either `Type` or `Type.field`.
    payload: String,

    /// Include the full line containing the reference for each match.
    #[clap(long = "with-snippet")]
    with_snippet: bool,

    /// Analyze only this project. You can pass this argument multiple times.
    /// Currently, only single-project configs are supported.
    #[clap(name = "project", long, short)]
    projects: Vec<String>,

    /// Limit the number of matches returned.
    #[clap(long, default_value_t = 100)]
    limit: usize,

    /// Emit JSON output.
    #[clap(long)]
    json: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeFindReferencesReport {
    project: String,
    target_type: String,
    target_field: Option<String>,
    with_snippet: bool,
    matches: Vec<AnalyzeFindReferencesMatch>,
    match_count: usize,
    total_count: usize,
    limit: usize,
    truncated: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeFindReferencesMatch {
    kind: String,
    containing_definition: String,
    location: AnalyzeFindReferencesLocation,
    snippet: Option<String>,
}

type AnalyzeFindReferencesLocation = AnalyzeLocation;

#[derive(Debug)]
struct AnalyzeFindReferenceItem {
    kind: String,
    container: String,
    location: Location,
}

struct AnalyzeFindReferencesPayload {
    type_name: String,
    field_name: Option<String>,
}

pub(crate) async fn handle_analyze_find_references_command(
    command: AnalyzeFindReferencesCommand,
) -> Result<(), Error> {
    let mut config = get_config(None)?;
    let project_name = ensure_single_project_config(&config)?;
    let payload = parse_find_references_payload(&command.payload)?;
    let with_snippet = command.with_snippet;
    let limit = command.limit;
    let json = command.json;
    set_project_flag(&mut config, command.projects)?;

    let (programs_by_project, _, config) = get_programs(config, Arc::new(ConsoleLogger)).await;
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
    analyze_project_find_references(
        project_name,
        program.as_ref(),
        &config.root_dir,
        payload,
        with_snippet,
        limit,
        json,
    )?;
    Ok(())
}

fn parse_find_references_payload(payload: &str) -> Result<AnalyzeFindReferencesPayload, Error> {
    let payload = payload.trim();
    if payload.is_empty() {
        return Err(Error::AnalyzeError {
            details: "A payload is required, e.g. `User` or `User.name`.".to_string(),
        });
    }

    let parts: Vec<&str> = payload.split('.').map(str::trim).collect();
    match parts.as_slice() {
        [] => Err(Error::AnalyzeError {
            details: "A payload is required, e.g. `User` or `User.name`.".to_string(),
        }),
        [type_name] => {
            if type_name.is_empty() {
                return Err(Error::AnalyzeError {
                    details: "Expected a type name, e.g. `User`.".to_string(),
                });
            }
            Ok(AnalyzeFindReferencesPayload {
                type_name: (*type_name).to_string(),
                field_name: None,
            })
        }
        [type_name, field_name] => {
            if type_name.is_empty() || field_name.is_empty() {
                return Err(Error::AnalyzeError {
                    details: "Expected payload in the format `Type` or `Type.field`."
                        .to_string(),
                });
            }
            Ok(AnalyzeFindReferencesPayload {
                type_name: (*type_name).to_string(),
                field_name: Some((*field_name).to_string()),
            })
        }
        _ => Err(Error::AnalyzeError {
            details: "Expected payload in the format `Type` or `Type.field`.".to_string(),
        }),
    }
}

fn analyze_project_find_references(
    project_name: ProjectName,
    programs: &relay_transforms::Programs,
    root_dir: &Path,
    payload: AnalyzeFindReferencesPayload,
    with_snippet: bool,
    limit: usize,
    json: bool,
) -> Result<(), Error> {
    let schema = &programs.source.schema;
    let type_name = payload.type_name.clone();
    let type_name_key = type_name.clone().intern();
    let type_ = schema
        .get_type(type_name_key)
        .ok_or_else(|| Error::AnalyzeError {
            details: format!("Type `{}` was not found in the schema.", type_name),
        })?;

    let mut items = Vec::new();
    if let Some(field_name) = payload.field_name.as_deref() {
        let usages = get_usages(&programs.source, schema, type_name_key, field_name.intern())
            .map_err(|err| Error::AnalyzeError {
                details: format!("Unable to find references: {err:?}"),
            })?;
        for (label, location) in usages {
            items.push(AnalyzeFindReferenceItem {
                kind: "field".to_string(),
                container: normalize_containing_definition(&label),
                location,
            });
        }
    } else {
        items = collect_type_condition_references(programs, type_);
    }

    let mut matches = items
        .into_iter()
        .map(|item| {
            let location = source_location_to_analyze_location(
                root_dir,
                &item.location,
                "find reference location",
            )?;
            let snippet = if with_snippet {
                Some(source_line_for_reference(root_dir, &item.location, "find reference location")?)
            } else {
                None
            };
            Ok(AnalyzeFindReferencesMatch {
                kind: item.kind,
                containing_definition: item.container,
                location,
                snippet,
            })
        })
        .collect::<Result<Vec<_>, Error>>()?;

    matches.sort_by(|a, b| {
        a.location
            .filename
            .cmp(&b.location.filename)
            .then(a.location.start_line.cmp(&b.location.start_line))
            .then(a.location.start_column.cmp(&b.location.start_column))
            .then(a.location.end_line.cmp(&b.location.end_line))
            .then(a.location.end_column.cmp(&b.location.end_column))
            .then(a.containing_definition.cmp(&b.containing_definition))
    });
    let limited_matches = apply_limit(matches, limit);

    let report = AnalyzeFindReferencesReport {
        project: project_name.to_string(),
        target_type: payload.type_name,
        target_field: payload.field_name,
        with_snippet,
        match_count: limited_matches.match_count,
        total_count: limited_matches.total_count,
        limit,
        truncated: limited_matches.truncated,
        matches: limited_matches.entries,
    };

    if json {
        print_json_report(&report)?;
    } else {
        print_analyze_find_references_text_report(&report);
    }
    Ok(())
}

fn collect_type_condition_references(
    programs: &relay_transforms::Programs,
    target_type: Type,
) -> Vec<AnalyzeFindReferenceItem> {
    let mut visitor = TypeReferenceFinder {
        target_type,
        container: None,
        items: Vec::new(),
    };
    visitor.visit_program(&programs.source);
    visitor.items
}

fn normalize_containing_definition(label: &str) -> String {
    label.split(" - ").next().unwrap_or(label).to_string()
}

struct TypeReferenceFinder {
    target_type: Type,
    container: Option<String>,
    items: Vec<AnalyzeFindReferenceItem>,
}

impl TypeReferenceFinder {
    fn push_reference(&mut self, location: Location, kind: &str) {
        if let Some(container) = &self.container {
            self.items.push(AnalyzeFindReferenceItem {
                kind: kind.to_string(),
                container: container.clone(),
                location,
            });
        }
    }
}

impl Visitor for TypeReferenceFinder {
    const NAME: &'static str = "TypeReferenceFinder";
    const VISIT_ARGUMENTS: bool = false;
    const VISIT_DIRECTIVES: bool = false;

    fn visit_operation(&mut self, operation: &graphql_ir::OperationDefinition) {
        let prev_container = self.container.replace(operation.name.item.0.to_string());
        self.default_visit_operation(operation);
        self.container = prev_container;
    }

    fn visit_fragment(&mut self, fragment: &FragmentDefinition) {
        let prev_container = self.container.replace(fragment.name.item.0.to_string());
        if fragment.type_condition == self.target_type {
            self.push_reference(fragment.name.location, "fragment");
        }
        self.default_visit_fragment(fragment);
        self.container = prev_container;
    }

    fn visit_inline_fragment(&mut self, inline_fragment: &graphql_ir::InlineFragment) {
        if let Some(type_condition) = inline_fragment.type_condition {
            if type_condition == self.target_type {
                self.push_reference(inline_fragment.spread_location, "inline-fragment");
            }
        }
        self.default_visit_inline_fragment(inline_fragment);
    }
}

fn print_analyze_find_references_text_report(report: &AnalyzeFindReferencesReport) {
    if report.matches.is_empty() {
        if let Some(target_field) = &report.target_field {
            println!(
                "Project {}: no references found for {}.{}.",
                report.project, report.target_type, target_field
            );
        } else {
            println!(
                "Project {}: no references found for {}.",
                report.project, report.target_type
            );
        }
        return;
    }

    println!(
        "Project {}: {} match(es) found for {}{}.",
        report.project,
        report.match_count,
        report.target_type,
        report
            .target_field
            .as_ref()
            .map(|field| format!(".{}", field))
            .unwrap_or_default()
    );
    if report.truncated {
        println!(
            "  showing {} of {} matches (use --limit to see more).",
            report.match_count, report.total_count
        );
    }
    for reference in &report.matches {
        println!(
            "  {} {} @ {}:{}:{}-{}:{}",
            reference.kind,
            reference.containing_definition,
            reference.location.filename,
            reference.location.start_line,
            reference.location.start_column,
            reference.location.end_line,
            reference.location.end_column
        );
        if let Some(snippet) = &reference.snippet {
            println!("    line: {}", snippet);
        }
    }
}
