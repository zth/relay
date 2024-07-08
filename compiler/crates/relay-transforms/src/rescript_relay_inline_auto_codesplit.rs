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
use schema::Schema;

use graphql_ir::{
    reexport::{Intern, StringKey}, Argument, ConstantValue, Directive, FragmentSpread, LinkedField, Program, Selection, Transformed, Transformer, Value, Variable
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

    // Inline child fragment spread auto codesplit directives of linked fields on the linked field itself.
    // Only relevant for fields that are objects, interfaces/unions are handled elsewhere.
    fn transform_linked_field(&mut self, field: &LinkedField) -> Transformed<Selection> {
        if !self.program.schema.field(field.definition.item).type_.inner().is_object() {
            return self.default_transform_linked_field(field)
        }

        let mut directives = vec![];

        find_fragment_spreads(&field.selections, &mut directives, None);

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

fn find_fragment_spreads(selections: &Vec<Selection>, directives: &mut Vec<Directive>, variable_condition: Option<StringKey>) -> () {
    selections.iter().for_each(|s| {
        match s {
            Selection::Condition(condition) => {
                find_fragment_spreads(&condition.selections, directives, match condition.value {
                    graphql_ir::ConditionValue::Variable(Variable {name, ..}) => Some(name.item.0),
                    graphql_ir::ConditionValue::Constant(_) => None
                });
            },
            Selection::FragmentSpread(spread) => {
                if let Some(auto_codesplit_directive) = spread.directives.iter().find(|d| d.name.item.0 == *FRAGMENT_SPREAD_AUTO_CODESPLIT) {
                    let mut arguments = auto_codesplit_directive.arguments.clone();
                    arguments.push(Argument {
                        name: common::WithLocation { location: Location::generated(), item: ArgumentName("fragmentName".intern()) },
                        value: common::WithLocation { location: Location::generated(), item: Value::Constant(ConstantValue::String(spread.fragment.item.0)) }
                    });

                    if variable_condition.is_some() {
                        arguments.push(Argument {
                            name: common::WithLocation { location: Location::generated(), item: ArgumentName("variableCondition".intern()) },
                            value: common::WithLocation { location: Location::generated(), item: Value::Constant(ConstantValue::String(variable_condition.unwrap())) }
                        });
                    }
                    let directive = Directive {
                        arguments,
                        ..auto_codesplit_directive.clone()
                    };
                    directives.push(directive);
                }
            },
            _ => ()
        }
    });
}
