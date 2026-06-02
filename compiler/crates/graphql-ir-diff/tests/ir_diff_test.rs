/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

use std::fmt;
use std::sync::Arc;

use graphql_ir_diff::NormalizedDifferenceFormatter;
use graphql_ir_diff::NormalizedSelectionFormatter;
use graphql_ir_diff::NormalizedTree;
use graphql_ir_diff::collect_normalized_tree;
use graphql_ir_diff::parse;
use indoc::indoc;
use intern::Lookup;
use pretty_assertions::assert_eq;
use schema::SDLSchema;
use schema::Schema;
use schema::build_schema;

// for visualization in tests
pub struct NormalizedTreeFormatter<'a> {
    tree: &'a NormalizedTree,
    schema: Arc<SDLSchema>,
}

impl<'a> NormalizedTreeFormatter<'a> {
    fn print_tree(
        &self,
        f: &mut fmt::Formatter<'_>,
        sel: &NormalizedTree,
        depth: usize,
    ) -> fmt::Result {
        let indent = "  ".repeat(depth);
        match sel {
            NormalizedTree::Node {
                selection,
                children,
            } => {
                writeln!(
                    f,
                    "{}{} {{",
                    indent,
                    NormalizedSelectionFormatter {
                        schema: self.schema.clone(),
                        selection
                    }
                )?;
                for tree in children.borrow().iter() {
                    self.print_tree(f, tree, depth + 1)?;
                }
                writeln!(f, "{}}}", indent)?;
            }
            NormalizedTree::Leaf {
                selection,
                possible_object_types,
            } => {
                let mut possible_object_type_names: Vec<_> = possible_object_types
                    .borrow()
                    .iter()
                    .map(|id| self.schema.object(*id).name.item.0.lookup())
                    .collect();
                possible_object_type_names.sort();
                writeln!(
                    f,
                    "{}{} on {{{}}}",
                    indent,
                    NormalizedSelectionFormatter {
                        schema: self.schema.clone(),
                        selection
                    },
                    possible_object_type_names.join(", "),
                )?;
            }
        }
        Ok(())
    }
}

impl<'a> fmt::Display for NormalizedTreeFormatter<'a> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        self.print_tree(f, self.tree, 0)
    }
}

const SCHEMA_STR: &str = r#"
    type Query {
        test_i: I!
        test_j: J!
        test_u: U!
        test_v: V!
        test_a(input_arg: Input, int_arg: Int): Int!
    }

    interface I {
        id: ID!
        data(arg: Int!): String!
    }

    interface J {
        id: ID!
        data(arg: Int!): String!
        object(id: ID!): J!
    }

    type R implements I & J {
        id: ID!
        data(arg: Int!): String!
        object(id: ID!): J!
        r: Int!
    }

    type S implements I & J {
        id: ID!
        data(arg: Int!): String!
        object(id: ID!): J!
        s: Int!
    }

    type T implements I {
        id: ID!
        data(arg: Int!): String!
        t: Int!
    }

    type X implements J {
        id: ID!
        data(arg: Int!): String!
        object(id: ID!): J!
        x: String!
    }

    type Y {
        id: ID!
        y: String!
    }

    type Z implements J {
        id: ID!
        data(arg: Int!): String!
        object(id: ID!): J!
        z: String!
    }

    union U = R | S | X
    union V = R | S | Y

    input InnerInput {
        string_arg: String
    }

    input Input {
        int_arg: Int
        object_arg: InnerInput
        list_arg: [Int]
    }
    "#;

fn build_test_schema() -> Arc<SDLSchema> {
    Arc::new(build_schema(SCHEMA_STR).expect("Failed to build test schema"))
}

fn assert_selection_eq(schema: Arc<SDLSchema>, executable: &str, expected: &str) {
    let actual = collect_normalized_tree(&parse(schema.clone(), executable).unwrap());
    let fmt = NormalizedTreeFormatter {
        schema,
        tree: &actual,
    };
    let actual = format!("{}", fmt);

    assert_eq!(actual, expected);
}

fn assert_difference_eq(schema: Arc<SDLSchema>, this: &str, that: &str, expected: Vec<&str>) {
    let this = collect_normalized_tree(&parse(schema.clone(), this).unwrap());
    let that = collect_normalized_tree(&parse(schema.clone(), that).unwrap());
    assert_eq!(
        this.subtract(&that)
            .iter()
            .map(|diff| NormalizedDifferenceFormatter {
                schema: schema.clone(),
                diff,
            }
            .to_string())
            .collect::<Vec<_>>(),
        expected
    );
}

#[test]
fn test_field_normalization() {
    let schema = build_test_schema();
    // all cases normalized to this form
    let expected = indoc! {"
        query {
          test_i {
            id on {R, S, T}
          }
        }
    "};

    let simple = r#"
        query {
            test_i {
                id
            }
        }
    "#;
    assert_selection_eq(schema.clone(), simple, expected);

    let inlining = r#"
        query {
            test_i {
                ... TestI
            }
        }
        fragment TestI on I {
            id
        }
    "#;
    assert_selection_eq(schema.clone(), inlining, expected);

    let flattening = r#"
        query {
            test_i {
                id
                ... on I {
                    id
                }
            }
        }
    "#;
    assert_selection_eq(schema.clone(), flattening, expected);

    let deduping = r#"
        query {
            test_i {
                id
                id
            }
        }
    "#;
    assert_selection_eq(schema.clone(), deduping, expected);

    let dealiasing = r#"
        query {
            test_i {
                user_id: id
                account_id: id
            }
        }
    "#;
    assert_selection_eq(schema.clone(), dealiasing, expected);
}

#[test]
fn test_type_condition_normalization() {
    let schema = build_test_schema();

    let distinct_concrete_conditions = r#"
        query {
            test_i {
                ... on R {
                    data(arg: 0)
                }
                ... on S {
                    data(arg: 0)
                }
            }
        }
    "#;
    assert_selection_eq(
        schema.clone(),
        distinct_concrete_conditions,
        indoc! {"
        query {
          test_i {
            data(arg: 0) on {R, S}
          }
        }
    "},
    );

    let equivalent_abstract_intersections = r#"
        query {
            test_u {
                ... on I {
                    ... on J { # U ^ I ^ J = {R, S}
                        data(arg: 0)
                    }
                }
                ... on J {
                    ... on I { # U ^ J ^ I = {R, S}
                        data(arg: 0)
                    }
                }
                ... on I { # U ^ I = {R, S}
                    data(arg: 0)
                }
            }
        }
    "#;
    assert_selection_eq(
        schema.clone(),
        equivalent_abstract_intersections,
        indoc! {"
        query {
          test_u {
            data(arg: 0) on {R, S}
          }
        }
    "},
    );
}

#[test]
fn test_subtraction_without_differences() {
    let schema = build_test_schema();
    // all cases normalized to subset of this.
    let superset = r#"
        query {
            test_i {
                id
                data(arg: 0)
            }
        }
    "#;

    let identical = r#"
        query {
            test_i {
                id
                data(arg: 0)
            }
        }
    "#;
    assert_difference_eq(schema.clone(), identical, superset, vec![]);

    let identical_except_name = r#"
        query GraphMateGenerated {
            test_i {
                id
                data(arg: 0)
            }
        }
    "#;
    assert_difference_eq(schema.clone(), identical_except_name, superset, vec![]);

    let identical_after_dealiasing = r#"
        query {
            test_i {
                my: id
                data(arg: 0)
            }
        }
    "#;
    assert_difference_eq(schema.clone(), identical_after_dealiasing, superset, vec![]);

    let identical_after_inlining = r#"
        query {
            test_i {
                ... ID
                ... Data
            }
        }
        fragment ID on I {
            id
        }
        fragment Data on I {
            data(arg: 0)
        }
    "#;
    assert_difference_eq(schema.clone(), identical_after_inlining, superset, vec![]);

    let smaller_selection = r#"
        query {
            test_i {
                id
            }
        }
    "#;
    assert_difference_eq(schema.clone(), smaller_selection, superset, vec![]);

    let smaller_type_conditions = r#"
        query {
            test_i {
                id
                ... on R {
                    data(arg: 0)
                }
            }
        }
    "#;
    assert_difference_eq(schema.clone(), smaller_type_conditions, superset, vec![]);
}

#[test]
fn test_subtraction_without_differences_on_field_with_all_variable_arguments() {
    let schema = build_test_schema();
    // all cases normalized to subset of this.
    let superset = r#"
        query($input_arg: Input, $int_arg: Int) {
            test_a(input_arg: $input_arg, int_arg: $int_arg)
        }
    "#;

    let identical = r#"
        query($input_arg: Input, $int_arg: Int) {
            test_a(input_arg: $input_arg, int_arg: $int_arg)
        }
    "#;
    assert_difference_eq(schema.clone(), identical, superset, vec![]);

    let renamed_arguments = r#"
        query($input: Input, $int: Int) {
            test_a(input_arg: $input, int_arg: $int)
        }
    "#;
    assert_difference_eq(schema.clone(), renamed_arguments, superset, vec![]);

    let fewer_arguments = r#"
        query($int_arg: Int) {
            test_a(int_arg: $int_arg)
        }
    "#;
    assert_difference_eq(schema.clone(), fewer_arguments, superset, vec![]);

    let partial_constant_argument_1 = r#"
        query($inner_input_arg: InnerInput) {
            test_a(input_arg: {object_arg: $inner_input_arg})
        }
    "#;
    assert_difference_eq(
        schema.clone(),
        partial_constant_argument_1,
        superset,
        vec![],
    );

    let partial_constant_argument_2 = r#"
        query($string_arg: String) {
            test_a(input_arg: {object_arg: {string_arg: $string_arg}})
        }
    "#;
    assert_difference_eq(
        schema.clone(),
        partial_constant_argument_2,
        superset,
        vec![],
    );

    let constant_argument = r#"
        query {
            test_a(input_arg: {object_arg: {string_arg: "foo"}})
        }
    "#;
    assert_difference_eq(schema.clone(), constant_argument, superset, vec![]);
}

#[test]
fn test_subtraction_on_field_with_partial_constant_arguments() {
    let schema = build_test_schema();
    // all cases normalized to subset of this.
    let superset = r#"
        query Foo($inner_input_arg: InnerInput) {
            test_a(input_arg: {object_arg: $inner_input_arg})
        }
    "#;

    let identical = r#"
        query($inner_input_arg: InnerInput) {
            test_a(input_arg: {object_arg: $inner_input_arg})
        }
    "#;
    assert_difference_eq(schema.clone(), identical, superset, vec![]);

    let partial_constant_argument = r#"
        query($string_arg: String) {
            test_a(input_arg: {object_arg: {string_arg: $string_arg}})
        }
    "#;
    assert_difference_eq(schema.clone(), partial_constant_argument, superset, vec![]);

    let constant_argument = r#"
        query {
            test_a(input_arg: {object_arg: {string_arg: "foo"}})
        }
    "#;
    assert_difference_eq(schema.clone(), constant_argument, superset, vec![]);

    // variable argument too "wide" for selection on test_a to be considered a subset
    let variable_argument = r#"
        query($input_arg: Input) {
            test_a(input_arg: $input_arg)
        }
    "#;
    assert_difference_eq(
        schema.clone(),
        variable_argument,
        superset,
        vec!["query -> test_a(input_arg: $input_arg)"],
    );
}

#[test]
fn test_subtraction_on_field_with_list_arguments() {
    let schema = build_test_schema();
    // all cases normalized to subset of this.
    let superset = r#"
        query Foo($int_arg_1: Int, $int_arg_2: Int) {
            test_a(input_arg: {list_arg: [$int_arg_1, $int_arg_2, 3]})
        }
    "#;

    let partial_list_argument = r#"
        query ($int_arg: Int) {
            test_a(input_arg: {list_arg: [1, $int_arg, 3]})
        }
    "#;
    assert_difference_eq(schema.clone(), partial_list_argument, superset, vec![]);

    let constant_list_argument = r#"
        query {
            test_a(input_arg: {list_arg: [1, 2, 3]})
        }
    "#;
    assert_difference_eq(schema.clone(), constant_list_argument, superset, vec![]);

    // variable argument too "wide" for selection on test_a to be considered a subset
    let variable_argument = r#"
        query($input_list_arg: [Int]) {
            test_a(input_arg: {list_arg: $input_list_arg})
        }
    "#;
    assert_difference_eq(
        schema.clone(),
        variable_argument,
        superset,
        vec!["query -> test_a(input_arg: {list_arg: $input_list_arg})"],
    );

    // literal list too small
    let smaller_list_argument = r#"
        query {
            test_a(input_arg: {list_arg: [1]})
        }
    "#;
    assert_difference_eq(
        schema.clone(),
        smaller_list_argument,
        superset,
        vec!["query -> test_a(input_arg: {list_arg: [1]})"],
    );
}

#[test]
fn test_subtraction_with_differences() {
    let schema = build_test_schema();
    // all cases normalized to superset of this
    let subset = r#"
        query {
            test_i {
                ... on R {
                  id
                }
            }
        }
    "#;

    let extra_scalar = r#"
        query {
            test_i {
                ... on R {
                  id
                }
                data(arg: 0)
            }
        }
    "#;
    assert_difference_eq(
        schema.clone(),
        extra_scalar,
        subset,
        vec!["query -> test_i -> data(arg: 0)"],
    );

    let extra_type_condition = r#"
        query {
            test_i {
                ... on R {
                  id
                }
                ... on S {
                  id
                }
            }
        }
    "#;
    assert_difference_eq(
        schema.clone(),
        extra_type_condition,
        subset,
        vec!["query -> test_i -> id on {S}"],
    );

    let extra_linked_field = r#"
        query {
            test_i {
                ... on R {
                  id
                }
            }
            test_j {
                id
            }
        }
    "#;
    assert_difference_eq(
        schema.clone(),
        extra_linked_field,
        subset,
        vec!["query -> test_j"],
    );
}
