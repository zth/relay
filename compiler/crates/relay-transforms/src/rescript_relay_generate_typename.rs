/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

use crate::util::{is_relay_custom_inline_fragment_directive, PointerAddress};
use common::{Location, WithLocation};
use fnv::FnvHashMap;
use graphql_ir::{
    FragmentDefinition, FragmentSpread, InlineFragment, LinkedField, OperationDefinition, Program,
    ScalarField, Selection, Transformed, TransformedValue, Transformer,
};

use schema::{SDLSchema, Schema, Type};
use std::sync::Arc;

/// Transform to add the `__typename` field to any LinkedField that both a) returns an
/// abstract type and b) does not already directly query `__typename`.
pub fn rescript_relay_generate_typename(program: &Program) -> Program {
    let mut transform = RescriptRelayGenerateTypenameTransform::new(program);
    transform
        .transform_program(program)
        .replace_or_else(|| program.clone())
}

// Note on correctness: the PointerAddress here is calculated from addresses of the input
// context. Because those value are still referenced, that memory cannot be freed/
// reused for the lifetime of the transform.
type Seen = FnvHashMap<PointerAddress, Transformed<Selection>>;

struct RescriptRelayGenerateTypenameTransform<'s> {
    program: &'s Program,
    seen: Seen,
    parent_type: Option<Type>,
}

impl<'s> RescriptRelayGenerateTypenameTransform<'s> {
    fn new(program: &'s Program) -> Self {
        Self {
            program,
            seen: Default::default(),
            parent_type: None,
        }
    }
}

impl<'s> Transformer for RescriptRelayGenerateTypenameTransform<'s> {
    const NAME: &'static str = "RescriptRelayGenerateTypenameTransform";
    const VISIT_ARGUMENTS: bool = false;
    const VISIT_DIRECTIVES: bool = false;

    fn transform_operation(
        &mut self,
        operation: &OperationDefinition,
    ) -> Transformed<OperationDefinition> {
        self.parent_type = Some(operation.type_);
        self.default_transform_operation(operation)
    }

    fn transform_fragment(
        &mut self,
        fragment: &FragmentDefinition,
    ) -> Transformed<FragmentDefinition> {
        self.parent_type = Some(fragment.type_condition);
        let schema = &self.program.schema;
        let mut selections = self.transform_selections(&fragment.selections);
        let type_ = fragment.type_condition;
        if !schema.is_extension_type(type_) && type_.is_abstract_type() {
            let mut next_selections = Vec::with_capacity(fragment.selections.len() + 1);
            next_selections.push(generate_abstract_key_field(schema, fragment.name.location));
            if let TransformedValue::Replace(selections) = selections {
                next_selections.extend(selections.into_iter())
            } else {
                next_selections.extend(fragment.selections.iter().cloned())
            };
            selections = TransformedValue::Replace(next_selections);
        }
        match selections {
            TransformedValue::Keep => Transformed::Keep,
            TransformedValue::Replace(selections) => Transformed::Replace(FragmentDefinition {
                selections,
                ..fragment.clone()
            }),
        }
    }

    fn transform_linked_field(&mut self, field: &LinkedField) -> Transformed<Selection> {
        let schema = &self.program.schema;
        let field_definition = schema.field(field.definition.item);
        let parent_type = self.parent_type;
        self.parent_type = Some(field_definition.type_.inner());
        let selections = self.transform_selections(&field.selections);
        self.parent_type = parent_type;
        let is_abstract = field_definition.type_.inner().is_abstract_type();
        let selections = if is_abstract && !has_typename_field(schema, &field.selections) {
            let mut next_selections = Vec::with_capacity(field.selections.len() + 1);
            next_selections.push(Selection::ScalarField(Arc::new(ScalarField {
                alias: None,
                definition: WithLocation::new(field.definition.location, schema.typename_field()),
                arguments: Default::default(),
                directives: Default::default(),
            })));
            if let TransformedValue::Replace(selections) = selections {
                next_selections.extend(selections.into_iter())
            } else {
                next_selections.extend(field.selections.iter().cloned());
            }
            TransformedValue::Replace(next_selections)
        } else {
            selections
        };
        match selections {
            TransformedValue::Keep => Transformed::Keep,
            TransformedValue::Replace(selections) => {
                Transformed::Replace(Selection::LinkedField(Arc::new(LinkedField {
                    alias: field.alias,
                    definition: field.definition,
                    arguments: field.arguments.clone(),
                    directives: field.directives.clone(),
                    selections,
                })))
            }
        }
    }

    fn transform_inline_fragment(&mut self, fragment: &InlineFragment) -> Transformed<Selection> {
        let key = PointerAddress::new(fragment);
        if let Some(prev) = self.seen.get(&key) {
            return prev.clone();
        }
        self.seen.insert(key, Transformed::Delete);
        let parent_type = self.parent_type;
        if fragment.type_condition.is_some() {
            self.parent_type = fragment.type_condition;
        }
        let mut selections = self.transform_selections(&fragment.selections);
        self.parent_type = parent_type;
        let schema = &self.program.schema;
        let type_ = if let Some(type_) = fragment.type_condition {
            type_
        } else {
            parent_type.expect("Expect the parent type to exist.")
        };
        if !fragment
            .directives
            .iter()
            .any(is_relay_custom_inline_fragment_directive)
            && !schema.is_extension_type(type_)
            && type_.is_abstract_type()
        {
            let mut next_selections = Vec::with_capacity(fragment.selections.len() + 1);
            next_selections.push(generate_abstract_key_field(schema, Location::generated()));
            if let TransformedValue::Replace(selections) = selections {
                next_selections.extend(selections.into_iter())
            } else {
                next_selections.extend(fragment.selections.iter().cloned())
            };
            selections = TransformedValue::Replace(next_selections);
        }
        let result = match selections {
            TransformedValue::Keep => Transformed::Keep,
            TransformedValue::Replace(selections) => {
                Transformed::Replace(Selection::InlineFragment(Arc::new(InlineFragment {
                    type_condition: fragment.type_condition,
                    directives: fragment.directives.clone(),
                    selections,
                })))
            }
        };
        self.seen.insert(key, result.clone());
        result
    }

    fn transform_scalar_field(&mut self, _field: &ScalarField) -> Transformed<Selection> {
        Transformed::Keep
    }

    fn transform_fragment_spread(&mut self, _spread: &FragmentSpread) -> Transformed<Selection> {
        Transformed::Keep
    }
}

fn has_typename_field(schema: &SDLSchema, selections: &[Selection]) -> bool {
    let typename_field = schema.typename_field();
    selections.iter().any(|x| match x {
        Selection::ScalarField(child) => {
            child.alias.is_none() && child.definition.item == typename_field
        }
        _ => false,
    })
}

fn generate_abstract_key_field(schema: &SDLSchema, location: Location) -> Selection {
    Selection::ScalarField(Arc::new(ScalarField {
        alias: None,
        definition: WithLocation::new(location, schema.typename_field()),
        arguments: vec![],
        directives: vec![],
    }))
}
