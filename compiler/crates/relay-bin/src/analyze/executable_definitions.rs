use std::cmp::{max, min};
use std::path::Path;
use std::sync::Arc;

use clap::Parser;
use common::{ConsoleLogger, Location, Span};
use graphql_ir::Selection;
use intern::Lookup;
use relay_compiler::{source_for_location, get_programs, FsSourceReader, ProjectName};
use serde::Serialize;

use crate::errors::Error;
use crate::{get_config, set_project_flag};

use super::utils::{
    apply_limit,
    ensure_single_project_config,
    print_json_report,
};

#[derive(Parser)]
#[clap(
    rename_all = "camel_case",
    about = "Find operations and fragments by selection size/depth."
)]
pub(crate) struct AnalyzeExecutableDefinitionsCommand {
    /// Analyze only this project. You can pass this argument multiple times.
    /// Currently, only single-project configs are supported.
    #[clap(name = "project", long, short)]
    projects: Vec<String>,

    /// Limit the number of matches returned.
    #[clap(long, default_value_t = 100)]
    limit: usize,

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
struct AnalyzeExecutableDefinitionsReport {
    project: String,
    min_selection_lines: Option<usize>,
    min_selection_depth: Option<usize>,
    total_operations: usize,
    total_fragments: usize,
    matches: Vec<AnalyzeExecutableDefinitionMatch>,
    match_count: usize,
    total_count: usize,
    limit: usize,
    truncated: bool,
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

pub(crate) async fn handle_analyze_executable_definitions_command(
    command: AnalyzeExecutableDefinitionsCommand,
) -> Result<(), Error> {
    let mut config = get_config(None)?;
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
    let limit = command.limit;

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
        limit,
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
    limit: usize,
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
    let limited_matches = apply_limit(matches, limit);

    let report = AnalyzeExecutableDefinitionsReport {
        project: project_name.to_string(),
        min_selection_lines,
        min_selection_depth,
        total_operations: programs.source.operations().count(),
        total_fragments: programs.source.fragments().count(),
        match_count: limited_matches.match_count,
        total_count: limited_matches.total_count,
        limit,
        truncated: limited_matches.truncated,
        matches: limited_matches.entries,
    };

    if json {
        print_json_report(&report)?;
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
            Selection::InlineFragment(inline_field) => {
                let (nested_span, nested_depth) =
                    get_selection_span_and_depth(&inline_field.selections);
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
        println!("    violations: {}", match_entry.violations.join(", "));
    }

    if report.truncated {
        println!(
            "  showing {} of {} match(es) (use --limit to see more).",
            report.match_count, report.total_count
        );
    }
}
