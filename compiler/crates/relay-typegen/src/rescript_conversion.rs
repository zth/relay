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

pub(crate) fn write_plan(roots: Vec<(String, Vec<&InstructionContainer>)>) -> String {
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
                    ("scalar", json!(name))
                }
                ConverterInstructions::BlockTraversal(array) => {
                    if *array {
                        entry.entry("list").or_insert(json!(1));
                    }
                    ("opaque", json!(true))
                }
                ConverterInstructions::ConvertUnion(name) => ("union", json!(name)),
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
        let entries = entries
            .into_iter()
            .map(|(path, mut entry)| {
                entry.insert("path".to_string(), json!(path));
                Value::Object(entry)
            })
            .collect::<Vec<_>>();
        output.insert(name, entries);
    }
    json!({"version": 2, "roots": output}).to_string()
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
        let value: Value = serde_json::from_str(&write_plan(vec![(
            "__root".into(),
            instructions.iter().collect(),
        )]))
        .unwrap();
        assert_eq!(
            value,
            json!({"version":2,"roots":{"__root":[
                {"path":["a","b"],"scalar":"B"},
                {"path":["a_b"],"scalar":"A"},
                {"path":["items"],"list":2,"scalar":"ArrayScalar"}
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
        let first = write_plan(vec![("__root".into(), instructions.iter().collect())]);
        instructions.reverse();
        assert_eq!(
            first,
            write_plan(vec![("__root".into(), instructions.iter().collect())])
        );
        let value: Value = serde_json::from_str(&first).unwrap();
        assert_eq!(value["roots"]["__root"][0]["list"], 3);
    }
}
