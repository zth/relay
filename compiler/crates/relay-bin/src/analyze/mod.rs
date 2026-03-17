use clap::Parser;

mod executable_definitions;
mod fragment_dependents;
mod fragment_usage;
mod find_references;
mod deprecated_usage;
mod print_operation;
mod rename_fragment;
mod unused_fragments;
mod schema_dce;
mod utils;

use crate::errors::Error;

use executable_definitions::AnalyzeExecutableDefinitionsCommand;
use find_references::AnalyzeFindReferencesCommand;
use deprecated_usage::AnalyzeDeprecatedUsageCommand;
use fragment_dependents::AnalyzeFragmentDependentsCommand;
use fragment_usage::AnalyzeFragmentUsageCommand;
use rename_fragment::AnalyzeRenameFragmentCommand;
use print_operation::AnalyzePrintOperationCommand;
use schema_dce::AnalyzeSchemaDceCommand;
use unused_fragments::AnalyzeUnusedFragmentsCommand;

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

    /// Find all dependent operations and fragments for a fragment.
    #[clap(name = "fragment-dependents")]
    FragmentDependents(AnalyzeFragmentDependentsCommand),

    /// Find deprecated fields, arguments, and directives in executable documents.
    #[clap(name = "deprecated-usage")]
    DeprecatedUsage(AnalyzeDeprecatedUsageCommand),

    /// Find fragments that are not referenced from any operation.
    #[clap(name = "unused-fragments")]
    UnusedFragments(AnalyzeUnusedFragmentsCommand),

    /// List fragments by spread usage count (most used first).
    #[clap(name = "fragment-usage")]
    FragmentUsage(AnalyzeFragmentUsageCommand),

    /// Rename a fragment and update all of its spread sites.
    #[clap(name = "rename-fragment")]
    RenameFragment(AnalyzeRenameFragmentCommand),

    /// Find schema fields never referenced in any Relay operations or fragments.
    #[clap(name = "schema-dce")]
    SchemaDce(AnalyzeSchemaDceCommand),

    /// Find operations/fragments by selection size/depth.
    #[clap(name = "executable-definitions")]
    ExecutableDefinitions(AnalyzeExecutableDefinitionsCommand),
}

pub async fn handle_analyze_command(command: AnalyzeCommand) -> Result<(), Error> {
    match command.command {
        AnalyzeSubcommand::FindReferences(command) => {
            find_references::handle_analyze_find_references_command(command).await
        }
        AnalyzeSubcommand::PrintOperation(command) => {
            print_operation::handle_analyze_print_operation_command(command).await
        }
        AnalyzeSubcommand::SchemaDce(command) => {
            schema_dce::handle_analyze_schema_dce_command(command).await
        }
        AnalyzeSubcommand::FragmentDependents(command) => {
            fragment_dependents::handle_analyze_fragment_dependents_command(command).await
        }
        AnalyzeSubcommand::DeprecatedUsage(command) => {
            deprecated_usage::handle_analyze_deprecated_usage_command(command).await
        }
        AnalyzeSubcommand::UnusedFragments(command) => {
            unused_fragments::handle_analyze_unused_fragments_command(command).await
        }
        AnalyzeSubcommand::FragmentUsage(command) => {
            fragment_usage::handle_analyze_fragment_usage_command(command).await
        }
        AnalyzeSubcommand::RenameFragment(command) => {
            rename_fragment::handle_analyze_rename_fragment_command(command).await
        }
        AnalyzeSubcommand::ExecutableDefinitions(command) => {
            executable_definitions::handle_analyze_executable_definitions_command(command).await
        }
    }
}
