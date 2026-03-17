use std::path::Path;

use common::Location;
use lsp_types::Range;
use relay_compiler::config::Config;
use relay_compiler::ProjectName;
use relay_compiler::{source_for_location, FsSourceReader};
use serde::Serialize;

use crate::errors::Error;

pub(crate) fn ensure_single_project_config(config: &Config) -> Result<ProjectName, Error> {
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

pub(crate) fn print_json_report<T: Serialize>(report: &T) -> Result<(), Error> {
    let json_output = serde_json::to_string_pretty(report).map_err(|err| Error::AnalyzeError {
        details: format!("Unable to serialize analyze output: {err}"),
    })?;
    println!("{}", json_output);
    Ok(())
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
pub(crate) struct AnalyzeLocation {
    pub filename: String,
    pub start_line: u32,
    pub start_column: u32,
    pub end_line: u32,
    pub end_column: u32,
}

#[derive(Debug, Clone, Copy, Serialize)]
#[serde(rename_all = "camelCase")]
pub(crate) struct AnalyzeRange {
    pub start_line: u32,
    pub start_column: u32,
    pub end_line: u32,
    pub end_column: u32,
}

pub(crate) fn source_location_to_analyze_location(
    root_dir: &Path,
    location: &Location,
    context: &str,
) -> Result<AnalyzeLocation, Error> {
    let source_location = location.source_location();
    let source = source_for_location(root_dir, source_location, &FsSourceReader).ok_or_else(|| {
        Error::AnalyzeError {
            details: format!(
                "Unable to load source location '{}' for {context}.",
                source_location.path()
            ),
        }
    })?;
    let source_text = source.text_source();
    let range = source_text.to_span_range(location.span());

    Ok(AnalyzeLocation {
        filename: source_location.path().to_string(),
        start_line: range.start.line + 1,
        start_column: range.start.character + 1,
        end_line: range.end.line + 1,
        end_column: range.end.character + 1,
    })
}

pub(crate) fn source_line_for_reference(
    root_dir: &Path,
    location: &Location,
    context: &str,
) -> Result<String, Error> {
    let source_location = location.source_location();
    let source = source_for_location(root_dir, source_location, &FsSourceReader).ok_or_else(|| {
        Error::AnalyzeError {
            details: format!(
                "Unable to load source location '{}' for snippet lookup ({context}).",
                source_location.path()
            ),
        }
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

pub(crate) fn normalize_range(range: &Range) -> AnalyzeRange {
    AnalyzeRange {
        start_line: range.start.line + 1,
        start_column: range.start.character + 1,
        end_line: range.end.line + 1,
        end_column: range.end.character + 1,
    }
}

#[derive(Debug)]
pub(crate) struct AnalyzeLimitResult<T> {
    pub entries: Vec<T>,
    pub match_count: usize,
    pub total_count: usize,
    pub truncated: bool,
}

pub(crate) fn apply_limit<T>(entries: Vec<T>, limit: usize) -> AnalyzeLimitResult<T> {
    let total_count = entries.len();
    let mut entries = entries;
    let truncated = total_count > limit;
    entries.truncate(limit);
    let match_count = entries.len();

    AnalyzeLimitResult {
        entries,
        match_count,
        total_count,
        truncated,
    }
}
