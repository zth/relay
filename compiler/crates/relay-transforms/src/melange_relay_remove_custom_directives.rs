/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

use std::sync::Arc;

use common::DirectiveName;
use lazy_static::lazy_static;

use graphql_ir::{
    reexport::{Intern, StringKey},
    Directive, FragmentDefinition, FragmentSpread, InlineFragment, LinkedField,
    OperationDefinition, Program, ScalarField, Selection, Transformed, Transformer,
};

pub fn melange_relay_remove_custom_directives(program: &Program) -> Program {
    let mut transform = MelangeRelayRemoveCustomDirectivesTransform::new(program);
    transform
        .transform_program(program)
        .replace_or_else(|| program.clone())
}

lazy_static! {
    static ref FRAGMENT_DIRECTIVE_IGNORE_UNUSED: StringKey = "melangeRelayIgnoreUnused".intern();
    static ref OPERATION_DIRECTIVE_NULLABLE_VARIABLES: StringKey =
        "melangeRelayNullableVariables".intern();
    static ref FIELD_DIRECTIVE_ALLOW_UNSAFE_ENUM: StringKey =
        "melangeRelayAllowUnsafeEnum".intern();
}

#[allow(dead_code)]
struct MelangeRelayRemoveCustomDirectivesTransform<'s> {
    program: &'s Program,
}

#[allow(dead_code)]
impl<'s> MelangeRelayRemoveCustomDirectivesTransform<'s> {
    fn new(program: &'s Program) -> Self {
        Self { program }
    }
}

impl<'s> Transformer for MelangeRelayRemoveCustomDirectivesTransform<'s> {
    const NAME: &'static str = "MelangeRelayRemoveCustomDirectivesTransform";
    const VISIT_ARGUMENTS: bool = false;
    const VISIT_DIRECTIVES: bool = false;

    fn transform_operation(
        &mut self,
        operation: &OperationDefinition,
    ) -> Transformed<OperationDefinition> {
        // TODO: Only replace if has directive?
        Transformed::Replace(OperationDefinition {
            directives: operation
                .directives
                .iter()
                .filter_map(|directive| {
                    if directive.name.item == DirectiveName(*OPERATION_DIRECTIVE_NULLABLE_VARIABLES) {
                        None
                    } else {
                        Some(directive.to_owned())
                    }
                })
                .collect::<Vec<Directive>>(),
            ..operation.clone()
        })
    }

    fn transform_fragment(
        &mut self,
        fragment: &FragmentDefinition,
    ) -> Transformed<FragmentDefinition> {
        // TODO: Only replace if has directive?
        Transformed::Replace(FragmentDefinition {
            directives: fragment
                .directives
                .iter()
                .filter_map(|directive| {
                    if directive.name.item == DirectiveName(*FRAGMENT_DIRECTIVE_IGNORE_UNUSED) {
                        None
                    } else {
                        Some(directive.to_owned())
                    }
                })
                .collect::<Vec<Directive>>(),
            ..fragment.clone()
        })
    }

    fn transform_linked_field(&mut self, _field: &LinkedField) -> Transformed<Selection> {
        Transformed::Keep
    }

    fn transform_inline_fragment(&mut self, _fragment: &InlineFragment) -> Transformed<Selection> {
        Transformed::Keep
    }

    fn transform_scalar_field(&mut self, field: &ScalarField) -> Transformed<Selection> {
        Transformed::Replace(Selection::ScalarField(Arc::new(ScalarField {
            directives: field
                .directives
                .iter()
                .filter_map(|directive| {
                    if directive.name.item == DirectiveName(*FIELD_DIRECTIVE_ALLOW_UNSAFE_ENUM) {
                        None
                    } else {
                        Some(directive.to_owned())
                    }
                })
                .collect::<Vec<Directive>>(),
            ..field.clone()
        })))
    }

    fn transform_fragment_spread(&mut self, _spread: &FragmentSpread) -> Transformed<Selection> {
        Transformed::Keep
    }
}
