(* @sourceLoc Test_connections.ml *)
(* @generated *)
[%%mel.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type fragment_member_User_friendsConnection_edges_node = {
    id: string [@live];
  }
  and fragment_member_User_friendsConnection_edges = {
    node: fragment_member_User_friendsConnection_edges_node option;
  }
  and fragment_member_User_friendsConnection = {
    edges: fragment_member_User_friendsConnection_edges option array option;
  }
  and fragment_member_User = {
    __typename: [ | `User] [@live];
    friendsConnection: fragment_member_User_friendsConnection;
  }
  and fragment_member = [
    | `User of fragment_member_User
    | `UnselectedUnionMember of string
  ]

  type fragment = {
    member: fragment_member option;
  }
end

let unwrap_fragment_member: < __typename: string > Js.t -> [
  | `User of Types.fragment_member_User
  | `UnselectedUnionMember of string
] = fun u -> match u##__typename with 
  | "User" -> `User (Obj.magic u)
  | v -> `UnselectedUnionMember v
let wrap_fragment_member: [
  | `User of Types.fragment_member_User
  | `UnselectedUnionMember of string
] -> < __typename: string > Js.t = function 
  | `User(v) -> Obj.magic v
  | `UnselectedUnionMember v -> [%mel.obj { __typename = v }]
module Internal = struct
  type fragmentRaw
  let fragmentConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
    {json|{"__root":{"member":{"u":"fragment_member"}}}|json}
  ]
  let fragmentConverterMap = let o = Js.Dict.empty () in 
    Js.Dict.set o "fragment_member" (Obj.magic unwrap_fragment_member : unit);
  o
  let convertFragment v = Melange_relay.convertObj v 
    fragmentConverter 
    fragmentConverterMap 
    Js.undefined
  end

type t
type fragmentRef
external getFragmentRef:
  [> | `TestConnectionsUnion_user] Melange_relay.fragmentRefs -> fragmentRef = "%identity"

let connectionKey = "TestConnections_user_friendsConnection"

[@@mel.inline]
[%%private
  external internal_makeConnectionId: Melange_relay.dataId -> (_ [@mel.as "TestConnections_user_friendsConnection"]) -> 'arguments -> Melange_relay.dataId = "getConnectionID"
[@@live] [@@mel.module "relay-runtime"] [@@mel.scope "ConnectionHandler"]

]let makeConnectionId (connectionParentDataId: Melange_relay.dataId) ?(onlineStatuses: [`Online | `Idle | `Offline] array=[| `Idle |]) ~(beforeDate: SomeModule.Datetime.t) ?(someInput: RelaySchemaAssets_graphql.input_SomeInput option) () =
  let onlineStatuses = Some onlineStatuses in
  let beforeDate = Some (SomeModule.Datetime.serialize beforeDate) in
  let args = [%mel.obj {statuses= onlineStatuses; beforeDate= beforeDate; objTests= [Melange_relay.Internal.Arg(Some([%mel.obj {int = Some(123)}])); Melange_relay.Internal.Arg(Some([%mel.obj {str = Some("Hello")}])); Melange_relay.Internal.Arg(someInput)]}] in
  internal_makeConnectionId connectionParentDataId args
module Utils = struct
  [@@@ocaml.warning "-33"]
  open Types

  let getConnectionNodes: Types.fragment_member_User_friendsConnection -> Types.fragment_member_User_friendsConnection_edges_node array = fun connection -> 
    begin match connection.edges with
      | None -> [||]
      | Some edges -> edges
        |. Belt.Array.keepMap(function 
          | None -> None
          | Some edge -> edge.node
        )
    end


end

type relayOperationNode
type operationType = relayOperationNode Melange_relay.fragmentNode


let node: operationType = [%mel.raw {json| (function(){
var v0 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
  "storageKey": null
};
return {
  "argumentDefinitions": [
    {
      "defaultValue": null,
      "kind": "LocalArgument",
      "name": "beforeDate"
    },
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
      "defaultValue": [
        "Idle"
      ],
      "kind": "LocalArgument",
      "name": "onlineStatuses"
    },
    {
      "defaultValue": null,
      "kind": "LocalArgument",
      "name": "someInput"
    }
  ],
  "kind": "Fragment",
  "metadata": {
    "connection": [
      {
        "count": "count",
        "cursor": "cursor",
        "direction": "forward",
        "path": [
          "member",
          "friendsConnection"
        ]
      }
    ]
  },
  "name": "TestConnectionsUnion_user",
  "selections": [
    {
      "alias": null,
      "args": [
        {
          "kind": "Literal",
          "name": "id",
          "value": "123"
        }
      ],
      "concreteType": null,
      "kind": "LinkedField",
      "name": "member",
      "plural": false,
      "selections": [
        (v0/*: any*/),
        {
          "kind": "InlineFragment",
          "selections": [
            {
              "alias": "friendsConnection",
              "args": [
                {
                  "kind": "Variable",
                  "name": "beforeDate",
                  "variableName": "beforeDate"
                },
                {
                  "items": [
                    {
                      "kind": "Literal",
                      "name": "objTests.0",
                      "value": {
                        "int": 123
                      }
                    },
                    {
                      "kind": "Literal",
                      "name": "objTests.1",
                      "value": {
                        "str": "Hello"
                      }
                    },
                    {
                      "kind": "Variable",
                      "name": "objTests.2",
                      "variableName": "someInput"
                    }
                  ],
                  "kind": "ListValue",
                  "name": "objTests"
                },
                {
                  "kind": "Variable",
                  "name": "statuses",
                  "variableName": "onlineStatuses"
                }
              ],
              "concreteType": "UserConnection",
              "kind": "LinkedField",
              "name": "__TestConnections_user_friendsConnection_connection",
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
                        {
                          "alias": null,
                          "args": null,
                          "kind": "ScalarField",
                          "name": "id",
                          "storageKey": null
                        },
                        (v0/*: any*/)
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
          "type": "User",
          "abstractKey": null
        }
      ],
      "storageKey": "member(id:\"123\")"
    }
  ],
  "type": "Query",
  "abstractKey": null
};
})() |json}]

