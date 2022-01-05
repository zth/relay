/* @sourceLoc Test_mutation.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@ocaml.warning("-30")

  type rec inputA = {
    time: SomeModule.Datetime.t,
    recursiveA: option<inputA>,
    usingB: option<inputB>,
  }
  and inputB = {
    time: option<SomeModule.Datetime.t>,
    usingA: option<inputA>,
  }
  type rec response_recursiveInput = {
    recursionIsCool: option<bool>,
  }
  type response = {
    recursiveInput: option<response_recursiveInput>,
  }
  type rawResponse = response
  type variables = {
    input: inputA,
  }
}

module Internal = {
  let variablesConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`JSON.parse(\`{"inputB":{"usingA":{"r":"inputA"},"time":{"c":"SomeModule.Datetime"}},"inputA":{"usingB":{"r":"inputB"},"time":{"c":"SomeModule.Datetime"},"recursiveA":{"r":"inputA"}},"__root":{"usingB":{"r":"inputB"},"usingA":{"r":"inputA"},"time":{"c":"SomeModule.Datetime",},"recursiveA":{"r":"inputA"},"input":{"r":"inputA"}}}\`)`
  )
  let variablesConverterMap = {
    "SomeModule.Datetime": SomeModule.Datetime.serialize,
  }
  let convertVariables = v => v->RescriptRelay.convertObj(
    variablesConverter,
    variablesConverterMap,
    Js.undefined
  )
  type wrapResponseRaw
  let wrapResponseConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`JSON.parse(\`{}\`)`
  )
  let wrapResponseConverterMap = ()
  let convertWrapResponse = v => v->RescriptRelay.convertObj(
    wrapResponseConverter,
    wrapResponseConverterMap,
    Js.null
  )
  type responseRaw
  let responseConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`JSON.parse(\`{}\`)`
  )
  let responseConverterMap = ()
  let convertResponse = v => v->RescriptRelay.convertObj(
    responseConverter,
    responseConverterMap,
    Js.undefined
  )
  type wrapRawResponseRaw = wrapResponseRaw
  let convertWrapRawResponse = convertWrapResponse
  type rawResponseRaw = responseRaw
  let convertRawResponse = convertResponse
}
module Utils = {
  @@ocaml.warning("-33")
  open Types
  let make_inputA = (
    ~time,
    ~recursiveA=?,
    ~usingB=?,
    ()
  ): inputA => {
    time: time,
    recursiveA: recursiveA,
    usingB: usingB
  }
  let make_inputB = (
    ~time=?,
    ~usingA=?,
    ()
  ): inputB => {
    time: time,
    usingA: usingA
  }
  let makeVariables = (
    ~input
  ): variables => {
    input: input
  }
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


