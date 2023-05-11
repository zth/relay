(* @sourceLoc Test_mutation.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type someInput = RelaySchemaAssets_graphql.input_SomeInput_nullable
  type response_setOnlineStatus_user_friendsConnection = {
    __typename: [ | `UserConnection] [@live];
  }
  and response_setOnlineStatus_user = {
    friendsConnection: response_setOnlineStatus_user_friendsConnection;
  }
  and response_setOnlineStatus = {
    user: response_setOnlineStatus_user option;
  }
  type response = {
    setOnlineStatus: response_setOnlineStatus option;
  }
  type rawResponse = response
  type variables = {
    datetime: SomeModule.Datetime.t Js.Null.t [@bs.optional];
    onlineStatus: [
      | `Idle
      | `Offline
      | `Online
    ];
    recursive: someInput Js.Null.t [@bs.optional];
  }
end

module Internal = struct
  let variablesConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"someInput":{"recursive":{"r":"someInput"},"datetime":{"c":"SomeModule.Datetime"}},"__root":{"recursive":{"r":"someInput"},"datetime":{"c":"SomeModule.Datetime"}}}|json}
  ]
  let variablesConverterMap = let o = Js.Dict.empty () in 
    Js.Dict.set o "SomeModule.Datetime" (Obj.magic SomeModule.Datetime.serialize : unit);
  o
  let convertVariables v = RescriptRelay.convertObj v 
    variablesConverter 
    variablesConverterMap 
    Js.null
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
  external onlineStatus_toString: RelaySchemaAssets_graphql.enum_OnlineStatus -> string = "%identity"
  external onlineStatus_input_toString: RelaySchemaAssets_graphql.enum_OnlineStatus_input -> string = "%identity"
  let onlineStatus_decode (enum: RelaySchemaAssets_graphql.enum_OnlineStatus): RelaySchemaAssets_graphql.enum_OnlineStatus_input option =
    (match enum with
      | #RelaySchemaAssets_graphql.enum_OnlineStatus_input as valid -> Some(valid)
      | _ -> None
    )
    let onlineStatus_fromString (str: string): RelaySchemaAssets_graphql.enum_OnlineStatus_input option =
    onlineStatus_decode (Obj.magic str)
    external make_someInput:     ?bool: bool-> 
    ?datetime: SomeModule.Datetime.t-> 
    ?float: float-> 
    ?int: int-> 
    ?_private: bool-> 
    ?recursive: someInput-> 
    ?str: string-> 
    unit ->
   someInput = "" [@@bs.obj]


  external makeVariables:     ?datetime: SomeModule.Datetime.t-> 
    onlineStatus: [
      | `Idle
      | `Offline
      | `Online
    ]-> 
    ?recursive: someInput-> 
    unit ->
   variables = "" [@@bs.obj]


end

type relayOperationNode
type operationType = relayOperationNode RescriptRelay.mutationNode


let node: operationType = [%bs.raw {json| (function(){
var v0 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "datetime"
},
v1 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "onlineStatus"
},
v2 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "recursive"
},
v3 = [
  {
    "kind": "Variable",
    "name": "onlineStatus",
    "variableName": "onlineStatus"
  }
],
v4 = {
  "alias": null,
  "args": [
    {
      "fields": [
        {
          "kind": "Literal",
          "name": "bool",
          "value": false
        },
        {
          "kind": "Variable",
          "name": "datetime",
          "variableName": "datetime"
        },
        {
          "kind": "Literal",
          "name": "float",
          "value": 12.2
        },
        {
          "kind": "Literal",
          "name": "int",
          "value": 64
        },
        {
          "kind": "Variable",
          "name": "recursive",
          "variableName": "recursive"
        },
        {
          "kind": "Literal",
          "name": "str",
          "value": "123"
        }
      ],
      "kind": "ObjectValue",
      "name": "objTest"
    },
    {
      "items": [
        {
          "kind": "Literal",
          "name": "statuses.0",
          "value": "Idle"
        },
        {
          "kind": "Variable",
          "name": "statuses.1",
          "variableName": "onlineStatus"
        }
      ],
      "kind": "ListValue",
      "name": "statuses"
    }
  ],
  "concreteType": "UserConnection",
  "kind": "LinkedField",
  "name": "friendsConnection",
  "plural": false,
  "selections": [
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "__typename",
      "storageKey": null
    }
  ],
  "storageKey": null
};
return {
  "fragment": {
    "argumentDefinitions": [
      (v0/*: any*/),
      (v1/*: any*/),
      (v2/*: any*/)
    ],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestMutationNullabilityMutation",
    "selections": [
      {
        "alias": null,
        "args": (v3/*: any*/),
        "concreteType": "SetOnlineStatusPayload",
        "kind": "LinkedField",
        "name": "setOnlineStatus",
        "plural": false,
        "selections": [
          {
            "alias": null,
            "args": null,
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "user",
            "plural": false,
            "selections": [
              (v4/*: any*/)
            ],
            "storageKey": null
          }
        ],
        "storageKey": null
      }
    ],
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [
      (v1/*: any*/),
      (v0/*: any*/),
      (v2/*: any*/)
    ],
    "kind": "Operation",
    "name": "TestMutationNullabilityMutation",
    "selections": [
      {
        "alias": null,
        "args": (v3/*: any*/),
        "concreteType": "SetOnlineStatusPayload",
        "kind": "LinkedField",
        "name": "setOnlineStatus",
        "plural": false,
        "selections": [
          {
            "alias": null,
            "args": null,
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "user",
            "plural": false,
            "selections": [
              (v4/*: any*/),
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
        ],
        "storageKey": null
      }
    ]
  },
  "params": {
    "cacheID": "8184be32c86e88c46d5ad837d9247590",
    "id": null,
    "metadata": {},
    "name": "TestMutationNullabilityMutation",
    "operationKind": "mutation",
    "text": "mutation TestMutationNullabilityMutation(\n  $onlineStatus: OnlineStatus!\n  $datetime: Datetime\n  $recursive: SomeInput\n) {\n  setOnlineStatus(onlineStatus: $onlineStatus) {\n    user {\n      friendsConnection(statuses: [Idle, $onlineStatus], objTest: {str: \"123\", bool: false, float: 12.2, int: 64, datetime: $datetime, recursive: $recursive}) {\n        __typename\n      }\n      id\n    }\n  }\n}\n"
  }
};
})() |json}]


