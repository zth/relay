use std::sync::Arc;

use clap::Parser;
use common::ConsoleLogger;
use intern::string_key::Intern;
use graphql_ir::FragmentDefinition;
use graphql_ir::OperationDefinitionName;
use graphql_ir::Selection;
use graphql_text_printer::print_full_operation;
use relay_compiler::{get_programs, ProjectName};
use relay_transforms::apply_transforms;
use serde::Serialize;

use crate::errors::Error;
use crate::{get_config, set_project_flag};

use super::utils::{ensure_single_project_config, print_json_report};

#[derive(Parser)]
#[clap(
    rename_all = "camel_case",
    about = "Print the full text for a named GraphQL operation."
)]
pub(crate) struct AnalyzePrintOperationCommand {
    /// The name of the operation to print.
    operation: String,

    /// Analyze only this project. You can pass this argument multiple times.
    /// Currently, only single-project configs are supported.
    #[clap(name = "project", long, short)]
    projects: Vec<String>,

    /// Emit JSON output.
    #[clap(long)]
    json: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct AnalyzePrintOperationReport {
    project: String,
    operation_name: String,
    operation_text: String,
}

pub(crate) async fn handle_analyze_print_operation_command(
    command: AnalyzePrintOperationCommand,
) -> Result<(), Error> {
    let mut config = get_config(None)?;
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

    let operation_only_program = get_operation_only_program(
        Arc::clone(&operation),
        vec![],
        &programs.source,
    );
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
        print_json_report(&report)?;
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
                Selection::Condition(condition) => {
                    selections_to_visit.push(&condition.selections);
                }
                Selection::LinkedField(linked_field) => {
                    selections_to_visit.push(&linked_field.selections);
                }
                Selection::InlineFragment(inline_fragment) => {
                    selections_to_visit.push(&inline_fragment.selections);
                }
                Selection::ScalarField(_) => {}
            }
        }
    }

    next_program
}

fn print_analyze_print_operation_text_report(report: &AnalyzePrintOperationReport) {
    println!("Project {}: operation {}.", report.project, report.operation_name);
    println!("{}", report.operation_text);
}
