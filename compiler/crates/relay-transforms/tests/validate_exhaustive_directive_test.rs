/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @generated SignedSource<<exhaustive>>
 */

mod validate_exhaustive_directive;

use validate_exhaustive_directive::transform_fixture;
use fixture_tests::test_fixture;

#[tokio::test]
async fn all_members_valid() {
    let input = include_str!("validate_exhaustive_directive/fixtures/all-members-valid.graphql");
    let expected = include_str!("validate_exhaustive_directive/fixtures/all-members-valid.expected");
    test_fixture(transform_fixture, file!(), "all-members-valid.graphql", "validate_exhaustive_directive/fixtures/all-members-valid.expected", input, expected).await;
}

#[tokio::test]
async fn ignore_member_valid() {
    let input = include_str!("validate_exhaustive_directive/fixtures/ignore-member-valid.graphql");
    let expected = include_str!("validate_exhaustive_directive/fixtures/ignore-member-valid.expected");
    test_fixture(
        transform_fixture,
        file!(),
        "ignore-member-valid.graphql",
        "validate_exhaustive_directive/fixtures/ignore-member-valid.expected",
        input,
        expected,
    )
    .await;
}

#[tokio::test]
async fn missing_member() {
    let input = include_str!("validate_exhaustive_directive/fixtures/missing-member.invalid.graphql");
    let expected = include_str!("validate_exhaustive_directive/fixtures/missing-member.invalid.expected");
    test_fixture(transform_fixture, file!(), "missing-member.invalid.graphql", "validate_exhaustive_directive/fixtures/missing-member.invalid.expected", input, expected).await;
}

#[tokio::test]
async fn directive_on_non_union() {
    let input = include_str!("validate_exhaustive_directive/fixtures/directive-on-non-union.invalid.graphql");
    let expected = include_str!("validate_exhaustive_directive/fixtures/directive-on-non-union.invalid.expected");
    test_fixture(transform_fixture, file!(), "directive-on-non-union.invalid.graphql", "validate_exhaustive_directive/fixtures/directive-on-non-union.invalid.expected", input, expected).await;
}

#[tokio::test]
async fn auto_mutation_valid() {
    let input = include_str!("validate_exhaustive_directive/fixtures/auto-mutation-valid.graphql");
    let expected = include_str!("validate_exhaustive_directive/fixtures/auto-mutation-valid.expected");
    test_fixture(
        transform_fixture,
        file!(),
        "auto-mutation-valid.graphql",
        "validate_exhaustive_directive/fixtures/auto-mutation-valid.expected",
        input,
        expected,
    )
    .await;
}

#[tokio::test]
async fn auto_mutation_missing_member() {
    let input = include_str!("validate_exhaustive_directive/fixtures/auto-mutation-missing.invalid.graphql");
    let expected = include_str!("validate_exhaustive_directive/fixtures/auto-mutation-missing.invalid.expected");
    test_fixture(
        transform_fixture,
        file!(),
        "auto-mutation-missing.invalid.graphql",
        "validate_exhaustive_directive/fixtures/auto-mutation-missing.invalid.expected",
        input,
        expected,
    )
    .await;
}

#[tokio::test]
async fn auto_mutation_non_exhaustive() {
    let input = include_str!("validate_exhaustive_directive/fixtures/auto-mutation-non-exhaustive.graphql");
    let expected = include_str!("validate_exhaustive_directive/fixtures/auto-mutation-non-exhaustive.expected");
    test_fixture(
        transform_fixture,
        file!(),
        "auto-mutation-non-exhaustive.graphql",
        "validate_exhaustive_directive/fixtures/auto-mutation-non-exhaustive.expected",
        input,
        expected,
    )
    .await;
}
