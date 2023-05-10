(* @sourceLoc Test_mutation.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type response_setOnlineStatus_user = {
    id: string [@live];
    onlineStatus: RelaySchemaAssets_graphql.enum_OnlineStatus option;
    fragmentRefs: [ | `TestFragment_user] RescriptRelay.fragmentRefs;
  }
  and response_setOnlineStatus = {
    user: response_setOnlineStatus_user option;
  }
  and rawResponse_setOnlineStatus_user = {
    __id: RescriptRelay.dataId option [@live];
    firstName: string;
    id: string [@live];
    lastName: string;
    onlineStatus: [
      | `Idle
      | `Offline
      | `Online
    ] option;
  }
  and rawResponse_setOnlineStatus = {
    user: rawResponse_setOnlineStatus_user option;
  }
  type response = {
    setOnlineStatus: response_setOnlineStatus option;
  }
  type rawResponse = {
    setOnlineStatus: rawResponse_setOnlineStatus option;
  }
  type variables = {
    connections: RescriptRelay.dataId array;
    onlineStatus: [
      | `Idle
      | `Offline
      | `Online
    ];
  }
end

module Internal = struct
  let variablesConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{}|json}
  ]
  let variablesConverterMap = ()
  let convertVariables v = RescriptRelay.convertObj v 
    variablesConverter 
    variablesConverterMap 
    Js.undefined
    type wrapResponseRaw
  let wrapResponseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"__root":{"setOnlineStatus_user":{"f":""}}}|json}
  ]
  let wrapResponseConverterMap = ()
  let convertWrapResponse v = RescriptRelay.convertObj v 
    wrapResponseConverter 
    wrapResponseConverterMap 
    Js.null
    type responseRaw
  let responseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"__root":{"setOnlineStatus_user":{"f":""}}}|json}
  ]
  let responseConverterMap = ()
  let convertResponse v = RescriptRelay.convertObj v 
    responseConverter 
    responseConverterMap 
    Js.undefined
    type wrapRawResponseRaw
  let wrapRawResponseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{}|json}
  ]
  let wrapRawResponseConverterMap = ()
  let convertWrapRawResponse v = RescriptRelay.convertObj v 
    wrapRawResponseConverter 
    wrapRawResponseConverterMap 
    Js.null
    type rawResponseRaw
  let rawResponseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{}|json}
  ]
  let rawResponseConverterMap = ()
  let convertRawResponse v = RescriptRelay.convertObj v 
    rawResponseConverter 
    rawResponseConverterMap 
    Js.undefined
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
    external makeVariables: (
    ~connections: RescriptRelay.dataId array,
    ~onlineStatus: [
      | `Idle
      | `Offline
      | `Online
    ],
  ) -> variables = "" [@@bs.obj]


  external makeOptimisticResponse: (
    ~setOnlineStatus: rawResponse_setOnlineStatus=?,
    unit
  ) -> rawResponse = "" [@@bs.obj]


  external make_rawResponse_setOnlineStatus_user: (
    ~__id: RescriptRelay.dataId=?,
    ~firstName: string,
    ~id: string,
    ~lastName: string,
    ~onlineStatus: [
      | `Idle
      | `Offline
      | `Online
    ]=?,
    unit
  ) -> rawResponse_setOnlineStatus_user = "" [@@bs.obj]


  external make_rawResponse_setOnlineStatus: (
    ~user: rawResponse_setOnlineStatus_user=?,
    unit
  ) -> rawResponse_setOnlineStatus = "" [@@bs.obj]


end

type relayOperationNode
type operationType = relayOperationNode RescriptRelay.mutationNode


let node: operationType = [%bs.raw {json| (function(){
var v0 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "connections"
},
v1 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "onlineStatus"
},
v2 = [
  {
    "kind": "Variable",
    "name": "onlineStatus",
    "variableName": "onlineStatus"
  }
],
v3 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v4 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "onlineStatus",
  "storageKey": null
},
v5 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "firstName",
  "storageKey": null
},
v6 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "lastName",
  "storageKey": null
};
return {
  "fragment": {
    "argumentDefinitions": [
      (v0/*: any*/),
      (v1/*: any*/)
    ],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestMutationSetOnlineStatusMutation",
    "selections": [
      {
        "alias": null,
        "args": (v2/*: any*/),
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
              (v3/*: any*/),
              (v4/*: any*/),
              {
                "args": null,
                "kind": "FragmentSpread",
                "name": "TestFragment_user"
              }
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
      (v0/*: any*/)
    ],
    "kind": "Operation",
    "name": "TestMutationSetOnlineStatusMutation",
    "selections": [
      {
        "alias": null,
        "args": (v2/*: any*/),
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
              (v3/*: any*/),
              (v4/*: any*/),
              (v5/*: any*/),
              (v6/*: any*/),
              {
                "name": "greeting",
                "args": null,
                "fragment": {
                  "kind": "InlineFragment",
                  "selections": [
                    (v5/*: any*/),
                    (v6/*: any*/)
                  ],
                  "type": "User",
                  "abstractKey": null
                },
                "kind": "RelayResolver",
                "storageKey": null,
                "isOutputType": false
              },
              {
                "kind": "ClientExtension",
                "selections": [
                  {
                    "alias": null,
                    "args": null,
                    "kind": "ScalarField",
                    "name": "__id",
                    "storageKey": null
                  }
                ]
              }
            ],
            "storageKey": null
          },
          {
            "alias": null,
            "args": null,
            "filters": null,
            "handle": "appendNode",
            "key": "",
            "kind": "LinkedHandle",
            "name": "user",
            "handleArgs": [
              {
                "kind": "Variable",
                "name": "connections",
                "variableName": "connections"
              },
              {
                "kind": "Literal",
                "name": "edgeTypeName",
                "value": "UserEdge"
              }
            ]
          }
        ],
        "storageKey": null
      }
    ]
  },
  "params": {
    "cacheID": "710258c627f5e34c207ecabe06d5da8c",
    "id": null,
    "metadata": {},
    "name": "TestMutationSetOnlineStatusMutation",
    "operationKind": "mutation",
    "text": "mutation TestMutationSetOnlineStatusMutation(\n  $onlineStatus: OnlineStatus!\n) {\n  setOnlineStatus(onlineStatus: $onlineStatus) {\n    user {\n      id\n      onlineStatus\n      ...TestFragment_user\n    }\n  }\n}\n\nfragment TestFragment_sub_user on User {\n  lastName\n  ...TestRelayResolver\n}\n\nfragment TestFragment_user on User {\n  firstName\n  onlineStatus\n  ...TestFragment_sub_user\n}\n\nfragment TestRelayResolver on User {\n  firstName\n  lastName\n}\n"
  }
};
})() |json}]


