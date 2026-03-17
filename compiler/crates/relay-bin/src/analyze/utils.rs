use relay_compiler::config::Config;
use relay_compiler::ProjectName;
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
