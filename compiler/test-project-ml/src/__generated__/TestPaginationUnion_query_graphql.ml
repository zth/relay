(* @sourceLoc Test_paginationUnion.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type fragment_members_edges_node_Group_adminsConnection_edges_node = {
    firstName: string;
    id: string [@live];
  }
  and fragment_members_edges_node_Group_adminsConnection_edges = {
    node: fragment_members_edges_node_Group_adminsConnection_edges_node option;
  }
  and fragment_members_edges_node_Group_adminsConnection = {
    edges: fragment_members_edges_node_Group_adminsConnection_edges option array option;
  }
  and fragment_members_edges_node_Group = {
    __typename: [ | `Group] [@live];
    adminsConnection: fragment_members_edges_node_Group_adminsConnection;
    id: string [@live];
    name: string;
  }
  and fragment_members_edges_node_User = {
    __typename: [ | `User] [@live];
    id: string [@live];
    fragmentRefs: [ | `TestPaginationUnion_user] RescriptRelay.fragmentRefs;
  }
  and fragment_members_edges_node = [
    | `Group of fragment_members_edges_node_Group
    | `User of fragment_members_edges_node_User
    | `UnselectedUnionMember of string
  ]

  type fragment_members_edges = {
    node: fragment_members_edges_node option;
  }
  and fragment_members = {
    edges: fragment_members_edges option array option;
  }
  type fragment = {
    members: fragment_members option;
  }
end

let unwrap_fragment_members_edges_node: < __typename: string > Js.t -> [
  | `Group of Types.fragment_members_edges_node_Group
  | `User of Types.fragment_members_edges_node_User
  | `UnselectedUnionMember of string
] = fun u -> match u##__typename with 
  | "Group" -> `Group (Obj.magic u)
  | "User" -> `User (Obj.magic u)
  | v -> `UnselectedUnionMember v
let wrap_fragment_members_edges_node: [
  | `Group of Types.fragment_members_edges_node_Group
  | `User of Types.fragment_members_edges_node_User
  | `UnselectedUnionMember of string
] -> < __typename: string > Js.t = function 
  | `Group(v) -> Obj.magic v
  | `User(v) -> Obj.magic v
  | `UnselectedUnionMember v -> [%bs.obj { __typename = v }]
module Internal = struct
  type fragmentRaw
  let fragmentConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"__root":{"members_edges_node_User":{"f":""},"members_edges_node":{"u":"fragment_members_edges_node"}}}|json}
  ]
  let fragmentConverterMap = let o = Js.Dict.empty () in 
    Js.Dict.set o "fragment_members_edges_node" unwrap_fragment_members_edges_node;
  o
  let convertFragment v = RescriptRelay.convertObj v 
    fragmentConverter 
    fragmentConverterMap 
    Js.undefined
  end

type t
type fragmentRef
external getFragmentRef:
  [> | `TestPaginationUnion_query] RescriptRelay.fragmentRefs -> fragmentRef = "%identity"

let connectionKey = "TestPaginationUnion_query_members"

[@@bs.inline]
[%%private
  external internal_makeConnectionId: RescriptRelay.dataId -> (_ [@bs.as "TestPaginationUnion_query_members"]) -> 'arguments -> RescriptRelay.dataId = "getConnectionID"
[@@live] [@@bs.module "relay-runtime"] [@@bs.scope "ConnectionHandler"]

]let makeConnectionId (connectionParentDataId: RescriptRelay.dataId) ~(groupId: string) ?(onlineStatuses: [`Online | `Idle | `Offline] array option) () =
  let groupId = Some groupId in
  let args = [%bs.obj {groupId= groupId; onlineStatuses= onlineStatuses}] in
  internal_makeConnectionId(connectionParentDataId, args)
module Utils = struct
  [@@@ocaml.warning "-33"]
  open Types

  let getConnectionNodes: Types.fragment_members option -> Types.fragment_members_edges_node array = fun connection -> 
    begin match connection with
      | None -> []
      | Some connection -> 
        begin match connection.edges with
          | None -> []
          | Some edges -> edges
            |. Belt.Array.keepMap(function 
              | None -> None
              | Some edge -> edge.node
            )
        end
    end


end

type relayOperationNode
type operationType = relayOperationNode RescriptRelay.fragmentNode


[%%private let makeNode rescript_graphql_node_TestPaginationUnionRefetchQuery: operationType = 
  ignore rescript_graphql_node_TestPaginationUnionRefetchQuery;
  [%raw {json|(function(){
var v0 = [
  "members"
],
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
};
return {
  "argumentDefinitions": [
    {
      "defaultValue": 2,
      "kind": "LocalArgument",
      "name": "count"
    },
    {
      "defaultValue": "",
      "kind": "LocalArgument",
      "name": "cursor"
    },
    {
      "defaultValue": null,
      "kind": "LocalArgument",
      "name": "groupId"
    },
    {
      "defaultValue": null,
      "kind": "LocalArgument",
      "name": "onlineStatuses"
    }
  ],
  "kind": "Fragment",
  "metadata": {
    "connection": [
      {
        "count": "count",
        "cursor": "cursor",
        "direction": "forward",
        "path": (v0/*: any*/)
      }
    ],
    "refetch": {
      "connection": {
        "forward": {
          "count": "count",
          "cursor": "cursor"
        },
        "backward": null,
        "path": (v0/*: any*/)
      },
      "fragmentPathInResult": [],
      "operation": rescript_graphql_node_TestPaginationUnionRefetchQuery
    }
  },
  "name": "TestPaginationUnion_query",
  "selections": [
    {
      "alias": "members",
      "args": [
        {
          "kind": "Variable",
          "name": "groupId",
          "variableName": "groupId"
        },
        {
          "kind": "Variable",
          "name": "onlineStatuses",
          "variableName": "onlineStatuses"
        }
      ],
      "concreteType": "MemberConnection",
      "kind": "LinkedField",
      "name": "__TestPaginationUnion_query_members_connection",
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
                {
                  "alias": null,
                  "args": null,
                  "kind": "ScalarField",
                  "name": "__typename",
                  "storageKey": null
                },
                {
                  "kind": "InlineFragment",
                  "selections": [
                    (v1/*: any*/),
                    {
                      "args": null,
                      "kind": "FragmentSpread",
                      "name": "TestPaginationUnion_user"
                    }
                  ],
                  "type": "User",
                  "abstractKey": null
                },
                {
                  "kind": "InlineFragment",
                  "selections": [
                    (v1/*: any*/),
                    {
                      "alias": null,
                      "args": null,
                      "kind": "ScalarField",
                      "name": "name",
                      "storageKey": null
                    },
                    {
                      "alias": null,
                      "args": [
                        {
                          "kind": "Literal",
                          "name": "first",
                          "value": 1
                        }
                      ],
                      "concreteType": "UserConnection",
                      "kind": "LinkedField",
                      "name": "adminsConnection",
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
                                (v1/*: any*/),
                                {
                                  "alias": null,
                                  "args": null,
                                  "kind": "ScalarField",
                                  "name": "firstName",
                                  "storageKey": null
                                }
                              ],
                              "storageKey": null
                            }
                          ],
                          "storageKey": null
                        }
                      ],
                      "storageKey": "adminsConnection(first:1)"
                    }
                  ],
                  "type": "Group",
                  "abstractKey": null
                }
              ],
              "storageKey": null
            },
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "cursor",
              "storageKey": null
            }
          ],
          "storageKey": null
        },
        {
          "alias": null,
          "args": null,
          "concreteType": "PageInfo",
          "kind": "LinkedField",
          "name": "pageInfo",
          "plural": false,
          "selections": [
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "endCursor",
              "storageKey": null
            },
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "hasNextPage",
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
};
})()|json}]
]
let node: operationType = makeNode TestPaginationUnionRefetchQuery_graphql.node

