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
#[clap(
    rename_all = "snake_case",
    about = "Relay project analysis helpers for audits, impact analysis, and targeted refactors.",
    after_help = "Use `relay tools <command> --help` for detailed guidance and examples.\nYou can also run `relay tools help <command>`.",
    after_long_help = "Use `relay tools <command> --help` for detailed guidance and examples.\nYou can also run `relay tools help <command>`."
)]
pub struct AnalyzeCommand {
    /// GraphQL/Relay tooling commands.
    #[clap(subcommand)]
    command: AnalyzeSubcommand,
}

#[derive(clap::Subcommand)]
enum AnalyzeSubcommand {
    /// Find schema type/field references before renames, deprecations, or removals.
    #[clap(
        name = "find-schema-references",
        about = "Find schema type/field references before renames, deprecations, or removals.",
        long_about = "\
Find references for a schema type or field path.

Use this when you need impact analysis before renaming, deprecating, or removing part of the schema.
Good fit: trace every use of `User.name`, or find all type conditions that mention `User`.
Not a good fit: use `fragment-dependents` for fragment spread impact, or `deprecated-usage` for a broad deprecation sweep.

Examples:
  relay tools find-schema-references User.name
  relay tools find-schema-references User --with-snippet
  relay tools find-schema-references User.name --json"
    )]
    FindReferences(AnalyzeFindReferencesCommand),

    /// Print one transformed operation with all reachable fragments inlined into the output.
    #[clap(
        name = "print-operation",
        about = "Print the executable GraphQL text for one named Relay operation.",
        long_about = "\
Print the executable GraphQL text for one named Relay operation.

Use this when you want to inspect the exact executable operation Relay produces after pulling in reachable fragments and inlining the Relay-managed pieces into the final GraphQL text.
Good fit: debugging the final query shape, sharing the full runnable GraphQL text in a review, or comparing two operations with similar names.
Not a good fit: use `find-schema-references` for impact analysis, or `definition-audit` to scan many operations/fragments at once.

Examples:
  relay tools print-operation UserProfileQuery
  relay tools print-operation UserProfileQuery --json"
    )]
    PrintOperation(AnalyzePrintOperationCommand),

    /// Find which operations and fragments depend on a fragment before changing it.
    #[clap(
        name = "fragment-dependents",
        about = "Find direct or transitive dependents of a fragment.",
        long_about = "\
Find direct or transitive dependents of a fragment.

Use this when you are changing a fragment and need to understand its blast radius before editing or deleting it.
Good fit: see which operations will change if `UserCard_user` changes, or walk the full dependency chain with `--transitive`.
Not a good fit: use `find-schema-references` for schema field usage, or `rename-fragment` when you already know you want a mechanical rename.

Examples:
  relay tools fragment-dependents UserCard_user
  relay tools fragment-dependents UserCard_user --transitive
  relay tools fragment-dependents UserCard_user --with-snippet --json"
    )]
    FragmentDependents(AnalyzeFragmentDependentsCommand),

    /// Find deprecated schema usage to plan or verify migrations.
    #[clap(
        name = "deprecated-usage",
        about = "Find deprecated schema usage to plan or verify migrations.",
        long_about = "\
Find deprecated fields, arguments, and directives in executable definitions.

Use this when you are preparing a schema cleanup, auditing migration work, or verifying that deprecations are gone from Relay documents.
Good fit: enumerate every deprecated field still in use before deleting it from the schema.
Not a good fit: use `find-schema-references` for one specific field, or `unused-schema-members` for schema members that are never used at all.

Examples:
  relay tools deprecated-usage
  relay tools deprecated-usage --limit 200
  relay tools deprecated-usage --json"
    )]
    DeprecatedUsage(AnalyzeDeprecatedUsageCommand),

    /// Find fragments that are not reachable from any operation.
    #[clap(
        name = "unused-fragments",
        about = "Find fragments that are not reachable from any operation.",
        long_about = "\
Find fragment definitions that are not reachable from any operation.

Use this when you want to clean up dead Relay code after feature removal or confirm that a fragment is no longer part of any shipped query path.
Good fit: identify fragments that can likely be deleted or reviewed for removal.
Not a good fit: use `fragment-spread-usage` to rank fragments by spread count, because low usage and unused are not the same thing.

Examples:
  relay tools unused-fragments
  relay tools unused-fragments --limit 50
  relay tools unused-fragments --json"
    )]
    UnusedFragments(AnalyzeUnusedFragmentsCommand),

    /// Rank fragments by spread count to spot shared hot spots or low-value fragments.
    #[clap(
        name = "fragment-spread-usage",
        about = "List fragments sorted by fragment spread usage count.",
        long_about = "\
List fragments sorted by spread usage count.

Use this when you want to find heavily shared fragments that may be doing too much, or lightly used fragments that may not justify their abstraction.
Good fit: rank fragments to spot refactor hot spots, shared leaf fragments, or candidates to inline.
Not a good fit: use `unused-fragments` for deletion safety, because a fragment can have usages and still be unreachable from any operation.

Examples:
  relay tools fragment-spread-usage
  relay tools fragment-spread-usage --sort usage-asc --min-usage 1
  relay tools fragment-spread-usage --limit 25 --json"
    )]
    FragmentUsage(AnalyzeFragmentUsageCommand),

    /// Rename a fragment definition and all spread sites when the change is mechanical.
    #[clap(
        name = "rename-fragment",
        about = "Rename a fragment definition and all of its spread sites.",
        long_about = "\
Rename a fragment definition and all of its spread sites.

Use this when the change is a mechanical rename and you want Relay-aware updates across the codebase.
Good fit: renaming `UserInfo_user` to `UserProfile_user`, especially with `--dry-run` first to inspect the edit set.
Important: this renames the fragment definition and spread sites, but it does not rename the source file. If your project expects fragment names and filenames to stay aligned, you must rename the file too or the result will likely be invalid.
Not a good fit: do not use this for semantic refactors such as splitting a fragment, changing its type condition, or redesigning ownership boundaries.

Examples:
  relay tools rename-fragment UserInfo_user UserProfile_user --dry-run
  relay tools rename-fragment UserInfo_user UserProfile_user
  relay tools rename-fragment UserInfo_user UserProfile_user --json"
    )]
    RenameFragment(AnalyzeRenameFragmentCommand),

    /// Find schema fields and union members unused by Relay documents in this project.
    #[clap(
        name = "unused-schema-members",
        about = "Find schema fields and union members unused by Relay documents.",
        long_about = "\
Find schema fields and union members unused by Relay documents.

Use this when you are auditing schema surface area from the Relay client's point of view and want cleanup candidates.
Good fit: find fields that no Relay operation or fragment in this project references before proposing schema deletions.
Not a good fit: this is not proof that other clients, servers, or future work do not need a field, so treat it as Relay-specific evidence.

Examples:
  relay tools unused-schema-members
  relay tools unused-schema-members --limit 25
  relay tools unused-schema-members --json"
    )]
    SchemaDce(AnalyzeSchemaDceCommand),

    /// Find large or deeply nested operations/fragments that are refactor candidates.
    #[clap(
        name = "definition-audit",
        about = "Audit operations and fragments by selection size or nesting depth.",
        long_about = "\
Find operations and fragments by selection size or nesting depth.

Use this when you want to scan a codebase for oversized executable definitions that may need refactoring.
Good fit: go through all fragments and flag ones that are too large or too deeply nested; large matches are often opportunities to split work into smaller, more focused components.
Not a good fit: this is a structural heuristic, not a runtime cost model, so do not treat it as an exact performance measurement.

Examples:
  relay tools definition-audit --min-selection-lines 40
  relay tools definition-audit --min-selection-depth 5
  relay tools definition-audit --min-selection-lines 30 --min-selection-depth 4 --json"
    )]
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
