use std::collections::{HashMap, HashSet, VecDeque};
use std::path::Path;

use clap::Parser;
use common::ConsoleLogger;
use graphql_ir::FragmentDefinitionName;
use graphql_ir::Selection;
use relay_compiler::{ProjectName, get_programs};
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
pub(crate) struct AnalyzeUnusedFragmentsCommand {
    /// Analyze only this project.
    /// This exists for compatibility with multi-project Relay configs.
    #[clap(name = "project", long, short)]
    projects: Vec<String>,

    /// Limit the number of fragments returned.
    #[clap(long, default_value_t = 100)]
    limit: usize,

    /// Emit JSON output.
    #[clap(long)]
    json: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeUnusedFragmentsReport {
    project: String,
    match_count: usize,
    total_count: usize,
    limit: usize,
    truncated: bool,
    fragments: Vec<AnalyzeUnusedFragmentMatch>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeUnusedFragmentMatch {
    fragment_name: String,
    reason: String,
    location: AnalyzeUnusedFragmentLocation,
}

type AnalyzeUnusedFragmentLocation = AnalyzeLocation;

pub(crate) async fn handle_analyze_unused_fragments_command(
    command: AnalyzeUnusedFragmentsCommand,
) -> Result<(), Error> {
    let mut config = get_config(None)?;
    set_project_flag(&mut config, command.projects)?;
    let project_name = ensure_single_project_config(&config)?;
    let limit = command.limit;
    let json = command.json;

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
    analyze_project_unused_fragments(
        project_name,
        program.as_ref(),
        &config.root_dir,
        limit,
        json,
    )?;
    Ok(())
}

fn analyze_project_unused_fragments(
    project_name: ProjectName,
    programs: &relay_transforms::Programs,
    root_dir: &Path,
    limit: usize,
    json: bool,
) -> Result<(), Error> {
    let mut outgoing: HashMap<FragmentDefinitionName, Vec<FragmentDefinitionName>> = HashMap::default();
    let mut inbound: HashMap<FragmentDefinitionName, Vec<FragmentDefinitionName>> = HashMap::default();
    let mut used_fragments: HashSet<FragmentDefinitionName> = HashSet::default();
    let mut operation_level_spreads = Vec::new();
    for operation in programs.source.operations() {
        let mut spreads = Vec::new();
        collect_fragment_spread_references(&operation.selections, &mut spreads);
        for fragment_name in spreads {
            if used_fragments.insert(fragment_name) {
                operation_level_spreads.push(fragment_name);
            }
        }
    }

    for fragment in programs.source.fragments() {
        let mut spreads = Vec::new();
        collect_fragment_spread_references(&fragment.selections, &mut spreads);
        let current_fragment_name = fragment.name.item;
        outgoing.insert(current_fragment_name, spreads.clone());

        for target_fragment_name in spreads {
            inbound
                .entry(target_fragment_name)
                .or_default()
                .push(current_fragment_name);
        }
    }

    let mut queue: VecDeque<FragmentDefinitionName> = VecDeque::from_iter(operation_level_spreads);

    while let Some(current_fragment_name) = queue.pop_front() {
        for dependent_fragment_name in outgoing
            .get(&current_fragment_name)
            .into_iter()
            .flatten()
        {
            if used_fragments.insert(*dependent_fragment_name) {
                queue.push_back(*dependent_fragment_name);
            }
        }
    }

    let mut fragments = Vec::new();
    for fragment in programs.source.fragments() {
        if used_fragments.contains(&fragment.name.item) {
            continue;
        }

        let reason = if inbound.get(&fragment.name.item).is_some() {
            "only-deeply-referenced"
        } else {
            "unused"
        };

        let location = source_location_to_analyze_location(
            root_dir,
            &fragment.name.location,
            "fragment definition",
        )?;
        fragments.push(AnalyzeUnusedFragmentMatch {
            fragment_name: fragment.name.item.to_string(),
            reason: reason.to_string(),
            location,
        });
    }

    fragments.sort_by(|a, b| {
        a.reason
            .cmp(&b.reason)
            .then(a.fragment_name.cmp(&b.fragment_name))
    });

    let limited_fragments = apply_limit(fragments, limit);

    let report = AnalyzeUnusedFragmentsReport {
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
        print_analyze_unused_fragments_text_report(&report);
    }

    Ok(())
}

fn collect_fragment_spread_references(
    selections: &[Selection],
    spreads: &mut Vec<FragmentDefinitionName>,
) {
    for selection in selections {
        match selection {
            Selection::FragmentSpread(spread) => {
                spreads.push(spread.fragment.item);
            }
            Selection::Condition(condition) => {
                collect_fragment_spread_references(&condition.selections, spreads);
            }
            Selection::InlineFragment(inline_fragment) => {
                collect_fragment_spread_references(&inline_fragment.selections, spreads);
            }
            Selection::LinkedField(linked_field) => {
                collect_fragment_spread_references(&linked_field.selections, spreads);
            }
            Selection::ScalarField(_) => {}
        }
    }
}

fn print_analyze_unused_fragments_text_report(report: &AnalyzeUnusedFragmentsReport) {
    if report.match_count == 0 {
        println!("Project {}: no unused fragments found.", report.project);
        return;
    }

    println!(
        "Project {}: {} unused fragment(s).",
        report.project, report.match_count
    );

    if report.truncated {
        println!(
            "  showing {} of {} fragment(s) (use --limit to see more).",
            report.match_count, report.total_count
        );
    }

    for entry in &report.fragments {
        println!(
            "  [{}] {} @ {}:{}:{}-{}:{}",
            entry.reason,
            entry.fragment_name,
            entry.location.filename,
            entry.location.start_line,
            entry.location.start_column,
            entry.location.end_line,
            entry.location.end_column
        );
    }
}
