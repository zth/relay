/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

use std::sync::Arc;

use common::{ArgumentName, Location};
use itertools::Itertools;
use lazy_static::lazy_static;

use graphql_ir::{
    reexport::{Intern, StringKey}, Argument, Directive, FragmentDefinition, FragmentSpread, InlineFragment, LinkedField, OperationDefinition, Program, ScalarField, Selection, Transformed, Transformer
};

pub fn rescript_relay_inline_auto_codesplit(program: &Program) -> Program {
    let mut transform = RescriptRelayInlineAutoCodesplitTransform::new(program);
    transform
        .transform_program(program)
        .replace_or_else(|| program.clone())
}

lazy_static! {
    static ref FRAGMENT_SPREAD_AUTO_CODESPLIT: StringKey =
        "autoCodesplit".intern();
}

#[allow(dead_code)]
struct RescriptRelayInlineAutoCodesplitTransform<'s> {
    program: &'s Program,
}

#[allow(dead_code)]
impl<'s> RescriptRelayInlineAutoCodesplitTransform<'s> {
    fn new(program: &'s Program) -> Self {
        Self { program }
    }
}

impl<'s> Transformer for RescriptRelayInlineAutoCodesplitTransform<'s> {
    const NAME: &'static str = "RescriptRelayInlineAutoCodesplitTransform";
    const VISIT_ARGUMENTS: bool = false;
    const VISIT_DIRECTIVES: bool = true;

    fn transform_operation(
        &mut self,
        operation: &OperationDefinition,
    ) -> Transformed<OperationDefinition> {
        self.default_transform_operation(operation)
    }

    fn transform_fragment(
        &mut self,
        fragment: &FragmentDefinition,
    ) -> Transformed<FragmentDefinition> {
        self.default_transform_fragment(fragment)
    }

    fn transform_linked_field(&mut self, field: &LinkedField) -> Transformed<Selection> {
        self.default_transform_linked_field(field)
    }

    fn transform_inline_fragment(&mut self, fragment: &InlineFragment) -> Transformed<Selection> {
        self.default_transform_inline_fragment(fragment)
    }

    fn transform_scalar_field(&mut self, field: &ScalarField) -> Transformed<Selection> {
        self.default_transform_scalar_field(field)
    }

    fn transform_fragment_spread(&mut self, spread: &FragmentSpread) -> Transformed<Selection> {
        if spread.directives.iter().find(|d| d.name.item.0 == *FRAGMENT_SPREAD_AUTO_CODESPLIT).is_some() {
            Transformed::Replace(Selection::FragmentSpread(Arc::new(FragmentSpread {
                directives: spread.directives.iter().map(|d| if d.name.item.0 == *FRAGMENT_SPREAD_AUTO_CODESPLIT {
                    let mut arguments = d.arguments.clone();
                    arguments.push(Argument {
                        name: common::WithLocation { location: Location::generated(), item: ArgumentName("fragmentName".intern()) },
                        value: common::WithLocation { location: Location::generated(), item: graphql_ir::Value::Constant(graphql_ir::ConstantValue::String(spread.fragment.item.0)) }
                    });
                    let directive = Directive {
                        arguments,
                        ..d.clone()
                    };
                    directive
                } else {
                    d.clone()
                }).collect_vec(),
                ..spread.clone()
            })))
        } else {
            self.default_transform_fragment_spread(spread)
        }
    }
}
