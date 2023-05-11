(* @sourceLoc Test_refetching.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type response_node = {
    __typename: string [@live];
    fragmentRefs: [ | `TestRefetching_user] RescriptRelay.fragmentRefs;
  }
  type response = {
    node: response_node option;
  }
  type rawResponse = response
  type variables = {
    friendsOnlineStatuses: [
      | `Idle
      | `Offline
      | `Online
    ] array option;
    id: string [@live];
    showOnlineStatus: bool option;
  }
  type refetchVariables = {
    friendsOnlineStatuses: [
      | `Idle
      | `Offline
      | `Online
    ] array option option;
    id: string option [@live];
    showOnlineStatus: bool option option;
  }
  let makeRefetchVariables 
    ?friendsOnlineStatuses 
    ?id 
    ?showOnlineStatus 
    ()
  : refetchVariables = {
    friendsOnlineStatuses= friendsOnlineStatuses;
    id= id;
    showOnlineStatus= showOnlineStatus
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
    {json|{"__root":{"node":{"f":""}}}|json}
  ]
  let wrapResponseConverterMap = ()
  let convertWrapResponse v = RescriptRelay.convertObj v 
    wrapResponseConverter 
    wrapResponseConverterMap 
    Js.null
    type responseRaw
  let responseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"__root":{"node":{"f":""}}}|json}
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

type queryRef

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
    external makeVariables:     ?friendsOnlineStatuses: [
      | `Idle
      | `Offline
      | `Online
    ] array-> 
    id: string-> 
    ?showOnlineStatus: bool-> 
    unit
   variables = "" [@@bs.obj]


end

type relayOperationNode
type operationType = relayOperationNode RescriptRelay.queryNode


let node: operationType = [%bs.raw {json| (function(){
var v0 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "friendsOnlineStatuses"
},
v1 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "id"
},
v2 = {
  "defaultValue": false,
  "kind": "LocalArgument",
  "name": "showOnlineStatus"
},
v3 = [
  {
    "kind": "Variable",
    "name": "id",
    "variableName": "id"
  }
],
v4 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
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
    "name": "TestRefetchingRefetchQuery",
    "selections": [
      {
        "alias": null,
        "args": (v3/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "node",
        "plural": false,
        "selections": [
          (v4/*: any*/),
          {
            "args": [
              {
                "kind": "Variable",
                "name": "friendsOnlineStatuses",
                "variableName": "friendsOnlineStatuses"
              },
              {
                "kind": "Variable",
                "name": "showOnlineStatus",
                "variableName": "showOnlineStatus"
              }
            ],
            "kind": "FragmentSpread",
            "name": "TestRefetching_user"
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
      (v0/*: any*/),
      (v2/*: any*/),
      (v1/*: any*/)
    ],
    "kind": "Operation",
    "name": "TestRefetchingRefetchQuery",
    "selections": [
      {
        "alias": null,
        "args": (v3/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "node",
        "plural": false,
        "selections": [
          (v4/*: any*/),
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "id",
            "storageKey": null
          },
          {
            "kind": "InlineFragment",
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
                    "name": "statuses",
                    "variableName": "friendsOnlineStatuses"
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
                    "name": "totalCount",
                    "storageKey": null
                  }
                ],
                "storageKey": null
              },
              {
                "condition": "showOnlineStatus",
                "kind": "Condition",
                "passingValue": true,
                "selections": [
                  {
                    "alias": null,
                    "args": null,
                    "kind": "ScalarField",
                    "name": "onlineStatus",
                    "storageKey": null
                  }
                ]
              }
            ],
            "type": "User",
            "abstractKey": null
          }
        ],
        "storageKey": null
      }
    ]
  },
  "params": {
    "cacheID": "a85f97ff6b8784ce7ba09fc040bcd33c",
    "id": null,
    "metadata": {},
    "name": "TestRefetchingRefetchQuery",
    "operationKind": "query",
    "text": "query TestRefetchingRefetchQuery(\n  $friendsOnlineStatuses: [OnlineStatus!]\n  $showOnlineStatus: Boolean = false\n  $id: ID!\n) {\n  node(id: $id) {\n    __typename\n    ...TestRefetching_user_lLXHd\n    id\n  }\n}\n\nfragment TestRefetching_user_lLXHd on User {\n  firstName\n  onlineStatus @include(if: $showOnlineStatus)\n  friendsConnection(statuses: $friendsOnlineStatuses) {\n    totalCount\n  }\n  id\n}\n"
  }
};
})() |json}]

include RescriptRelay.MakeLoadQuery(struct
            type variables = Types.variables
            type loadedQueryRef = queryRef
            type response = Types.response
            type node = relayOperationNode
            let query = node
            let convertVariables = Internal.convertVariables
        end)
