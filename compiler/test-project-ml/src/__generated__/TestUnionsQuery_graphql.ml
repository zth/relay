(* @sourceLoc Test_unions.ml *)
(* @generated *)
[%%mel.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type response_members_edges_node_Group_members_Group = {
    __typename: [ | `Group] [@live];
    avatarUrl: string option;
    id: string [@live];
    name: string;
  }
  and response_members_edges_node_Group_members_User = {
    __typename: [ | `User] [@live];
    firstName: string;
    id: string [@live];
    onlineStatus: RelaySchemaAssets_graphql.enum_OnlineStatus option;
  }
  and response_members_edges_node_Group = {
    __typename: [ | `Group] [@live];
    avatarUrl: string option;
    id: string [@live];
    members: response_members_edges_node_Group_members option array option;
    name: string;
  }
  and response_members_edges_node_User = {
    __typename: [ | `User] [@live];
    firstName: string;
    id: string [@live];
    onlineStatus: RelaySchemaAssets_graphql.enum_OnlineStatus option;
  }
  and response_members_edges_node_Group_members = [
    | `Group of response_members_edges_node_Group_members_Group
    | `User of response_members_edges_node_Group_members_User
    | `UnselectedUnionMember of string
  ]

  and response_members_edges_node = [
    | `Group of response_members_edges_node_Group
    | `User of response_members_edges_node_User
    | `UnselectedUnionMember of string
  ]

  type response_members_edges = {
    node: response_members_edges_node option;
  }
  and response_members = {
    edges: response_members_edges option array option;
  }
  type response = {
    members: response_members option;
  }
  type rawResponse = response
  type variables = unit
  type refetchVariables = unit
  let makeRefetchVariables () = ()
end

let unwrap_response_members_edges_node_Group_members: < __typename: string > Js.t -> [
  | `Group of Types.response_members_edges_node_Group_members_Group
  | `User of Types.response_members_edges_node_Group_members_User
  | `UnselectedUnionMember of string
] = fun u -> match u##__typename with 
  | "Group" -> `Group (Obj.magic u)
  | "User" -> `User (Obj.magic u)
  | v -> `UnselectedUnionMember v
let wrap_response_members_edges_node_Group_members: [
  | `Group of Types.response_members_edges_node_Group_members_Group
  | `User of Types.response_members_edges_node_Group_members_User
  | `UnselectedUnionMember of string
] -> < __typename: string > Js.t = function 
  | `Group(v) -> Obj.magic v
  | `User(v) -> Obj.magic v
  | `UnselectedUnionMember v -> [%mel.obj { __typename = v }]
let unwrap_response_members_edges_node: < __typename: string > Js.t -> [
  | `Group of Types.response_members_edges_node_Group
  | `User of Types.response_members_edges_node_User
  | `UnselectedUnionMember of string
] = fun u -> match u##__typename with 
  | "Group" -> `Group (Obj.magic u)
  | "User" -> `User (Obj.magic u)
  | v -> `UnselectedUnionMember v
let wrap_response_members_edges_node: [
  | `Group of Types.response_members_edges_node_Group
  | `User of Types.response_members_edges_node_User
  | `UnselectedUnionMember of string
] -> < __typename: string > Js.t = function 
  | `Group(v) -> Obj.magic v
  | `User(v) -> Obj.magic v
  | `UnselectedUnionMember v -> [%mel.obj { __typename = v }]
module Internal = struct
  let variablesConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
    {json|{}|json}
  ]
  let variablesConverterMap = ()
  let convertVariables v = Melange_relay.convertObj v 
    variablesConverter 
    variablesConverterMap 
    Js.undefined
    type wrapResponseRaw
  let wrapResponseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
    {json|{"__root":{"members_edges_node_Group_members":{"u":"response_members_edges_node_Group_members"},"members_edges_node":{"u":"response_members_edges_node"}}}|json}
  ]
  let wrapResponseConverterMap = let o = Js.Dict.empty () in 
    Js.Dict.set o "response_members_edges_node_Group_members" (Obj.magic wrap_response_members_edges_node_Group_members : unit);
    Js.Dict.set o "response_members_edges_node" (Obj.magic wrap_response_members_edges_node : unit);
  o
  let convertWrapResponse v = Melange_relay.convertObj v 
    wrapResponseConverter 
    wrapResponseConverterMap 
    Js.null
    type responseRaw
  let responseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
    {json|{"__root":{"members_edges_node_Group_members":{"u":"response_members_edges_node_Group_members"},"members_edges_node":{"u":"response_members_edges_node"}}}|json}
  ]
  let responseConverterMap = let o = Js.Dict.empty () in 
    Js.Dict.set o "response_members_edges_node_Group_members" (Obj.magic unwrap_response_members_edges_node_Group_members : unit);
    Js.Dict.set o "response_members_edges_node" (Obj.magic unwrap_response_members_edges_node : unit);
  o
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
  external onlineStatus_toString: RelaySchemaAssets_graphql.enum_OnlineStatus -> string = "%identity"
  external onlineStatus_input_toString: RelaySchemaAssets_graphql.enum_OnlineStatus_input -> string = "%identity"
  let onlineStatus_decode (enum: RelaySchemaAssets_graphql.enum_OnlineStatus): RelaySchemaAssets_graphql.enum_OnlineStatus_input option =
    (match enum with
      | #RelaySchemaAssets_graphql.enum_OnlineStatus_input as valid -> Some(valid)
      | _ -> None
    )
    let onlineStatus_fromString (str: string): RelaySchemaAssets_graphql.enum_OnlineStatus_input option =
    onlineStatus_decode (Obj.magic str)
    external makeVariables: unit -> unit = "" [@@mel.obj]
end

type relayOperationNode
type operationType = relayOperationNode Melange_relay.queryNode


let node: operationType = [%mel.raw {json| (function(){
var v0 = [
  {
    "kind": "Literal",
    "name": "groupId",
    "value": "123"
  }
],
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
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
  "kind": "InlineFragment",
  "selections": [
    (v2/*: any*/),
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "firstName",
      "storageKey": null
    },
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "onlineStatus",
      "storageKey": null
    }
  ],
  "type": "User",
  "abstractKey": null
},
v4 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "name",
  "storageKey": null
},
v5 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "avatarUrl",
  "storageKey": null
},
v6 = {
  "kind": "InlineFragment",
  "selections": [
    (v2/*: any*/),
    (v4/*: any*/),
    (v5/*: any*/)
  ],
  "type": "Group",
  "abstractKey": null
},
v7 = {
  "kind": "InlineFragment",
  "selections": [
    (v2/*: any*/)
  ],
  "type": "Node",
  "abstractKey": "__isNode"
};
return {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestUnionsQuery",
    "selections": [
      {
        "alias": null,
        "args": (v0/*: any*/),
        "concreteType": "MemberConnection",
        "kind": "LinkedField",
        "name": "members",
        "plural": false,
        "selections": [
          {
            "alias": null,
            "args": null,
            "concreteType": "MemberEdge",
            "kind": "LinkedField",
            "name": "edges",
            "plural": true,
            "selections": [
              {
                "alias": null,
                "args": null,
                "concreteType": null,
                "kind": "LinkedField",
                "name": "node",
                "plural": false,
                "selections": [
                  (v1/*: any*/),
                  (v3/*: any*/),
                  {
                    "kind": "InlineFragment",
                    "selections": [
                      (v2/*: any*/),
                      (v4/*: any*/),
                      (v5/*: any*/),
                      {
                        "alias": null,
                        "args": null,
                        "concreteType": null,
                        "kind": "LinkedField",
                        "name": "members",
                        "plural": true,
                        "selections": [
                          (v1/*: any*/),
                          (v3/*: any*/),
                          (v6/*: any*/)
                        ],
                        "storageKey": null
                      }
                    ],
                    "type": "Group",
                    "abstractKey": null
                  }
                ],
                "storageKey": null
              }
            ],
            "storageKey": null
          }
        ],
        "storageKey": "members(groupId:\"123\")"
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "TestUnionsQuery",
    "selections": [
      {
        "alias": null,
        "args": (v0/*: any*/),
        "concreteType": "MemberConnection",
        "kind": "LinkedField",
        "name": "members",
        "plural": false,
        "selections": [
          {
            "alias": null,
            "args": null,
            "concreteType": "MemberEdge",
            "kind": "LinkedField",
            "name": "edges",
            "plural": true,
            "selections": [
              {
                "alias": null,
                "args": null,
                "concreteType": null,
                "kind": "LinkedField",
                "name": "node",
                "plural": false,
                "selections": [
                  (v1/*: any*/),
                  (v3/*: any*/),
                  {
                    "kind": "InlineFragment",
                    "selections": [
                      (v2/*: any*/),
                      (v4/*: any*/),
                      (v5/*: any*/),
                      {
                        "alias": null,
                        "args": null,
                        "concreteType": null,
                        "kind": "LinkedField",
                        "name": "members",
                        "plural": true,
                        "selections": [
                          (v1/*: any*/),
                          (v3/*: any*/),
                          (v6/*: any*/),
                          (v7/*: any*/)
                        ],
                        "storageKey": null
                      }
                    ],
                    "type": "Group",
                    "abstractKey": null
                  },
                  (v7/*: any*/)
                ],
                "storageKey": null
              }
            ],
            "storageKey": null
          }
        ],
        "storageKey": "members(groupId:\"123\")"
      }
    ]
  },
  "params": {
    "cacheID": "7796bda6800b2da0ffac4f5a3b38b745",
    "id": null,
    "metadata": {},
    "name": "TestUnionsQuery",
    "operationKind": "query",
    "text": "query TestUnionsQuery {\n  members(groupId: \"123\") {\n    edges {\n      node {\n        __typename\n        ... on User {\n          id\n          firstName\n          onlineStatus\n        }\n        ... on Group {\n          id\n          name\n          avatarUrl\n          members {\n            __typename\n            ... on User {\n              id\n              firstName\n              onlineStatus\n            }\n            ... on Group {\n              id\n              name\n              avatarUrl\n            }\n            ... on Node {\n              __isNode: __typename\n              __typename\n              id\n            }\n          }\n        }\n        ... on Node {\n          __isNode: __typename\n          __typename\n          id\n        }\n      }\n    }\n  }\n}\n"
  }
};
})() |json}]

include Melange_relay.MakeLoadQuery(struct
            type variables = Types.variables
            type loadedQueryRef = queryRef
            type response = Types.response
            type node = relayOperationNode
            let query = node
            let convertVariables = Internal.convertVariables
        end)
