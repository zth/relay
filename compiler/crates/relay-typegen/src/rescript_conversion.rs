//! Lossless, versioned conversion metadata. Runtime preparation turns these
//! path entries into reusable converters; response traversal never joins paths.
use std::collections::BTreeMap;

use serde_json::Map;
use serde_json::Value;
use serde_json::json;

use crate::rescript_ast::ConverterInstructions;
use crate::rescript_ast::InstructionContainer;

// Provided variables arrive through a separate AST route. Keep every list
// wrapper, including lists of input objects and nullable nested lists.
pub(crate) fn list_depth(ast: &crate::writer::AST) -> usize {
    use crate::writer::AST;
    match ast {
        AST::Nullable(inner) | AST::NonNullable(inner) => list_depth(inner),
        AST::ReadOnlyArray(inner) => 1 + list_depth(inner),
        _ => 0,
    }
}

// Slots are local to one conversion context. Names remain in the generated
// callback table, but repeated plan entries only need the short slot ID.
#[derive(Clone, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub(crate) enum Callback {
    Scalar(String),
    Union(String),
}

pub(crate) type CallbackSlots = BTreeMap<Callback, usize>;

pub(crate) fn callback_slots(instructions: &[&InstructionContainer]) -> CallbackSlots {
    instructions
        .iter()
        .filter_map(|instruction| match &instruction.instruction {
            ConverterInstructions::ConvertCustomField(name, _) => {
                Some(Callback::Scalar(name.clone()))
            }
            ConverterInstructions::ConvertUnion(name) => Some(Callback::Union(name.clone())),
            _ => None,
        })
        .collect::<std::collections::BTreeSet<_>>()
        .into_iter()
        .enumerate()
        .map(|(id, callback)| (callback, id))
        .collect()
}

pub(crate) struct ConversionPlan {
    pub json: String,
    pub is_empty: bool,
}

pub(crate) fn write_plan(
    roots: Vec<(String, Vec<&InstructionContainer>)>,
    callbacks: &CallbackSlots,
) -> ConversionPlan {
    let mut output = BTreeMap::new();
    for (name, instructions) in roots {
        let mut entries: BTreeMap<Vec<String>, Map<String, Value>> = BTreeMap::new();
        for instruction in instructions {
            let entry = entries
                .entry(instruction.at_path[1..].to_vec())
                .or_default();
            let (key, value) = match &instruction.instruction {
                ConverterInstructions::ListDepth(depth) => ("list", json!(depth)),
                ConverterInstructions::ConvertCustomField(name, array) => {
                    if *array {
                        entry.entry("list").or_insert(json!(1));
                    }
                    (
                        "scalar",
                        json!(callbacks[&Callback::Scalar(name.clone())].to_string()),
                    )
                }
                ConverterInstructions::BlockTraversal(array) => {
                    if *array {
                        entry.entry("list").or_insert(json!(1));
                    }
                    ("opaque", json!(true))
                }
                ConverterInstructions::ConvertUnion(name) => (
                    "union",
                    json!(callbacks[&Callback::Union(name.clone())].to_string()),
                ),
                ConverterInstructions::RootObject(name) => ("reference", json!(name)),
                ConverterInstructions::HasFragments => ("fragments", json!(true)),
            };
            if key == "list" {
                let depth = entry
                    .get(key)
                    .and_then(Value::as_u64)
                    .unwrap_or(0)
                    .max(value.as_u64().unwrap());
                entry.insert(key.to_string(), json!(depth));
            } else {
                entry.insert(key.to_string(), value);
            }
        }
        // Generic nullable traversal already handles lists recursively. Explicit
        // depth is needed only at/above scalar, union, reference, opaque or
        // fragment operations. Keep those boundaries, omit plain-data hints.
        let mut needed_lists = std::collections::BTreeSet::new();
        for (path, entry) in &entries {
            if entry.keys().any(|key| key != "list") {
                for depth in 0..path.len() {
                    needed_lists.insert(path[..depth].to_vec());
                }
            }
        }
        entries.retain(|path, entry| {
            entry.len() != 1 || !entry.contains_key("list") || needed_lists.contains(path)
        });
        let entries = entries
            .into_iter()
            .map(|(path, mut entry)| {
                entry.insert("path".to_string(), json!(path));
                Value::Object(entry)
            })
            .collect::<Vec<_>>();
        output.insert(name, entries);
    }
    let is_empty = output.len() == 1 && output.get("__root").is_some_and(Vec::is_empty);
    ConversionPlan {
        json: json!({"version": 2, "roots": output}).to_string(),
        is_empty,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::rescript_ast::Context;
    fn at(path: &[&str], instruction: ConverterInstructions) -> InstructionContainer {
        InstructionContainer {
            context: Context::Response,
            at_path: path.iter().map(|s| s.to_string()).collect(),
            instruction,
        }
    }
    fn render(roots: Vec<(String, Vec<&InstructionContainer>)>) -> String {
        let instructions = roots
            .iter()
            .flat_map(|(_, entries)| entries.iter().copied())
            .collect::<Vec<_>>();
        let slots = callback_slots(&instructions);
        write_plan(roots, &slots).json
    }
    #[test]
    fn provided_variable_depth_keeps_nullable_wrappers() {
        use crate::writer::AST;
        let scalar = AST::Nullable(Box::new(AST::String));
        let inner = AST::NonNullable(Box::new(AST::ReadOnlyArray(Box::new(scalar))));
        let ast = AST::Nullable(Box::new(AST::ReadOnlyArray(Box::new(inner))));
        assert_eq!(list_depth(&ast), 2);
        assert_eq!(list_depth(&AST::String), 0);
    }
    #[test]
    fn preserves_path_boundaries_and_nested_list_depth() {
        let instructions = [
            at(
                &["response", "a_b"],
                ConverterInstructions::ConvertCustomField("A".into(), false),
            ),
            at(
                &["response", "a", "b"],
                ConverterInstructions::ConvertCustomField("B".into(), false),
            ),
            at(&["response", "items"], ConverterInstructions::ListDepth(1)),
            at(&["response", "items"], ConverterInstructions::ListDepth(2)),
            at(
                &["response", "items"],
                ConverterInstructions::ConvertCustomField("ArrayScalar".into(), true),
            ),
        ];
        let value: Value = serde_json::from_str(&render(vec![(
            "__root".into(),
            instructions.iter().collect(),
        )]))
        .unwrap();
        assert_eq!(
            value,
            json!({"version":2,"roots":{"__root":[
                {"path":["a","b"],"scalar":"2"},
                {"path":["a_b"],"scalar":"0"},
                {"path":["items"],"list":2,"scalar":"1"}
            ]}})
        );
    }
    #[test]
    fn instruction_order_and_duplicates_do_not_change_plan() {
        let mut instructions = vec![
            at(
                &["response", "items"],
                ConverterInstructions::BlockTraversal(true),
            ),
            at(&["response", "items"], ConverterInstructions::ListDepth(3)),
            at(&["response", "items"], ConverterInstructions::ListDepth(1)),
            at(
                &["response", "items"],
                ConverterInstructions::BlockTraversal(true),
            ),
        ];
        let first = render(vec![("__root".into(), instructions.iter().collect())]);
        instructions.reverse();
        assert_eq!(
            first,
            render(vec![("__root".into(), instructions.iter().collect())])
        );
        let value: Value = serde_json::from_str(&first).unwrap();
        assert_eq!(value["roots"]["__root"][0]["list"], 3);
    }
    #[test]
    fn callback_slots_are_stable_deduplicated_and_kind_specific() {
        let mut instructions = vec![
            at(
                &["response", "a"],
                ConverterInstructions::ConvertUnion("Same".into()),
            ),
            at(
                &["response", "b"],
                ConverterInstructions::ConvertCustomField("Same".into(), false),
            ),
            at(
                &["response", "c"],
                ConverterInstructions::ConvertCustomField("Same".into(), true),
            ),
        ];
        for i in 0..12 {
            instructions.push(at(
                &["Input", &format!("f{i}")],
                ConverterInstructions::ConvertCustomField(format!("Scalar{i}"), false),
            ));
        }
        let refs = instructions.iter().collect::<Vec<_>>();
        let slots = callback_slots(&refs);
        assert_eq!(slots.len(), 14);
        assert_ne!(
            slots[&Callback::Scalar("Same".into())],
            slots[&Callback::Union("Same".into())]
        );
        let output: Value =
            serde_json::from_str(&write_plan(vec![("__root".into(), refs)], &slots).json).unwrap();
        let entries = output["roots"]["__root"].as_array().unwrap();
        for instruction in &instructions {
            let (key, callback) = match &instruction.instruction {
                ConverterInstructions::ConvertCustomField(name, _) => {
                    ("scalar", Callback::Scalar(name.clone()))
                }
                ConverterInstructions::ConvertUnion(name) => {
                    ("union", Callback::Union(name.clone()))
                }
                _ => unreachable!(),
            };
            let path = json!(instruction.at_path[1..]);
            let entry = entries.iter().find(|entry| entry["path"] == path).unwrap();
            assert_eq!(entry[key], json!(slots[&callback].to_string()));
        }
        instructions.reverse();
        assert_eq!(
            slots,
            callback_slots(&instructions.iter().collect::<Vec<_>>())
        );
    }
    #[test]
    fn plain_list_hints_collapse_to_the_shared_converter() {
        let instructions = [
            at(&["response"], ConverterInstructions::ListDepth(2)),
            at(&["response", "items"], ConverterInstructions::ListDepth(1)),
            at(
                &["response", "items", "values"],
                ConverterInstructions::ListDepth(3),
            ),
        ];
        let plan = write_plan(
            vec![("__root".into(), instructions.iter().collect())],
            &CallbackSlots::new(),
        );
        assert!(plan.is_empty);
        assert_eq!(
            serde_json::from_str::<Value>(&plan.json).unwrap(),
            json!({"version":2,"roots":{"__root":[]}})
        );
    }

    #[test]
    fn list_hints_keep_every_required_operation_boundary() {
        let operations = [
            ConverterInstructions::ConvertCustomField("Scalar".into(), true),
            ConverterInstructions::ConvertUnion("Union".into()),
            ConverterInstructions::RootObject("Input".into()),
            ConverterInstructions::BlockTraversal(true),
            ConverterInstructions::HasFragments,
        ];
        for operation in operations {
            let instructions = [
                at(&["response", "items"], ConverterInstructions::ListDepth(2)),
                at(
                    &["response", "items", "child"],
                    ConverterInstructions::ListDepth(3),
                ),
                at(&["response", "items", "child"], operation),
                at(
                    &["response", "items_child"],
                    ConverterInstructions::ListDepth(1),
                ),
                at(&["response", "unused"], ConverterInstructions::ListDepth(1)),
                at(
                    &["response", "unused", "values"],
                    ConverterInstructions::ListDepth(2),
                ),
            ];
            let refs = instructions.iter().collect::<Vec<_>>();
            let slots = callback_slots(&refs);
            let plan = write_plan(
                vec![("__root".into(), refs), ("Input".into(), vec![])],
                &slots,
            );
            assert!(!plan.is_empty);
            let value: Value = serde_json::from_str(&plan.json).unwrap();
            let entries = value["roots"]["__root"].as_array().unwrap();
            assert_eq!(entries.len(), 2);
            assert_eq!(entries[0], json!({"path":["items"],"list":2}));
            assert_eq!(entries[1]["path"], json!(["items", "child"]));
            assert_eq!(entries[1]["list"], 3);
        }
    }
}
