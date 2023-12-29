/* @sourceLoc Test_mutation.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type inputA = RelaySchemaAssets_graphql.input_InputA_nullable
  @live type inputB = RelaySchemaAssets_graphql.input_InputB_nullable
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
    input?: Js.Null.t<inputA>,
  }
}

module Internal = {
  @live
  let variablesConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"inputB":{"usingA":{"r":"inputA"},"time":{"c":"SomeModule.Datetime"}},"inputA":{"usingB":{"r":"inputB"},"timestamps":{"b":"a"},"timestamp":{"b":""},"time":{"c":"SomeModule.Datetime"},"recursiveA":{"r":"inputA"}},"__root":{"input":{"r":"inputA"}}}`
  )
  @live
  let variablesConverterMap = {
    "SomeModule.Datetime": SomeModule.Datetime.serialize,
  }
  @live
  let convertVariables = v => v->RescriptRelay.convertObj(
    variablesConverter,
    variablesConverterMap,
    Js.null
  )
  @live
  type wrapResponseRaw
  @live
  let wrapResponseConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{}`
  )
  @live
  let wrapResponseConverterMap = ()
  @live
  let convertWrapResponse = v => v->RescriptRelay.convertObj(
    wrapResponseConverter,
    wrapResponseConverterMap,
    Js.null
  )
  @live
  type responseRaw
  @live
  let responseConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{}`
  )
  @live
  let responseConverterMap = ()
  @live
  let convertResponse = v => v->RescriptRelay.convertObj(
    responseConverter,
    responseConverterMap,
    Js.undefined
  )
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
    "name": "TestMutationWithRecursiveInputsNullableMutation",
    "selections": (v1/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "TestMutationWithRecursiveInputsNullableMutation",
    "selections": (v1/*: any*/)
  },
  "params": {
    "cacheID": "b14776c2c836d309337d2799ab76d4ce",
    "id": null,
    "metadata": {},
    "name": "TestMutationWithRecursiveInputsNullableMutation",
    "operationKind": "mutation",
    "text": "mutation TestMutationWithRecursiveInputsNullableMutation(\n  $input: InputA\n) {\n  recursiveInput(input: $input) {\n    recursionIsCool\n  }\n}\n"
  }
};
})() `)


