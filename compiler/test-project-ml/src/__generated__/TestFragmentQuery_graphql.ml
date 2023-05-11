(* @sourceLoc Test_fragment.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type response_loggedInUser = {
    fragmentRefs: [ | `TestFragment_allowUnsafeEnum | `TestFragment_ignoreUnused | `TestFragment_inline | `TestFragment_user] RescriptRelay.fragmentRefs;
  }
  and response_users_edges_node = {
    id: string [@live];
    onlineStatus: RelaySchemaAssets_graphql.enum_OnlineStatus option;
    fragmentRefs: [ | `TestFragment_plural_user] RescriptRelay.fragmentRefs;
  }
  and response_users_edges = {
    node: response_users_edges_node option;
  }
  and response_users = {
    edges: response_users_edges option array option;
  }
  type response = {
    loggedInUser: response_loggedInUser;
    users: response_users option;
  }
  type rawResponse = response
  type variables = unit
  type refetchVariables = unit
  let makeRefetchVariables () = ()
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
    {json|{"__root":{"users_edges_node":{"f":""},"loggedInUser":{"f":""}}}|json}
  ]
  let wrapResponseConverterMap = ()
  let convertWrapResponse v = RescriptRelay.convertObj v 
    wrapResponseConverter 
    wrapResponseConverterMap 
    Js.null
    type responseRaw
  let responseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"__root":{"users_edges_node":{"f":""},"loggedInUser":{"f":""}}}|json}
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
    external makeVariables: unit -> unit = ""
end

type relayOperationNode
type operationType = relayOperationNode RescriptRelay.queryNode


let node: operationType = [%bs.raw {json| (function(){
var v0 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "firstName",
  "storageKey": null
},
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "onlineStatus",
  "storageKey": null
},
v2 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v3 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "lastName",
  "storageKey": null
};
return {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestFragmentQuery",
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
            "name": "TestFragment_user"
          },
          {
            "kind": "InlineDataFragmentSpread",
            "name": "TestFragment_inline",
            "selections": [
              (v0/*: any*/),
              (v1/*: any*/)
            ],
            "args": null,
            "argumentDefinitions": []
          },
          {
            "args": null,
            "kind": "FragmentSpread",
            "name": "TestFragment_ignoreUnused"
          },
          {
            "args": null,
            "kind": "FragmentSpread",
            "name": "TestFragment_allowUnsafeEnum"
          }
        ],
        "storageKey": null
      },
      {
        "alias": null,
        "args": null,
        "concreteType": "UserConnection",
        "kind": "LinkedField",
        "name": "users",
        "plural": false,
        "selections": [
          {
            "alias": null,
            "args": null,
            "concreteType": "UserEdge",
            "kind": "LinkedField",
            "name": "edges",
            "plural": true,
            "selections": [
              {
                "alias": null,
                "args": null,
                "concreteType": "User",
                "kind": "LinkedField",
                "name": "node",
                "plural": false,
                "selections": [
                  (v2/*: any*/),
                  (v1/*: any*/),
                  {
                    "args": null,
                    "kind": "FragmentSpread",
                    "name": "TestFragment_plural_user"
                  }
                ],
                "storageKey": null
              }
            ],
            "storageKey": null
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
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "TestFragmentQuery",
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "loggedInUser",
        "plural": false,
        "selections": [
          (v0/*: any*/),
          (v1/*: any*/),
          (v3/*: any*/),
          {
            "name": "greeting",
            "args": null,
            "fragment": {
              "kind": "InlineFragment",
              "selections": [
                (v0/*: any*/),
                (v3/*: any*/)
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
          },
          (v1/*: any*/),
          (v2/*: any*/)
        ],
        "storageKey": null
      },
      {
        "alias": null,
        "args": null,
        "concreteType": "UserConnection",
        "kind": "LinkedField",
        "name": "users",
        "plural": false,
        "selections": [
          {
            "alias": null,
            "args": null,
            "concreteType": "UserEdge",
            "kind": "LinkedField",
            "name": "edges",
            "plural": true,
            "selections": [
              {
                "alias": null,
                "args": null,
                "concreteType": "User",
                "kind": "LinkedField",
                "name": "node",
                "plural": false,
                "selections": [
                  (v2/*: any*/),
                  (v1/*: any*/),
                  (v0/*: any*/)
                ],
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
    "cacheID": "635b45ab1a1db6575279f7418a418166",
    "id": null,
    "metadata": {},
    "name": "TestFragmentQuery",
    "operationKind": "query",
    "text": "query TestFragmentQuery {\n  loggedInUser {\n    ...TestFragment_user\n    ...TestFragment_inline\n    ...TestFragment_ignoreUnused\n    ...TestFragment_allowUnsafeEnum\n    id\n  }\n  users {\n    edges {\n      node {\n        id\n        onlineStatus\n        ...TestFragment_plural_user\n      }\n    }\n  }\n}\n\nfragment TestFragment_allowUnsafeEnum on User {\n  firstName\n  lastName\n  onlineStatus\n}\n\nfragment TestFragment_ignoreUnused on User {\n  firstName\n  lastName\n  onlineStatus\n}\n\nfragment TestFragment_inline on User {\n  firstName\n  onlineStatus\n}\n\nfragment TestFragment_plural_user on User {\n  id\n  firstName\n  onlineStatus\n}\n\nfragment TestFragment_sub_user on User {\n  lastName\n  ...TestRelayResolver\n}\n\nfragment TestFragment_user on User {\n  firstName\n  onlineStatus\n  ...TestFragment_sub_user\n}\n\nfragment TestRelayResolver on User {\n  firstName\n  lastName\n}\n"
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
