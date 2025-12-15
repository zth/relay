/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

use fixture_tests::Fixture;
use graphql_test_helpers::apply_transform_for_test;
use intern::string_key::Intern;
use relay_config::ProjectConfig;
use relay_transforms::validate_exhaustive_directive;

pub async fn transform_fixture(fixture: &Fixture<'_>) -> Result<String, String> {
    apply_transform_for_test(fixture, |program| {
        let auto_exhaustive_types = if fixture.file_name.contains("auto-type")
            || fixture.file_name.contains("inline-fragment-auto-type")
        {
            vec!["UserNameRenderer".intern()]
        } else {
            vec![]
        };
        let project_config = ProjectConfig {
            auto_exhaustive_mutations: true,
            auto_exhaustive_types,
            ..Default::default()
        };
        validate_exhaustive_directive(program, &project_config)?;
        Ok(program.clone())
    })
}
