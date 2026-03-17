use clap::Parser;

mod executable_definitions;
mod find_references;
mod print_operation;
mod schema_dce;
mod utils;

use crate::errors::Error;

use executable_definitions::AnalyzeExecutableDefinitionsCommand;
use find_references::AnalyzeFindReferencesCommand;
use print_operation::AnalyzePrintOperationCommand;
use schema_dce::AnalyzeSchemaDceCommand;

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

    /// Find unused schema fields in Relay operations.
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
        AnalyzeSubcommand::ExecutableDefinitions(command) => {
            executable_definitions::handle_analyze_executable_definitions_command(command).await
        }
    }
}
