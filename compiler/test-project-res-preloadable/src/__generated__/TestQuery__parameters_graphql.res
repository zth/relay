/**
 * @generated SignedSource<<e57e0c703a63b00358902adcc2744ba1>>
 * @relayHash 123064f3c998fd5b717ca05be99d7ee1
 * @lightSyntaxTransform
 * @nogrep
 */

// @relayRequestID 123064f3c998fd5b717ca05be99d7ee1

/* @sourceLoc Test_query.res */
/* @generated */
%%raw("/* @generated */")
module Types = { include TestQuery_graphql.Types }
type queryRef

type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json` {
  "kind": "PreloadableConcreteRequest",
  "params": {
    "id": "123064f3c998fd5b717ca05be99d7ee1",
    "metadata": {},
    "name": "TestQuery",
    "operationKind": "query",
    "text": null
  }
} `)

include RescriptRelay.MakeLoadQuery({
        type variables = Types.variables
        type loadedQueryRef = queryRef
        type response = Types.response
        type node = relayOperationNode
        let query = node
        let convertVariables = Internal.convertVariables
    });
