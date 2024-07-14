/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

use std::sync::Arc;

use common::{ArgumentName, Diagnostic, DiagnosticsResult, Location};
use itertools::Itertools;
use lazy_static::lazy_static;
use schema::Schema;

use graphql_ir::{
    reexport::{Intern, StringKey}, Argument, ConstantValue, Directive, FragmentSpread, LinkedField, Program, Selection, Transformed, Transformer, Value, Variable
};

use crate::{fragment_alias_directive::FRAGMENT_ALIAS_DIRECTIVE_NAME, ValidationMessageWithData};

pub fn rescript_relay_inline_codesplit(program: &Program) -> DiagnosticsResult<Program> {
    let mut transform = RescriptRelayInlineCodesplitTransform::new(program);
    let next_program = transform
        .transform_program(program)
        .replace_or_else(|| program.clone());

    if transform.errors.is_empty() {
        Ok(next_program)
    } else {
        Err(transform.errors)
    }
}

lazy_static! {
    static ref FRAGMENT_SPREAD_AUTO_CODESPLIT: StringKey =
        "codesplit".intern();
}

#[allow(dead_code)]
struct RescriptRelayInlineCodesplitTransform<'s> {
    program: &'s Program,
    errors: Vec<Diagnostic>,
}

#[allow(dead_code)]
impl<'s> RescriptRelayInlineCodesplitTransform<'s> {
    fn new(program: &'s Program) -> Self {
        Self { program, errors: Vec::new(), }
    }
}

impl<'s> Transformer for RescriptRelayInlineCodesplitTransform<'s> {
    const NAME: &'static str = "RescriptRelayInlineAutoCodesplitTransform";
    const VISIT_ARGUMENTS: bool = false;
    const VISIT_DIRECTIVES: bool = true;

    // Inline child fragment spread auto codesplit directives of linked fields on the linked field itself.
    // Only relevant for fields that are objects, interfaces/unions are handled elsewhere.
    fn transform_linked_field(&mut self, field: &LinkedField) -> Transformed<Selection> {
        if !self.program.schema.field(field.definition.item).type_.inner().is_object() {
            return self.default_transform_linked_field(field)
        }

        let mut directives = vec![];

        find_fragment_spreads(&field.selections, &mut self.errors, &mut directives, None);

        if directives.len() > 0 {
            field.directives.iter().for_each(|d| {
                directives.push(d.clone());
            });

            let selections = self.transform_selections(&field.selections);

            Transformed::Replace(Selection::LinkedField(Arc::new(LinkedField {
                directives,
                selections: selections.replace_or_else(|| field.selections.clone()),
                ..field.clone()
            })))
        } else {
            self.default_transform_linked_field(field)
        }
    }

    fn transform_fragment_spread(&mut self, spread: &FragmentSpread) -> Transformed<Selection> {
        if spread.directives.iter().find(|d| d.name.item.0 == *FRAGMENT_SPREAD_AUTO_CODESPLIT).is_some() {
            if !spread.directives.iter().find(|d| d.name.item == *FRAGMENT_ALIAS_DIRECTIVE_NAME).is_some() {
                self.errors.push(Diagnostic::error_with_data(
                    ValidationMessageWithData::ExpectedAliasWithAutoCodesplit,
                    spread.fragment.location,
                ));
            }
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

fn find_fragment_spreads(selections: &Vec<Selection>, errors: &mut Vec<Diagnostic>, directives: &mut Vec<Directive>, variable_condition: Option<(StringKey, bool)>) -> () {
    selections.iter().for_each(|s| {
        match s {
            Selection::Condition(condition) => {
                find_fragment_spreads(&condition.selections, errors, directives, match condition.value {
                    graphql_ir::ConditionValue::Variable(Variable {name, ..}) => Some((name.item.0, condition.passing_value)),
                    graphql_ir::ConditionValue::Constant(_) => None
                });
            },
            Selection::FragmentSpread(spread) => {
                if let Some(codesplit_directive) = spread.directives.iter().find(|d| d.name.item.0 == *FRAGMENT_SPREAD_AUTO_CODESPLIT) {
                    if !spread.directives.iter().find(|d| d.name.item == *FRAGMENT_ALIAS_DIRECTIVE_NAME).is_some() {
                        errors.push(Diagnostic::error_with_data(
                            ValidationMessageWithData::ExpectedAliasWithAutoCodesplit,
                            spread.fragment.location,
                        ));
                        return;
                    }
                    let mut arguments = codesplit_directive.arguments.clone();
                    arguments.push(Argument {
                        name: common::WithLocation { location: Location::generated(), item: ArgumentName("fragmentName".intern()) },
                        value: common::WithLocation { location: Location::generated(), item: Value::Constant(ConstantValue::String(spread.fragment.item.0)) }
                    });

                    if variable_condition.is_some() {
                        arguments.push(Argument {
                            name: common::WithLocation { location: Location::generated(), item: ArgumentName("variableCondition".intern()) },
                            value: common::WithLocation { location: Location::generated(), item: Value::Constant(ConstantValue::String(variable_condition.unwrap().0)) }
                        });

                        arguments.push(Argument {
                            name: common::WithLocation { location: Location::generated(), item: ArgumentName("variableConditionIsInclude".intern()) },
                            value: common::WithLocation { location: Location::generated(), item: Value::Constant(ConstantValue::Boolean(variable_condition.unwrap().1)) }
                        });
                    }
                    let directive = Directive {
                        arguments,
                        ..codesplit_directive.clone()
                    };
                    directives.push(directive);
                }
            },
            _ => ()
        }
    });
}
