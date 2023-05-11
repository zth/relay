(* @sourceLoc Test_mutation.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type inputA = RelaySchemaAssets_graphql.input_InputA
  type inputB = RelaySchemaAssets_graphql.input_InputB
  type response_recursiveInput = {
    recursionIsCool: bool option;
  }
  type response = {
    recursiveInput: response_recursiveInput option;
  }
  type rawResponse = response
  type variables = {
    input: inputA;
  }
end

module Internal = struct
  let variablesConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"inputB":{"usingA":{"r":"inputA"},"time":{"c":"SomeModule.Datetime"}},"inputA":{"usingB":{"r":"inputB"},"timestamps":{"b":"a"},"timestamp":{"b":""},"time":{"c":"SomeModule.Datetime"},"recursiveA":{"r":"inputA"}},"__root":{"input":{"r":"inputA"}}}|json}
  ]
  let variablesConverterMap = let o = Js.Dict.empty () in 
    Js.Dict.set o "SomeModule.Datetime" SomeModule.Datetime.serialize;
  o
  let convertVariables v = RescriptRelay.convertObj v 
    variablesConverter 
    variablesConverterMap 
    Js.undefined
    type wrapResponseRaw
  let wrapResponseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{}|json}
  ]
  let wrapResponseConverterMap = ()
  let convertWrapResponse v = RescriptRelay.convertObj v 
    wrapResponseConverter 
    wrapResponseConverterMap 
    Js.null
    type responseRaw
  let responseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{}|json}
  ]
  let responseConverterMap = ()
  let convertResponse v = RescriptRelay.convertObj v 
    responseConverter 
    responseConverterMap 
    Js.undefined
    type wrapRawResponseRaw = wrapResponseRaw
  let convertWrapRawResponse = convertWrapResponse
  type rawResponseRaw = responseRaw
  let convertRawResponse = convertResponse
end
module Utils = struct
  [@@@ocaml.warning "-33"]
  open Types
  external make_inputA:     ?recursiveA: inputA-> 
    time: SomeModule.Datetime.t-> 
    ?timestamp: Timestamp.t-> 
    ?timestamps: Timestamp.t option array-> 
    ?unmapped: RescriptRelay.any-> 
    ?usingB: inputB-> 
    unit
   inputA = "" [@@bs.obj]


  external make_inputB:     ?_constraint: bool-> 
    ?time: SomeModule.Datetime.t-> 
    ?usingA: inputA-> 
    unit
   inputB = "" [@@bs.obj]


  external makeVariables:     input: inputA-> 
   variables = "" [@@bs.obj]


end

type relayOperationNode
type operationType = relayOperationNode RescriptRelay.mutationNode


let node: operationType = [%bs.raw {json| (function(){
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
})() |json}]


