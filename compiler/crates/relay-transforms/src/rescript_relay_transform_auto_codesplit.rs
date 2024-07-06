/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

use std::sync::Arc;

use common::{DirectiveName, NamedItem};
use lazy_static::lazy_static;

use graphql_ir::{
    reexport::{Intern, StringKey}, Directive, InlineFragment, Program, Selection, Transformed, Transformer
};

pub fn rescript_relay_transform_auto_codesplit(program: &Program) -> Program {
    let mut transform = RescriptRelayTransformAutoCodesplitTransform::new(program);
    transform
        .transform_program(program)
        .replace_or_else(|| program.clone())
}

lazy_static! {
    static ref FRAGMENT_SPREAD_AUTO_CODESPLIT: StringKey =
        "autoCodesplit".intern();
}

#[allow(dead_code)]
struct RescriptRelayTransformAutoCodesplitTransform<'s> {
    program: &'s Program,
}

#[allow(dead_code)]
impl<'s> RescriptRelayTransformAutoCodesplitTransform<'s> {
    fn new(program: &'s Program) -> Self {
        Self { program }
    }
}
// This transform recursively copies all relevant @autoCodesplit directives to the top-most inline fragment spread.
// This is because of internal Relay reasons, how the normalization AST is transformed and how we need it to look.
// All inline fragments will be flattened into the top-most one in an internal Relay transform that runs after this
// (flatten.rs). So, we need to make sure all relevant directives are copied onto the inline fragment that'll remain,
// or else they're gone in the inline transform and we can't figure out what to code split.
impl<'s> Transformer for RescriptRelayTransformAutoCodesplitTransform<'s> {
    const NAME: &'static str = "RescriptRelayTransformAutoCodesplitTransform";
    const VISIT_ARGUMENTS: bool = false;
    const VISIT_DIRECTIVES: bool = true;

    fn transform_inline_fragment(&mut self, fragment: &InlineFragment) -> Transformed<Selection> {
        let mut directives = vec![];

        extract_directives_from_nested_spreads(fragment, &mut directives);

        if directives.len() > 0 {
            fragment.directives.iter().for_each(|d| {
                directives.push(d.clone());
            });

            Transformed::Replace(Selection::InlineFragment(
                Arc::new(InlineFragment {
                    directives,
                    ..fragment.clone()
                })
            ))
        } else {
            self.default_transform_inline_fragment(fragment)
        }
    }
}

fn extract_directives_from_nested_spreads(fragment: &InlineFragment, directives: &mut Vec<Directive>) -> () {
    fragment.selections.iter().for_each(|s| {
        match &s {
            Selection::InlineFragment(inline_fragment) => {
                if inline_fragment.type_condition.is_some() && inline_fragment.type_condition == fragment.type_condition {
                    if let Some(auto_codesplit_directive) = inline_fragment.directives.named(DirectiveName(*FRAGMENT_SPREAD_AUTO_CODESPLIT)) {
                        directives.push(auto_codesplit_directive.clone());
                    }
                    extract_directives_from_nested_spreads(&inline_fragment, directives);
                }
            },
            _ => ()
        }
    });
}
