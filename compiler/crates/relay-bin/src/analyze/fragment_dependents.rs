use std::collections::{HashMap, VecDeque};
use std::path::Path;

use clap::Parser;
use common::ConsoleLogger;
use common::Location;
use graphql_ir::ExecutableDefinitionName;
use graphql_ir::FragmentDefinitionName;
use graphql_ir::Selection;
use intern::string_key::Intern;
use relay_compiler::{source_for_location, get_programs, FsSourceReader, ProjectName};
use serde::Serialize;

use crate::errors::Error;
use crate::{get_config, set_project_flag};

use super::utils::{ensure_single_project_config, print_json_report};

#[derive(Parser)]
#[clap(
    rename_all = "camel_case",
    about = "Find direct dependents of a fragment (operations/fragments that spread it)."
)]
pub(crate) struct AnalyzeFragmentDependentsCommand {
    /// The name of the fragment to find dependents for.
    fragment: String,

    /// Include the full line containing the dependent reference.
    #[clap(long = "with-snippet")]
    with_snippet: bool,

    /// Analyze only this project. You can pass this argument multiple times.
    /// Currently, only single-project configs are supported.
    #[clap(name = "project", long, short)]
    projects: Vec<String>,

    /// Limit the number of dependents returned.
    #[clap(long, default_value_t = 100)]
    limit: usize,

    /// Include transitive dependents (operations/fragments that depend on direct dependents).
    ///
    /// Direct dependents are the most common case (distance = 1), and usually represent
    /// the immediate blast radius of a fragment change.
    /// Transitive dependents are useful when you need complete impact analysis.
    #[clap(long)]
    transitive: bool,

    /// Emit JSON output.
    #[clap(long)]
    json: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeFragmentDependentsReport {
    project: String,
    fragment: String,
    with_snippet: bool,
    include_transitive: bool,
    match_count: usize,
    total_count: usize,
    limit: usize,
    truncated: bool,
    matches: Vec<AnalyzeFragmentDependentMatch>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeFragmentDependentMatch {
    kind: String,
    containing_definition: String,
    distance: usize,
    location: AnalyzeFragmentDependentLocation,
    snippet: Option<String>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeFragmentDependentLocation {
    filename: String,
    start_line: u32,
    start_column: u32,
    end_line: u32,
    end_column: u32,
}

#[derive(Debug, Clone)]
struct FragmentDependentEdge {
    parent: ExecutableDefinitionName,
    location: Location,
}

pub(crate) async fn handle_analyze_fragment_dependents_command(
    command: AnalyzeFragmentDependentsCommand,
) -> Result<(), Error> {
    let mut config = get_config(None)?;
    let project_name = ensure_single_project_config(&config)?;
    let root_fragment = parse_fragment_name(&command.fragment)?;
    let with_snippet = command.with_snippet;
    let include_transitive = command.transitive;
    let limit = command.limit;
    let json = command.json;
    set_project_flag(&mut config, command.projects)?;

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
    analyze_project_fragment_dependents(
        project_name,
        program.as_ref(),
        &config.root_dir,
        root_fragment,
        with_snippet,
        include_transitive,
        limit,
        json,
    )?;

    Ok(())
}

fn parse_fragment_name(fragment: &str) -> Result<FragmentDefinitionName, Error> {
    let fragment = fragment.trim();
    if fragment.is_empty() {
        return Err(Error::AnalyzeError {
            details: "A fragment name is required, e.g. `UserDataFragment`.".to_string(),
        });
    }

    Ok(FragmentDefinitionName(fragment.intern()))
}

fn analyze_project_fragment_dependents(
    project_name: ProjectName,
    programs: &relay_transforms::Programs,
    root_dir: &Path,
    root_fragment: FragmentDefinitionName,
    with_snippet: bool,
    include_transitive: bool,
    limit: usize,
    json: bool,
) -> Result<(), Error> {
    if programs.source.fragment(root_fragment).is_none() {
        return Err(Error::AnalyzeError {
            details: format!(
                "Fragment `{}` was not found in source documents.",
                root_fragment
            ),
        });
    }

    let edges = collect_fragment_spread_edges(programs);
    let mut dependents: Vec<AnalyzeFragmentDependentMatch> = Vec::new();
    let mut queue = VecDeque::new();
    let mut distance_by_definition: HashMap<ExecutableDefinitionName, usize> = HashMap::default();

    distance_by_definition.insert(root_fragment.into(), 0);
    queue.push_back(root_fragment);

    while let Some(current_fragment) = queue.pop_front() {
        let current_distance = distance_by_definition
            .get(&current_fragment.into())
            .copied()
            .unwrap_or(0);

        for edge in edges.get(&current_fragment).into_iter().flatten() {
            if distance_by_definition.contains_key(&edge.parent) {
                continue;
            }

            let distance = current_distance + 1;
            let (kind, containing_definition) = match edge.parent {
                ExecutableDefinitionName::OperationDefinitionName(operation_name) => {
                    ("operation".to_string(), operation_name.to_string())
                }
                ExecutableDefinitionName::FragmentDefinitionName(fragment_name) => {
                    if fragment_name == root_fragment {
                        continue;
                    }

                    ("fragment".to_string(), fragment_name.to_string())
                }
            };

            distance_by_definition.insert(edge.parent, distance);

            let location = location_from_reference(root_dir, &edge.location)?;
            let snippet = if with_snippet {
                Some(reference_line_snippet(root_dir, &edge.location)?)
            } else {
                None
            };

            dependents.push(AnalyzeFragmentDependentMatch {
                kind,
                containing_definition,
                distance,
                location,
                snippet,
            });

            if include_transitive {
                if let ExecutableDefinitionName::FragmentDefinitionName(parent_fragment) = edge.parent {
                    queue.push_back(parent_fragment);
                }
            }
        }
    }

    dependents.sort_by(|a, b| {
        a.kind
            .cmp(&b.kind)
            .then(a.containing_definition.cmp(&b.containing_definition))
            .then(a.distance.cmp(&b.distance))
    });
    let total_count = dependents.len();
    let truncated = total_count > limit;
    dependents.truncate(limit);

    let report = AnalyzeFragmentDependentsReport {
        project: project_name.to_string(),
        fragment: root_fragment.to_string(),
        with_snippet,
        include_transitive,
        match_count: dependents.len(),
        total_count,
        limit,
        truncated,
        matches: dependents,
    };

    if json {
        print_json_report(&report)?;
    } else {
        print_analyze_fragment_dependents_text_report(&report);
    }

    Ok(())
}

fn collect_fragment_spread_edges(
    programs: &relay_transforms::Programs,
) -> HashMap<FragmentDefinitionName, Vec<FragmentDependentEdge>> {
    let mut edges: HashMap<FragmentDefinitionName, Vec<FragmentDependentEdge>> = HashMap::default();

    for operation in programs.source.operations() {
        collect_fragment_spreads_from_selections(
            &operation.selections,
            ExecutableDefinitionName::OperationDefinitionName(operation.name.item),
            &mut edges,
        );
    }

    for fragment in programs.source.fragments() {
        collect_fragment_spreads_from_selections(
            &fragment.selections,
            ExecutableDefinitionName::FragmentDefinitionName(fragment.name.item),
            &mut edges,
        );
    }

    edges
}

fn collect_fragment_spreads_from_selections(
    selections: &[Selection],
    parent: ExecutableDefinitionName,
    edges: &mut HashMap<FragmentDefinitionName, Vec<FragmentDependentEdge>>,
) {
    for selection in selections {
        match selection {
            Selection::FragmentSpread(spread) => {
                edges
                    .entry(spread.fragment.item)
                    .or_default()
                    .push(FragmentDependentEdge {
                        parent,
                        location: spread.fragment.location,
                    });
            }
            Selection::Condition(condition) => {
                collect_fragment_spreads_from_selections(&condition.selections, parent, edges);
            }
            Selection::InlineFragment(inline_fragment) => {
                collect_fragment_spreads_from_selections(&inline_fragment.selections, parent, edges);
            }
            Selection::LinkedField(linked_field) => {
                collect_fragment_spreads_from_selections(&linked_field.selections, parent, edges);
            }
            Selection::ScalarField(_) => {}
        }
    }
}

fn location_from_reference(
    root_dir: &Path,
    location: &Location,
) -> Result<AnalyzeFragmentDependentLocation, Error> {
    let source_location = location.source_location();
    let source = source_for_location(root_dir, source_location, &FsSourceReader)
        .ok_or_else(|| Error::AnalyzeError {
            details: format!(
                "Unable to load source location '{}' for dependent reference.",
                source_location.path()
            ),
        })?;
    let source_text = source.text_source();
    let range = source_text.to_span_range(location.span());

    Ok(AnalyzeFragmentDependentLocation {
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
    let source_text = source.text_source();

    let range = source_text.to_span_range(location.span());
    let local_line = range
        .start
        .line
        .checked_sub(source_text.line_index as u32)
        .ok_or_else(|| Error::AnalyzeError {
            details: format!("Unable to resolve snippet line for {}.", source_location.path()),
        })?;

    source_text
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

fn print_analyze_fragment_dependents_text_report(report: &AnalyzeFragmentDependentsReport) {
    if report.matches.is_empty() {
        println!(
            "Project {}: no dependents found for fragment {}.",
            report.project, report.fragment
        );
        return;
    }

    let scope = if report.include_transitive {
        "direct and transitive"
    } else {
        "direct"
    };
    println!(
        "Project {}: {} {} dependent(s) found for fragment {}.",
        report.project,
        report.match_count,
        scope,
        report.fragment
    );

    for dependent in &report.matches {
        println!(
            "  {} {} (depth {}): {}:{}:{}-{}:{}",
            dependent.kind,
            dependent.containing_definition,
            dependent.distance,
            dependent.location.filename,
            dependent.location.start_line,
            dependent.location.start_column,
            dependent.location.end_line,
            dependent.location.end_column
        );
        if let Some(snippet) = &dependent.snippet {
            println!("    line: {}", snippet);
        }
    }

    if report.truncated {
        println!(
            "  showing {} of {} dependent(s) (use --limit to see more).",
            report.match_count, report.total_count
        );
    }
}
