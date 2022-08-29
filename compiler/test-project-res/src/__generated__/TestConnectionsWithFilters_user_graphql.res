/* @sourceLoc Test_connections.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@ocaml.warning("-30")

  type rec fragment_friendsConnection_edges_node = {
    @live id: string,
  }
  and fragment_friendsConnection_edges = {
    node: option<fragment_friendsConnection_edges_node>,
  }
  and fragment_friendsConnection = {
    edges: option<array<option<fragment_friendsConnection_edges>>>,
  }
  type fragment = {
    friendsConnection: fragment_friendsConnection,
  }
}

module Internal = {
  @live
  type fragmentRaw
  @live
  let fragmentConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{}`
  )
  @live
  let fragmentConverterMap = ()
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
  RescriptRelay.fragmentRefs<[> | #TestConnectionsWithFilters_user]> => fragmentRef = "%identity"

module Utils = {
  @@ocaml.warning("-33")
  open Types
  @live
  @inline
  let connectionKey = "TestConnectionsWithFilters_user_friendsConnection"

  %%private(
    @live @module("relay-runtime") @scope("ConnectionHandler")
    external internal_makeConnectionId: (RescriptRelay.dataId, @as("TestConnectionsWithFilters_user_friendsConnection") _, 'arguments) => RescriptRelay.dataId = "getConnectionID"
  )

  let makeConnectionId = (connectionParentDataId: RescriptRelay.dataId, ~onlineStatuses: option<array<[#Online | #Idle | #Offline]>>=?, ~objTest: RelaySchemaAssets_graphql.input_SomeInput=Obj.magic({"str": "123"}), ()) => {
    let objTest = Some(objTest)
    let args = {"statuses": onlineStatuses, "objTest": objTest}
    internal_makeConnectionId(connectionParentDataId, args)
  }
  @live
  let getConnectionNodes: fragment_friendsConnection => array<fragment_friendsConnection_edges_node> = connection => 
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


let node: operationType = %raw(json` {
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
      "defaultValue": {
        "str": "123"
      },
      "kind": "LocalArgument",
      "name": "objTest"
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
        "path": [
          "friendsConnection"
        ]
      }
    ]
  },
  "name": "TestConnectionsWithFilters_user",
  "selections": [
    {
      "alias": "friendsConnection",
      "args": [
        {
          "kind": "Variable",
          "name": "objTest",
          "variableName": "objTest"
        },
        {
          "kind": "Variable",
          "name": "statuses",
          "variableName": "onlineStatuses"
        }
      ],
      "concreteType": "UserConnection",
      "kind": "LinkedField",
      "name": "__TestConnectionsWithFilters_user_friendsConnection_connection",
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
                {
                  "alias": null,
                  "args": null,
                  "kind": "ScalarField",
                  "name": "__typename",
                  "storageKey": null
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
  "type": "User",
  "abstractKey": null
} `)

