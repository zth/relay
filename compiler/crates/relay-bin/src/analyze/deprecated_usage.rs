use clap::Parser;
use common::ConsoleLogger;
use graphql_ir::ExecutableDefinition;
use relay_compiler::{ProjectName, get_programs};
use relay_transforms::deprecated_fields_for_executable_definition;
use serde::Serialize;

use crate::errors::Error;
use crate::{get_config, set_project_flag};

use super::utils::{
    apply_limit,
    ensure_single_project_config,
    print_json_report,
    source_location_to_analyze_location,
    AnalyzeLocation,
};

#[derive(Parser)]
#[clap(rename_all = "camel_case")]
pub(crate) struct AnalyzeDeprecatedUsageCommand {
    /// Analyze only this project.
    /// This exists for compatibility with multi-project Relay configs.
    #[clap(name = "project", long, short)]
    projects: Vec<String>,

    /// Limit the number of results returned.
    #[clap(long, default_value_t = 100)]
    limit: usize,

    /// Emit JSON output.
    #[clap(long)]
    json: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeDeprecatedUsageReport {
    project: String,
    match_count: usize,
    total_count: usize,
    limit: usize,
    truncated: bool,
    usages: Vec<AnalyzeDeprecatedUsageEntry>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeDeprecatedUsageEntry {
    kind: String,
    item: String,
    reason: Option<String>,
    containing_definition: String,
    containing_definition_kind: String,
    location: AnalyzeDeprecatedUsageLocation,
}

type AnalyzeDeprecatedUsageLocation = AnalyzeLocation;

pub(crate) async fn handle_analyze_deprecated_usage_command(
    command: AnalyzeDeprecatedUsageCommand,
) -> Result<(), Error> {
    let mut config = get_config(None)?;
    set_project_flag(&mut config, command.projects)?;
    let project_name = ensure_single_project_config(&config)?;
    let json = command.json;
    let limit = command.limit;

    let (programs_by_project, _, config) = get_programs(config, std::sync::Arc::new(ConsoleLogger)).await;
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
    analyze_project_deprecated_usage(
        project_name,
        program.as_ref(),
        &config.root_dir,
        limit,
        json,
    )?;
    Ok(())
}

fn analyze_project_deprecated_usage(
    project_name: ProjectName,
    program: &relay_transforms::Programs,
    root_dir: &std::path::Path,
    limit: usize,
    json: bool,
) -> Result<(), Error> {
    let mut usages = Vec::new();
    let schema = &program.source.schema;
    for operation in program.source.operations() {
        collect_deprecated_usage(
            &ExecutableDefinition::Operation(operation.as_ref().clone()),
            &operation.name.item.to_string(),
            "operation",
            schema,
            root_dir,
            &mut usages,
        )?;
    }

    for fragment in program.source.fragments() {
        collect_deprecated_usage(
            &ExecutableDefinition::Fragment(fragment.as_ref().clone()),
            &fragment.name.item.to_string(),
            "fragment",
            schema,
            root_dir,
            &mut usages,
        )?;
    }

    usages.sort_by(|a, b| {
        a.kind
            .cmp(&b.kind)
            .then(a.containing_definition_kind.cmp(&b.containing_definition_kind))
            .then(a.containing_definition.cmp(&b.containing_definition))
            .then(a.item.cmp(&b.item))
            .then(a.location.filename.cmp(&b.location.filename))
            .then(a.location.start_line.cmp(&b.location.start_line))
            .then(a.location.start_column.cmp(&b.location.start_column))
    });

    let limited_usages = apply_limit(usages, limit);

    let report = AnalyzeDeprecatedUsageReport {
        project: project_name.to_string(),
        match_count: limited_usages.match_count,
        total_count: limited_usages.total_count,
        limit,
        truncated: limited_usages.truncated,
        usages: limited_usages.entries,
    };

    if json {
        print_json_report(&report)?;
    } else {
        print_analyze_deprecated_usage_text_report(&report);
    }
    Ok(())
}

fn collect_deprecated_usage(
    definition: &ExecutableDefinition,
    definition_name: &str,
    definition_kind: &'static str,
    schema: &std::sync::Arc<schema::SDLSchema>,
    root_dir: &std::path::Path,
    usages: &mut Vec<AnalyzeDeprecatedUsageEntry>,
) -> Result<(), Error> {
    let warnings = deprecated_fields_for_executable_definition(schema, definition)
        .map_err(|errors| Error::AnalyzeError {
            details: format!(
                "Unable to get deprecation diagnostics for `{definition_name}`: {errors:?}"
            ),
        })?;

    for warning in warnings {
        let message = warning.message().to_string();
        let (kind, item, fallback) = parse_deprecated_warning(&message);
        let location = source_location_to_analyze_location(
            root_dir,
            &warning.location(),
            "deprecated usage",
        )?;
        usages.push(AnalyzeDeprecatedUsageEntry {
            kind,
            item: item.or(fallback).unwrap_or_default(),
            reason: parse_deprecation_reason(&message),
            containing_definition: definition_name.to_string(),
            containing_definition_kind: definition_kind.to_string(),
            location,
        });
    }

    Ok(())
}

fn parse_deprecated_warning(message: &str) -> (String, Option<String>, Option<String>) {
    let backticked = collect_backticked_segments(message);
    let fallback = message.to_string();
    let (kind, item) = if message.starts_with("The field ") {
        (
            "field".to_string(),
            backticked.first().cloned(),
        )
    } else if message.starts_with("The argument ") && message.contains("of the directive") {
        let directive = backticked
            .get(1)
            .cloned()
            .unwrap_or_default();
        let arg = backticked.first().cloned().unwrap_or_else(String::new);
        let item = if directive.is_empty() || arg.is_empty() {
            None
        } else {
            Some(format!("{directive} argument {arg}"))
        };
        ("argument".to_string(), item)
    } else if message.starts_with("The argument ") {
        let parent = backticked.get(1).cloned().unwrap_or_else(String::new);
        let arg = backticked.first().cloned().unwrap_or_else(String::new);
        let item = if parent.is_empty() || arg.is_empty() {
            None
        } else {
            Some(format!("{parent} argument {arg}"))
        };
        ("argument".to_string(), item)
    } else if message.starts_with("The directive ") {
        (
            "directive".to_string(),
            backticked.first().cloned(),
        )
    } else {
        (
            "deprecated".to_string(),
            backticked.first().cloned(),
        )
    };

    let fallback_item = (if fallback.is_empty() {
        None
    } else {
        Some(fallback)
    })
    .filter(|_| item.is_none());

    (kind, item, fallback_item)
}

fn parse_deprecation_reason(message: &str) -> Option<String> {
    let marker = "Deprecation reason: \"";
    let start = message.find(marker)?;
    let after_marker = &message[(start + marker.len())..];
    let end = after_marker.find('"')?;
    let reason = &after_marker[..end];
    if reason.is_empty() {
        None
    } else {
        Some(reason.to_string())
    }
}

fn collect_backticked_segments(message: &str) -> Vec<String> {
    let mut segments = Vec::new();
    let mut remaining = message;

    loop {
        let start = match remaining.find('`') {
            Some(value) => value + 1,
            None => break,
        };
        let tail = &remaining[start..];
        let end = match tail.find('`') {
            Some(value) => value,
            None => break,
        };
        segments.push(tail[..end].to_string());
        remaining = &tail[end + 1..];
    }

    segments
}

fn print_analyze_deprecated_usage_text_report(report: &AnalyzeDeprecatedUsageReport) {
    if report.match_count == 0 {
        println!("Project {}: no deprecated usages found.", report.project);
        return;
    }

    println!(
        "Project {}: {} deprecated usage(s).",
        report.project, report.match_count
    );

    if report.truncated {
        println!(
            "  showing {} of {} deprecated usage(s) (use --limit to see more).",
            report.match_count, report.total_count
        );
    }

    for usage in &report.usages {
        println!(
            "  {} usage '{}' in {} {} @ {}:{}:{}-{}:{}",
            usage.kind,
            usage.item,
            usage.containing_definition_kind,
            usage.containing_definition,
            usage.location.filename,
            usage.location.start_line,
            usage.location.start_column,
            usage.location.end_line,
            usage.location.end_column
        );
        if let Some(reason) = &usage.reason {
            println!("    reason: {reason}");
        }
    }
}
