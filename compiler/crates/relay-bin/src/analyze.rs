use std::collections::BTreeMap;
use std::collections::HashMap;
use std::collections::HashSet;
use std::path::Path;
use std::path::PathBuf;
use std::cmp::{max, min};
use std::sync::Arc;

use clap::Parser;
use common::{ConsoleLogger, Location};
use graphql_ir::OperationDefinitionName;
use graphql_ir::FragmentDefinition;
use graphql_ir::FragmentDefinitionName;
use graphql_ir::Selection;
use graphql_ir::Visitor;
use intern::Lookup;
use intern::string_key::Intern;
use graphql_text_printer::print_full_operation;
use relay_compiler::get_programs;
use relay_compiler::source_for_location;
use relay_compiler::ProjectName;
use relay_compiler::FsSourceReader;
use relay_lsp::find_field_usages::get_usages;
use common::Span;
use schema::Field;
use schema::FieldID;
use schema::SDLSchema;
use schema::Schema;
use schema::Type;
use relay_transforms::apply_transforms;
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
    /// Find references for a schema path.
    #[clap(name = "find-references")]
    FindReferences(AnalyzeFindReferencesCommand),

    /// Print the full text for a named GraphQL operation.
    #[clap(name = "print-operation")]
    PrintOperation(AnalyzePrintOperationCommand),

    /// Find unused schema fields in Relay operations.
    #[clap(name = "schema-dce")]
    SchemaDce(AnalyzeSchemaDCECommand),

    /// Find operations/fragments by selection size/depth.
    #[clap(name = "executable-definitions")]
    ExecutableDefinitions(AnalyzeExecutableDefinitionsCommand),
}

#[derive(Parser)]
#[clap(
    rename_all = "camel_case",
    about = "Find references for schema type/field paths."
)]
pub struct AnalyzeFindReferencesCommand {
    /// A schema path: either `Type` or `Type.field`.
    payload: String,

    /// Include the full line containing the reference for each match.
    #[clap(long = "with-snippet")]
    with_snippet: bool,

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

#[derive(Parser)]
#[clap(
    rename_all = "camel_case",
    about = "Print the full text for a named GraphQL operation."
)]
pub struct AnalyzePrintOperationCommand {
    /// The name of the operation to print.
    operation: String,

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

#[derive(Parser)]
#[clap(
    rename_all = "camel_case",
    about = "Find operations and fragments by selection size/depth."
)]
pub struct AnalyzeExecutableDefinitionsCommand {
    /// Analyze only this project. You can pass this argument multiple times.
    /// Currently, only single-project configs are supported.
    #[clap(name = "project", long, short)]
    projects: Vec<String>,

    /// Analyze using this config file. If not provided, searches for a config in
    /// package.json under the `relay` key or `relay.config.json` files among other up
    /// from the current working directory.
    config: Option<PathBuf>,

    /// Minimum number of line breaks covered by selections.
    #[clap(long = "min-selection-lines")]
    min_selection_lines: Option<usize>,

    /// Minimum depth of selection nesting.
    #[clap(long = "min-selection-depth")]
    min_selection_depth: Option<usize>,

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

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeExecutableDefinitionsReport {
    project: String,
    min_selection_lines: Option<usize>,
    min_selection_depth: Option<usize>,
    total_operations: usize,
    total_fragments: usize,
    matches: Vec<AnalyzeExecutableDefinitionMatch>,
    match_count: usize,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeExecutableDefinitionMatch {
    kind: String,
    name: String,
    location: AnalyzeExecutableDefinitionLocation,
    selection_lines: usize,
    selection_depth: usize,
    violations: Vec<String>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeExecutableDefinitionLocation {
    filename: String,
    start_line: u32,
    start_column: u32,
    end_line: u32,
    end_column: u32,
}

pub async fn handle_analyze_command(command: AnalyzeCommand) -> Result<(), Error> {
    match command.command {
        AnalyzeSubcommand::FindReferences(command) => {
            handle_analyze_find_references_command(command).await
        }
        AnalyzeSubcommand::PrintOperation(command) => {
            handle_analyze_print_operation_command(command).await
        }
        AnalyzeSubcommand::SchemaDce(command) => {
            handle_analyze_schema_dce_command(command).await
        }
        AnalyzeSubcommand::ExecutableDefinitions(command) => {
            handle_analyze_executable_definitions_command(command).await
        }
    }
}

async fn handle_analyze_find_references_command(
    command: AnalyzeFindReferencesCommand,
) -> Result<(), Error> {
    let mut config = get_config(command.config)?;
    let project_name = ensure_single_project_config(&config)?;
    let payload = parse_find_references_payload(&command.payload)?;
    let with_snippet = command.with_snippet;
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
        json,
    )?;
    Ok(())
}

async fn handle_analyze_print_operation_command(
    command: AnalyzePrintOperationCommand,
) -> Result<(), Error> {
    let mut config = get_config(command.config)?;
    let project_name = ensure_single_project_config(&config)?;
    let operation_name = command.operation;
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
    analyze_project_print_operation(
        project_name,
        program.as_ref(),
        &config,
        operation_name,
        json,
    )?;
    Ok(())
}

#[derive(Debug)]
struct AnalyzeFindReferencesPayload {
    type_name: String,
    field_name: Option<String>,
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

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeFindReferencesReport {
    project: String,
    target_type: String,
    target_field: Option<String>,
    with_snippet: bool,
    matches: Vec<AnalyzeFindReferencesMatch>,
    match_count: usize,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeFindReferencesMatch {
    kind: String,
    containing_definition: String,
    location: AnalyzeFindReferencesLocation,
    snippet: Option<String>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeFindReferencesLocation {
    filename: String,
    start_line: u32,
    start_column: u32,
    end_line: u32,
    end_column: u32,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzePrintOperationReport {
    project: String,
    operation_name: String,
    operation_text: String,
}

#[derive(Debug)]
struct AnalyzeFindReferenceItem {
    kind: String,
    container: String,
    location: Location,
}

fn analyze_project_find_references(
    project_name: ProjectName,
    programs: &relay_transforms::Programs,
    root_dir: &Path,
    payload: AnalyzeFindReferencesPayload,
    with_snippet: bool,
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
            let location = location_from_reference(root_dir, &item.location)?;
            let snippet = if with_snippet {
                Some(reference_line_snippet(root_dir, &item.location)?)
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

    let report = AnalyzeFindReferencesReport {
        project: project_name.to_string(),
        target_type: payload.type_name,
        target_field: payload.field_name,
        with_snippet,
        match_count: matches.len(),
        matches,
    };

    if json {
        let json_output =
            serde_json::to_string_pretty(&report).map_err(|err| Error::AnalyzeError {
                details: format!("Unable to serialize analyze output: {err}"),
            })?;
        println!("{}", json_output);
    } else {
        print_analyze_find_references_text_report(&report);
    }
    Ok(())
}

fn analyze_project_print_operation(
    project_name: ProjectName,
    programs: &relay_transforms::Programs,
    config: &relay_compiler::config::Config,
    operation_name: String,
    json: bool,
) -> Result<(), Error> {
    let operation_name = OperationDefinitionName(operation_name.clone().intern());
    let operation = programs
        .source
        .operation(operation_name)
        .ok_or_else(|| Error::AnalyzeError {
            details: format!(
                "Operation `{}` was not found in source documents.",
                operation_name
            ),
        })?;

    let project_config = config
        .enabled_projects()
        .find(|project_config| project_config.name == project_name)
        .ok_or_else(|| Error::AnalyzeError {
            details: format!("Unable to get project config for project {project_name}."),
        })?;

    let operation_only_program = get_operation_only_program(Arc::clone(&operation), vec![], &programs.source);
    let transformed_programs = apply_transforms(
        project_config,
        Arc::new(operation_only_program),
        Default::default(),
        Arc::new(ConsoleLogger),
        None,
        config.custom_transforms.as_ref(),
        config.transferrable_refetchable_query_directives.clone(),
    )
    .map_err(|errors| Error::AnalyzeError {
        details: format!(
            "Unable to run transforms for operation `{}`: {errors:?}",
            operation_name
        ),
    })?;

    let operation_to_print = transformed_programs
        .operation_text
        .operation(operation_name)
        .ok_or_else(|| Error::AnalyzeError {
            details: format!(
                "Unable to print operation `{}` after transforms.",
                operation_name
            ),
        })?;

    let report = AnalyzePrintOperationReport {
        project: project_name.to_string(),
        operation_name: operation_name.to_string(),
        operation_text: print_full_operation(
            &transformed_programs.operation_text,
            operation_to_print,
            Default::default(),
        ),
    };

    if json {
        let json_output =
            serde_json::to_string_pretty(&report).map_err(|err| Error::AnalyzeError {
                details: format!("Unable to serialize analyze output: {err}"),
            })?;
        println!("{}", json_output);
    } else {
        print_analyze_print_operation_text_report(&report);
    }
    Ok(())
}

fn get_operation_only_program(
    operation: std::sync::Arc<graphql_ir::OperationDefinition>,
    fragments: Vec<std::sync::Arc<FragmentDefinition>>,
    program: &graphql_ir::Program,
) -> graphql_ir::Program {
    use std::collections::HashSet;

    let mut selections_to_visit: Vec<&[graphql_ir::Selection]> = vec![&operation.selections];
    let mut next_program = graphql_ir::Program::new(program.schema.clone());
    let mut visited_fragments: HashSet<graphql_ir::FragmentDefinitionName> = HashSet::default();

    next_program.insert_operation(Arc::clone(&operation));
    for fragment in fragments.iter() {
        selections_to_visit.push(&fragment.selections);
        next_program.insert_fragment(Arc::clone(fragment));
    }

    while let Some(current_selections) = selections_to_visit.pop() {
        for selection in current_selections {
            match selection {
                graphql_ir::Selection::FragmentSpread(spread) => {
                    if visited_fragments.contains(&spread.fragment.item) {
                        continue;
                    }
                    visited_fragments.insert(spread.fragment.item);
                    if let Some(fragment) = program.fragment(spread.fragment.item) {
                        selections_to_visit.push(&fragment.selections);
                        next_program.insert_fragment(Arc::clone(&fragment));
                    }
                }
                graphql_ir::Selection::Condition(condition) => {
                    selections_to_visit.push(&condition.selections);
                }
                graphql_ir::Selection::LinkedField(linked_field) => {
                    selections_to_visit.push(&linked_field.selections);
                }
                graphql_ir::Selection::InlineFragment(inline_fragment) => {
                    selections_to_visit.push(&inline_fragment.selections);
                }
                graphql_ir::Selection::ScalarField(_) => {}
            }
        }
    }

    next_program
}

fn print_analyze_print_operation_text_report(report: &AnalyzePrintOperationReport) {
    println!("Project {}: operation {}.", report.project, report.operation_name);
    println!("{}", report.operation_text);
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

fn location_from_reference(
    root_dir: &Path,
    location: &Location,
) -> Result<AnalyzeFindReferencesLocation, Error> {
    let source_location = location.source_location();
    let source = source_for_location(root_dir, source_location, &FsSourceReader)
        .ok_or_else(|| Error::AnalyzeError {
            details: format!(
                "Unable to load source location '{}' for reference.",
                source_location.path()
            ),
        })?;
    let source_text = source.text_source();
    let range = source_text.to_span_range(location.span());

    Ok(AnalyzeFindReferencesLocation {
        filename: source_location.path().to_string(),
        start_line: range.start.line + 1,
        start_column: range.start.character + 1,
        end_line: range.end.line + 1,
        end_column: range.end.character + 1,
    })
}

fn reference_line_snippet(root_dir: &Path, location: &Location) -> Result<String, Error> {
    let source_location = location.source_location();
    let source = source_for_location(root_dir, source_location, &FsSourceReader)
        .ok_or_else(|| Error::AnalyzeError {
            details: format!(
                "Unable to load source location '{}' for snippet lookup.",
                source_location.path()
            ),
        })?;
    let text_source = source.text_source();
    let range = text_source.to_span_range(location.span());
    let local_line = range
        .start
        .line
        .checked_sub(text_source.line_index as u32)
        .ok_or_else(|| Error::AnalyzeError {
            details: format!("Unable to resolve snippet line for {}.", source_location.path()),
        })?;
    text_source
        .text
        .lines()
        .nth(local_line as usize)
        .map(|line| line.to_string())
        .ok_or_else(|| Error::AnalyzeError {
            details: format!(
                "Unable to resolve snippet line for {}:{}.",
                source_location.path(),
                range.start.line + 1
            ),
        })
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

async fn handle_analyze_executable_definitions_command(
    command: AnalyzeExecutableDefinitionsCommand,
) -> Result<(), Error> {
    let mut config = get_config(command.config)?;
    let project_name = ensure_single_project_config(&config)?;
    set_project_flag(&mut config, command.projects)?;

    if command.min_selection_lines.is_none() && command.min_selection_depth.is_none() {
        return Err(Error::AnalyzeError {
            details: "At least one executable-definitions criterion must be provided."
                .into(),
        });
    }

    if command.min_selection_lines == Some(0) {
        return Err(Error::AnalyzeError {
            details: "min-selection-lines must be greater than zero.".into(),
        });
    }

    if command.min_selection_depth == Some(0) {
        return Err(Error::AnalyzeError {
            details: "min-selection-depth must be greater than zero.".into(),
        });
    }

    let json = command.json;
    let min_selection_lines = command.min_selection_lines;
    let min_selection_depth = command.min_selection_depth;

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
    analyze_project_executable_definitions(
        project_name,
        program.as_ref(),
        &config.root_dir,
        min_selection_lines,
        min_selection_depth,
        json,
    )?;
    Ok(())
}

fn analyze_project_executable_definitions(
    project_name: ProjectName,
    programs: &relay_transforms::Programs,
    root_dir: &Path,
    min_selection_lines: Option<usize>,
    min_selection_depth: Option<usize>,
    json: bool,
) -> Result<(), Error> {
    let mut matches = Vec::new();

    for operation in programs.source.operations() {
        if let Some(match_entry) = analyze_executable_definition(
            "operation",
            operation.name.item.lookup().to_string(),
            operation.name.location,
            &operation.selections,
            min_selection_lines,
            min_selection_depth,
            root_dir,
        )? {
            matches.push(match_entry);
        }
    }

    for fragment in programs.source.fragments() {
        if let Some(match_entry) = analyze_executable_definition(
            "fragment",
            fragment.name.item.lookup().to_string(),
            fragment.name.location,
            &fragment.selections,
            min_selection_lines,
            min_selection_depth,
            root_dir,
        )? {
            matches.push(match_entry);
        }
    }

    matches.sort_by(|a, b| {
        a.kind
            .cmp(&b.kind)
            .then(a.name.cmp(&b.name))
            .then(a.selection_lines.cmp(&b.selection_lines))
            .then(a.selection_depth.cmp(&b.selection_depth))
    });

    let report = AnalyzeExecutableDefinitionsReport {
        project: project_name.to_string(),
        min_selection_lines,
        min_selection_depth,
        total_operations: programs.source.operations().count(),
        total_fragments: programs.source.fragments().count(),
        match_count: matches.len(),
        matches,
    };

    if json {
        let json_output =
            serde_json::to_string_pretty(&report).map_err(|err| Error::AnalyzeError {
                details: format!("Unable to serialize analyze output: {err}"),
            })?;
        println!("{}", json_output);
    } else {
        print_analyze_executable_definitions_text_report(&report)
    }

    Ok(())
}

fn analyze_executable_definition(
    kind: &'static str,
    name: String,
    name_location: Location,
    selections: &[Selection],
    min_selection_lines: Option<usize>,
    min_selection_depth: Option<usize>,
    root_dir: &Path,
) -> Result<Option<AnalyzeExecutableDefinitionMatch>, Error> {
    let (selection_span, selection_depth) = get_selection_span_and_depth(selections);
    let source_location = name_location.source_location();
    let location_source_text = source_for_location(root_dir, source_location, &FsSourceReader)
        .ok_or_else(|| Error::AnalyzeError {
            details: format!(
                "Unable to load source location '{}' for definition '{}'.",
                source_location.path(),
                name
            ),
        })?
        .text_source()
        .to_owned();

    let (selection_span_for_location, selection_lines) = if let Some(span) = selection_span {
        let range = location_source_text.to_span_range(span);
        let selection_lines = (range.end.line - range.start.line + 1) as usize;
        (span, selection_lines)
    } else {
        (name_location.span(), 0)
    };

    let range = location_source_text.to_span_range(selection_span_for_location);
    let mut violations = Vec::new();
    if let Some(min_selection_lines) = min_selection_lines {
        if selection_lines >= min_selection_lines {
            violations.push(format!(
                "selection body covers {} line(s), meets minimum line threshold of {}",
                selection_lines, min_selection_lines
            ));
        }
    }
    if let Some(min_selection_depth) = min_selection_depth {
        if selection_depth >= min_selection_depth {
            violations.push(format!(
                "selection depth is {}, meets minimum depth threshold of {}",
                selection_depth, min_selection_depth
            ));
        }
    }

    if violations.is_empty() {
        return Ok(None);
    }

    Ok(Some(AnalyzeExecutableDefinitionMatch {
        kind: kind.to_string(),
        name,
        location: AnalyzeExecutableDefinitionLocation {
            filename: source_location.path().to_string(),
            start_line: range.start.line + 1,
            start_column: range.start.character + 1,
            end_line: range.end.line + 1,
            end_column: range.end.character + 1,
        },
        selection_lines,
        selection_depth,
        violations,
    }))
}

fn get_selection_span_and_depth(selections: &[Selection]) -> (Option<Span>, usize) {
    let mut total_selection_span: Option<Span> = None;
    let mut max_depth = 0;

    for selection in selections {
        let selection_span = selection.location().span();
        let (depth, nested_span) = match selection {
            Selection::ScalarField(_) | Selection::FragmentSpread(_) => (1, None),
            Selection::LinkedField(linked_field) => {
                let (nested_span, nested_depth) = get_selection_span_and_depth(&linked_field.selections);
                (1 + nested_depth, Some(nested_span))
            }
            Selection::InlineFragment(inline_fragment) => {
                let (nested_span, nested_depth) =
                    get_selection_span_and_depth(&inline_fragment.selections);
                (1 + nested_depth, Some(nested_span))
            }
            Selection::Condition(condition) => {
                let (nested_span, nested_depth) = get_selection_span_and_depth(&condition.selections);
                (1 + nested_depth, Some(nested_span))
            }
        };

        let selection_span = match nested_span {
            Some(nested_span) => maybe_merge_spans(Some(selection_span), nested_span),
            None => Some(selection_span),
        };
        total_selection_span = maybe_merge_spans(total_selection_span, selection_span);
        max_depth = max(max_depth, depth);
    }

    (total_selection_span, max_depth)
}

fn maybe_merge_spans(first: Option<Span>, second: Option<Span>) -> Option<Span> {
    match (first, second) {
        (Some(first_span), Some(second_span)) => Some(Span::new(
            min(first_span.start, second_span.start),
            max(first_span.end, second_span.end),
        )),
        (Some(first_span), None) => Some(first_span),
        (None, Some(second_span)) => Some(second_span),
        (None, None) => None,
    }
}

fn print_analyze_executable_definitions_text_report(
    report: &AnalyzeExecutableDefinitionsReport,
) {
    if report.match_count == 0 {
        println!(
            "Project {}: no executable definitions match the provided criteria.",
            report.project
        );
        return;
    }

    println!(
        "Project {}: {} match(es) across {} operation(s), {} fragment(s).",
        report.project,
        report.match_count,
        report.total_operations,
        report.total_fragments
    );

    for match_entry in &report.matches {
        println!(
            "  {} {} @ {}:{}:{}-{}:{} (lines={}, depth={})",
            match_entry.kind,
            match_entry.name,
            match_entry.location.filename,
            match_entry.location.start_line,
            match_entry.location.start_column,
            match_entry.location.end_line,
            match_entry.location.end_column,
            match_entry.selection_lines,
            match_entry.selection_depth
        );
        println!(
            "    violations: {}",
            match_entry.violations.join(", ")
        );
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
