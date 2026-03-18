use std::collections::HashMap;
use std::path::Path;

use clap::Parser;
use common::ConsoleLogger;
use graphql_ir::Selection;
use graphql_ir::FragmentDefinitionName;
use relay_compiler::ProjectName;
use relay_compiler::{get_programs};
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
pub(crate) struct AnalyzeFragmentUsageCommand {
    /// Analyze only this project.
    /// This exists for compatibility with multi-project Relay configs.
    #[clap(name = "project", long, short)]
    projects: Vec<String>,

    /// Sort order for usage results.
    #[clap(
        long,
        default_value = "usage-desc",
        value_parser = ["usage-desc", "usage-asc"]
    )]
    sort: String,

    /// Show only fragments with at least this many usages.
    #[clap(long = "min-usage")]
    min_usage: Option<usize>,

    /// Limit the number of fragments returned.
    #[clap(long, default_value_t = 100)]
    limit: usize,

    /// Emit JSON output.
    #[clap(long)]
    json: bool,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum AnalyzeFragmentUsageSort {
    UsageDesc,
    UsageAsc,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeFragmentUsageReport {
    project: String,
    match_count: usize,
    total_count: usize,
    limit: usize,
    truncated: bool,
    fragments: Vec<AnalyzeFragmentUsageMatch>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeFragmentUsageMatch {
    fragment_name: String,
    usage_count: usize,
    location: AnalyzeFragmentUsageLocation,
}

type AnalyzeFragmentUsageLocation = AnalyzeLocation;

pub(crate) async fn handle_analyze_fragment_usage_command(
    command: AnalyzeFragmentUsageCommand,
) -> Result<(), Error> {
    let mut config = get_config(None)?;
    set_project_flag(&mut config, command.projects)?;
    let project_name = ensure_single_project_config(&config)?;
    let sort = match command.sort.as_str() {
        "usage-desc" => AnalyzeFragmentUsageSort::UsageDesc,
        "usage-asc" => AnalyzeFragmentUsageSort::UsageAsc,
        _ => {
            return Err(Error::AnalyzeError {
                details: "sort must be usage-desc or usage-asc.".into(),
            })
        }
    };
    let min_usage = command.min_usage;
    let limit = command.limit;
    let json = command.json;
    if let Some(0) = min_usage {
        return Err(Error::AnalyzeError {
            details: "min-usage must be greater than zero.".into(),
        });
    }

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
    analyze_project_fragment_usage(
        project_name,
        program.as_ref(),
        &config.root_dir,
        sort,
        min_usage,
        limit,
        json,
    )?;

    Ok(())
}

fn analyze_project_fragment_usage(
    project_name: ProjectName,
    programs: &relay_transforms::Programs,
    root_dir: &Path,
    sort: AnalyzeFragmentUsageSort,
    min_usage: Option<usize>,
    limit: usize,
    json: bool,
) -> Result<(), Error> {
    let mut usage_by_fragment: HashMap<FragmentDefinitionName, usize> = programs
        .source
        .fragments()
        .map(|fragment| (fragment.name.item, 0))
        .collect();

    for operation in programs.source.operations() {
        collect_fragment_spread_usages(&operation.selections, &mut usage_by_fragment);
    }

    for fragment in programs.source.fragments() {
        collect_fragment_spread_usages(&fragment.selections, &mut usage_by_fragment);
    }

    let mut fragments = Vec::new();
    for fragment in programs.source.fragments() {
        let usage_count = usage_by_fragment
            .get(&fragment.name.item)
            .copied()
            .unwrap_or_default();
        let location = source_location_to_analyze_location(
            root_dir,
            &fragment.name.location,
            "fragment usage",
        )?;
        fragments.push(AnalyzeFragmentUsageMatch {
            fragment_name: fragment.name.item.to_string(),
            usage_count,
            location,
        });
    }

    if let Some(min_usage) = min_usage {
        fragments.retain(|entry| entry.usage_count >= min_usage);
    }

    match sort {
        AnalyzeFragmentUsageSort::UsageDesc => fragments
            .sort_by(|a, b| b.usage_count.cmp(&a.usage_count).then(a.fragment_name.cmp(&b.fragment_name))),
        AnalyzeFragmentUsageSort::UsageAsc => fragments
            .sort_by(|a, b| a.usage_count.cmp(&b.usage_count).then(a.fragment_name.cmp(&b.fragment_name))),
    }

    let limited_fragments = apply_limit(fragments, limit);

    let report = AnalyzeFragmentUsageReport {
        project: project_name.to_string(),
        match_count: limited_fragments.match_count,
        total_count: limited_fragments.total_count,
        limit,
        truncated: limited_fragments.truncated,
        fragments: limited_fragments.entries,
    };

    if json {
        print_json_report(&report)?;
    } else {
        print_analyze_fragment_usage_text_report(&report);
    }

    Ok(())
}

fn collect_fragment_spread_usages(
    selections: &[Selection],
    usage_by_fragment: &mut HashMap<FragmentDefinitionName, usize>,
) {
    for selection in selections {
        match selection {
            Selection::FragmentSpread(spread) => {
                let entry = usage_by_fragment.entry(spread.fragment.item).or_insert(0);
                *entry += 1;
            }
            Selection::Condition(condition) => {
                collect_fragment_spread_usages(&condition.selections, usage_by_fragment);
            }
            Selection::InlineFragment(inline_fragment) => {
                collect_fragment_spread_usages(&inline_fragment.selections, usage_by_fragment);
            }
            Selection::LinkedField(linked_field) => {
                collect_fragment_spread_usages(&linked_field.selections, usage_by_fragment);
            }
            Selection::ScalarField(_) => {}
        }
    }
}

fn print_analyze_fragment_usage_text_report(report: &AnalyzeFragmentUsageReport) {
    if report.match_count == 0 {
        println!("Project {}: no fragments found.", report.project);
        return;
    }

    println!(
        "Project {}: {} fragment(s) sorted by usage count.",
        report.project, report.match_count
    );
    if report.truncated {
        println!(
            "  showing {} of {} fragment(s) (use --limit to see more).",
            report.match_count, report.total_count
        );
    }

    for fragment in &report.fragments {
        println!(
            "  {:>3} use(s): {} @ {}:{}:{}-{}:{}",
            fragment.usage_count,
            fragment.fragment_name,
            fragment.location.filename,
            fragment.location.start_line,
            fragment.location.start_column,
            fragment.location.end_line,
            fragment.location.end_column
        );
    }
}
