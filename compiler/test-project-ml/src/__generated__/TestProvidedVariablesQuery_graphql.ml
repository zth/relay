(* @sourceLoc Test_providedVariables.ml *)
(* @generated *)
[%%mel.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type someInput = RelaySchemaAssets_graphql.input_SomeInput
  type inputB = RelaySchemaAssets_graphql.input_InputB
  type inputA = RelaySchemaAssets_graphql.input_InputA
  type response_loggedInUser = {
    fragmentRefs: [ | `TestProvidedVariables_user] Melange_relay.fragmentRefs;
  }
  type response = {
    loggedInUser: response_loggedInUser;
  }
  type rawResponse = response
  type variables = unit
  type refetchVariables = unit
  let makeRefetchVariables () = ()
end

module Internal = struct
  let variablesConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
    {json|{"someInput":{"recursive":{"r":"someInput"},"datetime":{"c":"SomeModule.Datetime"}},"inputA":{"usingB":{"r":"inputB"},"timestamps":{"b":"a"},"timestamp":{"b":""},"time":{"c":"SomeModule.Datetime"},"recursiveA":{"r":"inputA"}},"inputB":{"usingA":{"r":"inputA"},"time":{"c":"SomeModule.Datetime"}},"__root":{"__relay_internal__pv__TestProvidedVariablesSomeInput":{"r":"someInput"},"__relay_internal__pv__TestProvidedVariablesInputB":{"r":"inputB"},"__relay_internal__pv__TestProvidedVariablesDatetimes":{"c":"SomeModule.Datetime"},"__relay_internal__pv__TestProvidedVariablesDatetime":{"c":"SomeModule.Datetime"}}}|json}
  ]
  let variablesConverterMap = let o = Js.Dict.empty () in 
    Js.Dict.set o "SomeModule.Datetime" (Obj.magic SomeModule.Datetime.serialize : unit);
  o
  let convertVariables v = Melange_relay.convertObj v 
    variablesConverter 
    variablesConverterMap 
    Js.undefined
    type wrapResponseRaw
  let wrapResponseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
    {json|{"__root":{"loggedInUser":{"f":""}}}|json}
  ]
  let wrapResponseConverterMap = ()
  let convertWrapResponse v = Melange_relay.convertObj v 
    wrapResponseConverter 
    wrapResponseConverterMap 
    Js.null
    type responseRaw
  let responseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
    {json|{"__root":{"loggedInUser":{"f":""}}}|json}
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

type queryRef

module Utils = struct
  [@@@ocaml.warning "-33"]
  open Types
  external make_someInput:     ?bool: bool-> 
    ?datetime: SomeModule.Datetime.t-> 
    ?float: float-> 
    ?int: int-> 
    ?_private: bool-> 
    ?recursive: someInput-> 
    ?str: string-> 
    unit ->
   someInput = "" [@@mel.obj]


  external make_inputB:     ?_constraint: bool-> 
    ?time: SomeModule.Datetime.t-> 
    ?usingA: inputA-> 
    unit ->
   inputB = "" [@@mel.obj]


  external make_inputA:     ?recursiveA: inputA-> 
    time: SomeModule.Datetime.t-> 
    ?timestamp: Timestamp.t-> 
    ?timestamps: Timestamp.t option array-> 
    ?unmapped: Melange_relay.any-> 
    ?usingB: inputB-> 
    unit ->
   inputA = "" [@@mel.obj]


  external makeVariables: unit -> unit = "" [@@mel.obj]
end
type 't providedVariable = { providedVariable: unit -> 't; get: unit -> 't }
type providedVariablesType = {
  __relay_internal__pv__TestProvidedVariablesBool: bool providedVariable;
  __relay_internal__pv__TestProvidedVariablesDatetime: SomeModule.Datetime.t option providedVariable;
  __relay_internal__pv__TestProvidedVariablesDatetimes: SomeModule.Datetime.t array option providedVariable;
  __relay_internal__pv__TestProvidedVariablesFloat: float providedVariable;
  __relay_internal__pv__TestProvidedVariablesID: string option providedVariable;
  __relay_internal__pv__TestProvidedVariablesInputB: RelaySchemaAssets_graphql.input_InputB providedVariable;
  __relay_internal__pv__TestProvidedVariablesInt: int option providedVariable;
  __relay_internal__pv__TestProvidedVariablesSomeInput: RelaySchemaAssets_graphql.input_SomeInput providedVariable;
  __relay_internal__pv__TestProvidedVariablesStr: string providedVariable;
}
let providedVariablesDefinition: providedVariablesType = {
  __relay_internal__pv__TestProvidedVariablesSomeInput = {
    providedVariable = TestProvidedVariables.SomeInput.get;
    get = (fun () -> Internal.convertVariables (Js.Dict.fromArray [|("__relay_internal__pv__TestProvidedVariablesSomeInput", TestProvidedVariables.SomeInput.get())|]) |. Js.Dict.unsafeGet "__relay_internal__pv__TestProvidedVariablesSomeInput");
  };
  __relay_internal__pv__TestProvidedVariablesInputB = {
    providedVariable = TestProvidedVariables.InputB.get;
    get = (fun () -> Internal.convertVariables (Js.Dict.fromArray [|("__relay_internal__pv__TestProvidedVariablesInputB", TestProvidedVariables.InputB.get())|]) |. Js.Dict.unsafeGet "__relay_internal__pv__TestProvidedVariablesInputB");
  };
  __relay_internal__pv__TestProvidedVariablesBool = {
    providedVariable = TestProvidedVariables.Bool.get;
    get = TestProvidedVariables.Bool.get;
  };
  __relay_internal__pv__TestProvidedVariablesStr = {
    providedVariable = TestProvidedVariables.Str.get;
    get = TestProvidedVariables.Str.get;
  };
  __relay_internal__pv__TestProvidedVariablesFloat = {
    providedVariable = TestProvidedVariables.Float.get;
    get = TestProvidedVariables.Float.get;
  };
  __relay_internal__pv__TestProvidedVariablesInt = {
    providedVariable = TestProvidedVariables.Int.get;
    get = TestProvidedVariables.Int.get;
  };
  __relay_internal__pv__TestProvidedVariablesID = {
    providedVariable = TestProvidedVariables.ID.get;
    get = TestProvidedVariables.ID.get;
  };
  __relay_internal__pv__TestProvidedVariablesDatetime = {
    providedVariable = TestProvidedVariables.Datetime.get;
    get = (fun () -> Internal.convertVariables (Js.Dict.fromArray [|("__relay_internal__pv__TestProvidedVariablesDatetime", TestProvidedVariables.Datetime.get())|]) |. Js.Dict.unsafeGet "__relay_internal__pv__TestProvidedVariablesDatetime");
  };
  __relay_internal__pv__TestProvidedVariablesDatetimes = {
    providedVariable = TestProvidedVariables.Datetimes.get;
    get = (fun () -> Internal.convertVariables (Js.Dict.fromArray [|("__relay_internal__pv__TestProvidedVariablesDatetimes", TestProvidedVariables.Datetimes.get())|]) |. Js.Dict.unsafeGet "__relay_internal__pv__TestProvidedVariablesDatetimes");
  };
}

type relayOperationNode
type operationType = relayOperationNode Melange_relay.queryNode


[%%private let makeNode providedVariablesDefinition: operationType = 
  ignore providedVariablesDefinition;
  [%raw {json|{
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestProvidedVariablesQuery",
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "loggedInUser",
        "plural": false,
        "selections": [
          {
            "args": null,
            "kind": "FragmentSpread",
            "name": "TestProvidedVariables_user"
          }
        ],
        "storageKey": null
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesSomeInput"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesInputB"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesBool"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesStr"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesFloat"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesInt"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesID"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesDatetime"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesDatetimes"
      }
    ],
    "kind": "Operation",
    "name": "TestProvidedVariablesQuery",
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "loggedInUser",
        "plural": false,
        "selections": [
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "firstName",
            "storageKey": null
          },
          {
            "alias": null,
            "args": [
              {
                "kind": "Variable",
                "name": "bool",
                "variableName": "__relay_internal__pv__TestProvidedVariablesBool"
              },
              {
                "kind": "Variable",
                "name": "dateTime",
                "variableName": "__relay_internal__pv__TestProvidedVariablesDatetime"
              },
              {
                "kind": "Variable",
                "name": "dateTimes",
                "variableName": "__relay_internal__pv__TestProvidedVariablesDatetimes"
              },
              {
                "kind": "Variable",
                "name": "float",
                "variableName": "__relay_internal__pv__TestProvidedVariablesFloat"
              },
              {
                "kind": "Variable",
                "name": "id",
                "variableName": "__relay_internal__pv__TestProvidedVariablesID"
              },
              {
                "kind": "Variable",
                "name": "inputB",
                "variableName": "__relay_internal__pv__TestProvidedVariablesInputB"
              },
              {
                "kind": "Variable",
                "name": "int",
                "variableName": "__relay_internal__pv__TestProvidedVariablesInt"
              },
              {
                "kind": "Variable",
                "name": "someInput",
                "variableName": "__relay_internal__pv__TestProvidedVariablesSomeInput"
              },
              {
                "kind": "Variable",
                "name": "str",
                "variableName": "__relay_internal__pv__TestProvidedVariablesStr"
              }
            ],
            "kind": "ScalarField",
            "name": "onlineStatus",
            "storageKey": null
          },
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "id",
            "storageKey": null
          }
        ],
        "storageKey": null
      }
    ]
  },
  "params": {
    "cacheID": "e126b7abfa263019306c87047185b1ff",
    "id": null,
    "metadata": {},
    "name": "TestProvidedVariablesQuery",
    "operationKind": "query",
    "text": "query TestProvidedVariablesQuery(\n  $__relay_internal__pv__TestProvidedVariablesSomeInput: SomeInput!\n  $__relay_internal__pv__TestProvidedVariablesInputB: InputB!\n  $__relay_internal__pv__TestProvidedVariablesBool: Boolean!\n  $__relay_internal__pv__TestProvidedVariablesStr: String!\n  $__relay_internal__pv__TestProvidedVariablesFloat: Float!\n  $__relay_internal__pv__TestProvidedVariablesInt: Int\n  $__relay_internal__pv__TestProvidedVariablesID: ID\n  $__relay_internal__pv__TestProvidedVariablesDatetime: Datetime\n  $__relay_internal__pv__TestProvidedVariablesDatetimes: [Datetime!]\n) {\n  loggedInUser {\n    ...TestProvidedVariables_user\n    id\n  }\n}\n\nfragment TestProvidedVariables_user on User {\n  firstName\n  onlineStatus(someInput: $__relay_internal__pv__TestProvidedVariablesSomeInput, inputB: $__relay_internal__pv__TestProvidedVariablesInputB, bool: $__relay_internal__pv__TestProvidedVariablesBool, str: $__relay_internal__pv__TestProvidedVariablesStr, float: $__relay_internal__pv__TestProvidedVariablesFloat, int: $__relay_internal__pv__TestProvidedVariablesInt, id: $__relay_internal__pv__TestProvidedVariablesID, dateTime: $__relay_internal__pv__TestProvidedVariablesDatetime, dateTimes: $__relay_internal__pv__TestProvidedVariablesDatetimes)\n}\n",
    "providedVariables": providedVariablesDefinition
  }
}|json}]
]
let node: operationType = makeNode providedVariablesDefinition

include Melange_relay.MakeLoadQuery(struct
            type variables = Types.variables
            type loadedQueryRef = queryRef
            type response = Types.response
            type node = relayOperationNode
            let query = node
            let convertVariables = Internal.convertVariables
        end)
