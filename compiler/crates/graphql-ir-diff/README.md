# graphql_ir_diff

Comparing the intermediate representation (IR) of 2 GraphQL documents and outputs the differences.

## Algorithm

The `compare` function determines whether one GraphQL document (`doc1`) is a subset of another (`doc2`) by comparing their normalized selection sets. The algorithm produces a similarity score and a detailed report of any missing selections.

### High-Level Steps

1. **Load Schema**: Parse the GraphQL schema from the provided paths to enable type-aware comparison.

2. **Parse to IR**: Convert both GraphQL documents into intermediate representation (IR).

3. **Build Normalized Trees**: Transform each IR into a `NormalizedTree` - a tree structure that:
   - Removes fragment spreads and inline fragments (inlines them instead)
   - Dealiases fields (e.g., `my_id: id` becomes `id`)
   - Deduplicates identical fields
   - Tracks type conditions at leaf level (which concrete object types can reach each scalar field)

   The normailized tree mirrors the JSON response structure of the query

4. **Subtract Trees**: Perform a DFS traversal comparing `tree1` from (`doc1`) against `tree2` (from `doc2`):
   - For each selection in `tree1`, find a matching superset selection in `tree2` using the **subset check**
   - **Subset check for arguments**: An argument is a subset if it has the same name and its value is a subset of the other's value. Any concrete value is considered a subset of a variable (since variables can be set to any value at runtime).
   - For **leaf nodes** (scalar fields): Also verify that all type conditions in `tree1` are satisfied by `tree2`
   - For **node matches**: Recursively compare children
   - Collect all selections in `tree1` that have no matching superset in `tree2`

5. **Compute Score**: Calculate a similarity score as:
   ```
   score = 1.0 - (missing_nodes_count / total_nodes_in_doc1)
   ```
   - Score of `1.0` means `doc1` is a complete subset of `doc2`
   - Score of `0.0` means `doc1` is completely disjoint from `doc2`

### Key Concepts

- **NormalizedSelection**: Represents a field with its name (dealiased) and arguments
- **NormalizedTree::Node**: Linked fields with children selections
- **NormalizedTree::Leaf**: Scalar fields with possible concrete object types that can reach them
- **Subset relationship**: `A ⊆ B` if A's field name matches B's and each argument in A has a matching argument in B whose value is equal or is a variable
