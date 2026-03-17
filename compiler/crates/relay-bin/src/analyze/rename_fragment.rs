use std::collections::HashMap;
use std::fs;
use std::path::Path;
use std::sync::Arc;

use clap::Parser;
use common::{ConsoleLogger, Location};
use graphql_ir::FragmentDefinitionName;
use graphql_syntax::parse_executable_with_error_recovery;
use intern::string_key::Intern;
use lsp_types::Range;
use relay_compiler::{get_programs, FsSourceReader, ProjectName, source_for_location};
use relay_lsp::rename::{create_rename_request, get_locations_for_rename};
use relay_lsp::{position_to_offset, Feature};
use serde::Serialize;

use crate::errors::Error;
use crate::{get_config, set_project_flag};

use super::utils::{
    AnalyzeRange,
    ensure_single_project_config,
    normalize_range,
    print_json_report,
};

type AnalyzeRenameFragmentLocation = AnalyzeRange;

#[derive(Parser)]
#[clap(
    rename_all = "camel_case",
    about = "Rename a fragment definition and all of its spread sites."
)]
pub(crate) struct AnalyzeRenameFragmentCommand {
    /// The current fragment name.
    old_fragment: String,

    /// The new fragment name.
    new_fragment: String,

    /// Analyze only this project. You can pass this argument multiple times.
    /// Currently, only single-project configs are supported.
    #[clap(name = "project", long, short)]
    projects: Vec<String>,

    /// Show what would change without modifying files.
    #[clap(long = "dry-run", alias = "dryRun")]
    dry_run: bool,

    /// Emit JSON output.
    #[clap(long)]
    json: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeRenameFragmentReport {
    project: String,
    old_fragment: String,
    new_fragment: String,
    dry_run: bool,
    file_count: usize,
    match_count: usize,
    files: Vec<AnalyzeRenameFragmentFile>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzeRenameFragmentFile {
    filename: String,
    replacement_count: usize,
    locations: Vec<AnalyzeRenameFragmentLocation>,
}

pub(crate) async fn handle_analyze_rename_fragment_command(
    command: AnalyzeRenameFragmentCommand,
) -> Result<(), Error> {
    let mut config = get_config(None)?;
    let project_name = ensure_single_project_config(&config)?;
    let old_fragment = parse_fragment_name(&command.old_fragment)?;
    let new_fragment = parse_fragment_name(&command.new_fragment)?;
    let json = command.json;
    let dry_run = command.dry_run;

    if old_fragment == new_fragment {
        return Err(Error::AnalyzeError {
            details: "old-fragment and new-fragment must be different.".to_string(),
        });
    }

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

    analyze_project_rename_fragment(
        project_name,
        program.as_ref(),
        &config.root_dir,
        old_fragment,
        new_fragment,
        dry_run,
        json,
    )?;

    Ok(())
}

fn parse_fragment_name(fragment_name: &str) -> Result<FragmentDefinitionName, Error> {
    let fragment_name = fragment_name.trim();
    if fragment_name.is_empty() {
        return Err(Error::AnalyzeError {
            details: "A fragment name is required.".to_string(),
        });
    }

    Ok(FragmentDefinitionName(fragment_name.intern()))
}

fn analyze_project_rename_fragment(
    project_name: ProjectName,
    programs: &relay_transforms::Programs,
    root_dir: &Path,
    old_fragment: FragmentDefinitionName,
    new_fragment: FragmentDefinitionName,
    dry_run: bool,
    json: bool,
) -> Result<(), Error> {
    let old_fragment_name = old_fragment.to_string();
    let new_fragment_name = new_fragment.to_string();

    let source_fragment = programs
        .source
        .fragment(old_fragment)
        .ok_or_else(|| Error::AnalyzeError {
            details: format!("Fragment `{old_fragment_name}` was not found in source documents."),
        })?;

    let definition_location = source_fragment.name.location;
    let rename_request = create_fragment_rename_request(root_dir, definition_location)?;

    let mut rename_locations = get_locations_for_rename(rename_request, &programs.source).map_err(|err| {
        Error::AnalyzeError {
            details: format!("Unable to resolve rename locations for `{old_fragment_name}`: {err:?}"),
        }
    })?;

    if rename_locations.is_empty() {
        return Err(Error::AnalyzeError {
            details: format!("Fragment `{old_fragment_name}` has no rename targets."),
        });
    }

    // Stable output order.
    rename_locations.sort_by(|left, right| {
        left.source_location()
            .path()
            .cmp(right.source_location().path())
            .then(left.span().start.cmp(&right.span().start))
    });

    let mut locations_by_file: HashMap<String, Vec<Range>> = HashMap::default();
    for location in rename_locations {
        let source_location = location.source_location();
        let source = source_for_location(root_dir, source_location, &FsSourceReader).ok_or_else(|| {
            Error::AnalyzeError {
                details: format!(
                    "Unable to load source location '{}' for rename target.",
                    source_location.path()
                ),
            }
        })?;
        let range = source.text_source().to_span_range(location.span());
        locations_by_file
            .entry(source_location.path().to_string())
            .or_default()
            .push(range);
    }

    let mut file_changes = Vec::new();
    for (filename, mut ranges) in locations_by_file {
        if dry_run {
            ranges.sort_by(|left, right| {
                (left.start.line, left.start.character).cmp(&(right.start.line, right.start.character))
            });

            file_changes.push(AnalyzeRenameFragmentFile {
                filename,
                replacement_count: ranges.len(),
                locations: ranges
                    .into_iter()
                    .map(|range| normalize_range(&range))
                    .collect(),
            });

            continue;
        }

        let absolute_path = root_dir.join(&filename);
        let mut source_text = fs::read_to_string(&absolute_path).map_err(|err| Error::AnalyzeError {
            details: format!("Unable to read file '{}': {err}", absolute_path.display()),
        })?;

        let mut replacements = Vec::with_capacity(ranges.len());
        for range in ranges.drain(..) {
            let start = position_to_offset(&range.start, 0, 0, &source_text)
                .and_then(|offset| usize::try_from(offset).ok())
                .ok_or_else(|| Error::AnalyzeError {
                    details: format!(
                        "Unable to map rename target line/column in '{}': {}:{}-{}:{}",
                        filename,
                        range.start.line + 1,
                        range.start.character + 1,
                        range.end.line + 1,
                        range.end.character + 1
                    ),
                })?;

            let end = position_to_offset(&range.end, 0, 0, &source_text)
                .and_then(|offset| usize::try_from(offset).ok())
                .ok_or_else(|| Error::AnalyzeError {
                    details: format!(
                        "Unable to map rename target line/column in '{}': {}:{}-{}:{}",
                        filename,
                        range.start.line + 1,
                        range.start.character + 1,
                        range.end.line + 1,
                        range.end.character + 1
                    ),
                })?;

            if start > end {
                return Err(Error::AnalyzeError {
                    details: format!(
                        "Unable to apply rename in '{}': invalid range {}:{}-{}:{}",
                        filename,
                        range.start.line + 1,
                        range.start.character + 1,
                        range.end.line + 1,
                        range.end.character + 1
                    ),
                });
            }

            replacements.push((start, end, range));
        }

        replacements.sort_by(|left, right| right.0.cmp(&left.0));
        for (start, end, _) in replacements.iter() {
            source_text.replace_range(*start..*end, &new_fragment_name);
        }

        fs::write(&absolute_path, source_text).map_err(|err| Error::AnalyzeError {
            details: format!("Unable to write file '{}': {err}", absolute_path.display()),
        })?;

        replacements.sort_by(|left, right| {
            (left.2.start.line, left.2.start.character).cmp(&(right.2.start.line, right.2.start.character))
        });

            file_changes.push(AnalyzeRenameFragmentFile {
                filename,
                replacement_count: replacements.len(),
                locations: replacements
                    .into_iter()
                    .map(|(_, _, range)| normalize_range(&range))
                    .collect(),
            });
    }

    file_changes.sort_by(|left, right| left.filename.cmp(&right.filename));
    let match_count: usize = file_changes.iter().map(|entry| entry.replacement_count).sum();

    let report = AnalyzeRenameFragmentReport {
        project: project_name.to_string(),
        old_fragment: old_fragment_name,
        new_fragment: new_fragment_name,
        dry_run,
        file_count: file_changes.len(),
        match_count,
        files: file_changes,
    };

    if json {
        print_json_report(&report)?;
    } else {
        print_analyze_rename_fragment_text_report(&report);
    }

    Ok(())
}

fn create_fragment_rename_request(
    root_dir: &Path,
    definition_location: Location,
) -> Result<relay_lsp::rename::RenameRequest, Error> {
    let source_location = definition_location.source_location();
    let source = source_for_location(root_dir, source_location, &FsSourceReader).ok_or_else(|| {
        Error::AnalyzeError {
            details: format!(
                "Unable to load source location '{}' for fragment definition.",
                source_location.path()
            ),
        }
    })?;

    let source_text = source.text_source().text.to_string();
    let feature = Feature::ExecutableDocument(parse_executable_with_error_recovery(
        &source_text,
        source_location,
    )
    .item);

    create_rename_request(feature, definition_location).map_err(|err| Error::AnalyzeError {
        details: format!(
            "Unable to prepare rename request for source '{}': {err:?}",
            source_location.path()
        ),
    })
}

fn print_analyze_rename_fragment_text_report(report: &AnalyzeRenameFragmentReport) {
    if report.match_count == 0 {
        println!(
            "Project {}: no changes made ({} not found).",
            report.project, report.old_fragment
        );
        return;
    }

    let action = if report.dry_run {
        "would rename"
    } else {
        "renamed"
    };
    let writes = if report.dry_run { "(no files written)" } else { "" };

    println!(
        "Project {}: {} {} -> {} in {} location(s) across {} file(s) {}",
        report.project,
        action,
        report.old_fragment,
        report.new_fragment,
        report.match_count,
        report.file_count,
        writes
    );

    for file in &report.files {
        println!("  {} ({} location(s))", file.filename, file.replacement_count);
        for location in &file.locations {
            println!(
                "    {}:{}-{}:{}",
                location.start_line,
                location.start_column,
                location.end_line,
                location.end_column
            );
        }
    }
}
