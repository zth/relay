/* @sourceLoc Test_connections.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type rec fragment_member_User_friendsConnection_edges_node = {
    @live id: string,
  }
  and fragment_member_User_friendsConnection_edges = {
    node: option<fragment_member_User_friendsConnection_edges_node>,
  }
  and fragment_member_User_friendsConnection = {
    edges: option<array<option<fragment_member_User_friendsConnection_edges>>>,
  }
  @tag("__typename") and fragment_member = 
    | @live User(
      {
        @live __typename: [ | #User],
        friendsConnection: fragment_member_User_friendsConnection,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  type fragment_t = {
    member: option<fragment_member>,
  }
  type fragment = array<fragment_t>
}

@live
let unwrap_fragment_member: Types.fragment_member => Types.fragment_member = RescriptRelay_Internal.unwrapUnion(_, ["User"])
@live
let wrap_fragment_member: Types.fragment_member => Types.fragment_member = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  type fragmentRaw
  @live
  let fragmentConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"__root":{"member":{"u":"fragment_member"}}}`
  )
  @live
  let fragmentConverterMap = {
    "fragment_member": unwrap_fragment_member,
  }
  @live
  let convertFragment = v => v->RescriptRelay.convertObj(
    fragmentConverter,
    fragmentConverterMap,
    Js.undefined
  )
}

type t
type fragmentRef
external getFragmentRef:
  array<RescriptRelay.fragmentRefs<[> | #TestConnectionsUnionPlural_user]>> => fragmentRef = "%identity"

@live
@inline
let connectionKey = "TestConnections_user_friendsConnection"

%%private(
  @live @module("relay-runtime") @scope("ConnectionHandler")
  external internal_makeConnectionId: (RescriptRelay.dataId, @as("TestConnections_user_friendsConnection") _, 'arguments) => RescriptRelay.dataId = "getConnectionID"
)

@live
let makeConnectionId = (connectionParentDataId: RescriptRelay.dataId, ~onlineStatuses: array<RelaySchemaAssets_graphql.enum_OnlineStatus>=[Idle], ~beforeDate: SomeModule.Datetime.t, ~someInput: option<RelaySchemaAssets_graphql.input_SomeInput>=?) => {
  let onlineStatuses = Some(onlineStatuses)
  let beforeDate = Some(SomeModule.Datetime.serialize(beforeDate))
  let args = {"statuses": onlineStatuses, "beforeDate": beforeDate, "objTests": [RescriptRelay_Internal.Arg(Some({"int": Some(123)})), RescriptRelay_Internal.Arg(Some({"str": Some("Hello")})), RescriptRelay_Internal.Arg(someInput)]}
  internal_makeConnectionId(connectionParentDataId, args)
}
module Utils = {
  @@warning("-33")
  open Types

  @live
  let getConnectionNodes: Types.fragment_member_User_friendsConnection => array<Types.fragment_member_User_friendsConnection_edges_node> = connection => 
    switch connection.edges {
      | None => []
      | Some(edges) => edges
        ->Belt.Array.keepMap(edge => switch edge {
          | None => None
          | Some(edge) => edge.node
        })
    }


}

type relayOperationNode
type operationType = RescriptRelay.fragmentNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
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
    ],
    "plural": true
  },
  "name": "TestConnectionsUnionPlural_user",
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
})() `)

