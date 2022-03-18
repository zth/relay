/* @sourceLoc Test_mutation.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@ocaml.warning("-30")

  @live
  type rec inputA = {
    recursiveA: option<inputA>,
    time: SomeModule.Datetime.t,
    usingB: option<inputB>,
  }
  @live
  and inputB = {
    @as("constraint") constraint_: option<bool>,
    time: option<SomeModule.Datetime.t>,
    usingA: option<inputA>,
  }
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
  @live
  let variablesConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"inputB":{"usingA":{"r":"inputA"},"time":{"c":"SomeModule.Datetime"}},"inputA":{"usingB":{"r":"inputB"},"time":{"c":"SomeModule.Datetime"},"recursiveA":{"r":"inputA"}},"__root":{"input":{"r":"inputA"}}}`
  )
  @live
  let variablesConverterMap = {
    "SomeModule.Datetime": SomeModule.Datetime.serialize,
  }
  @live
  let convertVariables = v => v->RescriptRelay.convertObj(
    variablesConverter,
    variablesConverterMap,
    Js.undefined
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
  @@ocaml.warning("-33")
  open Types
  @live @obj external make_inputA: (
    ~recursiveA: inputA=?,
    ~time: SomeModule.Datetime.t,
    ~usingB: inputB=?,
    unit
  ) => inputA = ""


  @live let make_inputB = (
    ~constraint_=?,
    ~time=?,
    ~usingA=?,
    ()
  ): inputB => {
    constraint_: constraint_,
    time: time,
    usingA: usingA
  }

  @live @obj external makeVariables: (
    ~input: inputA,
  ) => variables = ""


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


