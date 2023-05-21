(* @sourceLoc Test_mutation.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type inputA = RelaySchemaAssets_graphql.input_InputA_nullable
  type inputB = RelaySchemaAssets_graphql.input_InputB_nullable
  type response_recursiveInput = {
    recursionIsCool: bool option;
  }
  type response = {
    recursiveInput: response_recursiveInput option;
  }
  type rawResponse = response
  type variables = {
    input: inputA Js.Null.t ;
  }
end

module Internal = struct
  let variablesConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"inputB":{"usingA":{"r":"inputA"},"time":{"c":"SomeModule.Datetime"}},"inputA":{"usingB":{"r":"inputB"},"timestamps":{"b":"a"},"timestamp":{"b":""},"time":{"c":"SomeModule.Datetime"},"recursiveA":{"r":"inputA"}},"__root":{"input":{"r":"inputA"}}}|json}
  ]
  let variablesConverterMap = let o = Js.Dict.empty () in 
    Js.Dict.set o "SomeModule.Datetime" (Obj.magic SomeModule.Datetime.serialize : unit);
  o
  let convertVariables v = Melange_relay.convertObj v 
    variablesConverter 
    variablesConverterMap 
    Js.null
    type wrapResponseRaw
  let wrapResponseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{}|json}
  ]
  let wrapResponseConverterMap = ()
  let convertWrapResponse v = Melange_relay.convertObj v 
    wrapResponseConverter 
    wrapResponseConverterMap 
    Js.null
    type responseRaw
  let responseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{}|json}
  ]
  let responseConverterMap = ()
  let convertResponse v = Melange_relay.convertObj v 
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
    ?unmapped: Melange_relay.any-> 
    ?usingB: inputB-> 
    unit ->
   inputA = "" [@@bs.obj]


  external make_inputB:     ?_constraint: bool-> 
    ?time: SomeModule.Datetime.t-> 
    ?usingA: inputA-> 
    unit ->
   inputB = "" [@@bs.obj]


  external makeVariables:     ?input: inputA-> 
    unit ->
   variables = "" [@@bs.obj]


end

type relayOperationNode
type operationType = relayOperationNode Melange_relay.mutationNode


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
})() |json}]


