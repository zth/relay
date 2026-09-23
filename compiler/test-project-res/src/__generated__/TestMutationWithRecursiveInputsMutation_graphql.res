/* @sourceLoc Test_mutation.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type inputA = RelaySchemaAssets_graphql.input_InputA
  @live type inputB = RelaySchemaAssets_graphql.input_InputB
  @live
  type rec response_recursiveInput = {
    recursionIsCool: option<bool>,
  }
  @live
  type response = {
    recursiveInput: option<response_recursiveInput>,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    input: inputA,
  }
}

module Internal = {
  %%private(
  @live
  let variablesConverter: JSON.t = %raw(json`{"roots":{"__root":[{"path":["input"],"reference":"inputA"}],"inputA":[{"path":["recursiveA"],"reference":"inputA"},{"path":["time"],"scalar":"0"},{"opaque":true,"path":["timestamp"]},{"list":1,"opaque":true,"path":["timestamps"]},{"path":["usingB"],"reference":"inputB"}],"inputB":[{"path":["time"],"scalar":"0"},{"path":["usingA"],"reference":"inputA"}]},"version":2}`)
  @live
  let variablesCallbacks = {
    "0": SomeModule.Datetime.serialize,
  }
  @live
  let preparedVariablesConverter = RescriptRelay.prepareConversion(
    variablesConverter,
    variablesCallbacks,
    None
  )
  )
  @live
  let convertVariables = value => RescriptRelay.runConversion(preparedVariablesConverter, value)
  @live
  type wrapResponseRaw
  @live
  let convertWrapResponse = value => RescriptRelay.convertWithoutPlan(value, null)
  @live
  type responseRaw
  @live
  let convertResponse = value => RescriptRelay.convertWithoutPlan(value, None)
  type wrapRawResponseRaw = wrapResponseRaw
  @live
  let convertWrapRawResponse = convertWrapResponse
  type rawResponseRaw = responseRaw
  @live
  let convertRawResponse = convertResponse
}
module Utils = {
  @@warning("-33")
  open Types
}

type relayOperationNode
type operationType = RescriptRelay.mutationNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "input"
  }
],
v1 = [
  {
    "alias": null,
    "args": [
      {
        "kind": "Variable",
        "name": "input",
        "variableName": "input"
      }
    ],
    "concreteType": "RecursiveInputPayload",
    "kind": "LinkedField",
    "name": "recursiveInput",
    "plural": false,
    "selections": [
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "recursionIsCool",
        "storageKey": null
      }
    ],
    "storageKey": null
  }
];
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": null,
    "name": "TestMutationWithRecursiveInputsMutation",
    "selections": (v1/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "TestMutationWithRecursiveInputsMutation",
    "selections": (v1/*: any*/)
  },
  "params": {
    "cacheID": "06c352149b8d5b52130daf8addfb4a90",
    "id": null,
    "metadata": {},
    "name": "TestMutationWithRecursiveInputsMutation",
    "operationKind": "mutation",
    "text": "mutation TestMutationWithRecursiveInputsMutation(\n  $input: InputA!\n) {\n  recursiveInput(input: $input) {\n    recursionIsCool\n  }\n}\n"
  }
};
})() `)


