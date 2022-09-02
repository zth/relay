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
  RescriptRelay.fragmentRefs<[> | #TestConnectionsWithConstantValues_user]> => fragmentRef = "%identity"

@live
@inline
let connectionKey = "TestConnectionsWithonstantValues_user_friendsConnection"

%%private(
  @live @module("relay-runtime") @scope("ConnectionHandler")
  external internal_makeConnectionId: (RescriptRelay.dataId, @as("TestConnectionsWithonstantValues_user_friendsConnection") _, 'arguments) => RescriptRelay.dataId = "getConnectionID"
)

let makeConnectionId = (connectionParentDataId: RescriptRelay.dataId, ~onlineStatus: [#Online | #Idle | #Offline], ~beforeDate: SomeModule.Datetime.t, ~bool: option<bool>=?, ()) => {
  let onlineStatus = Some(onlineStatus)
  let beforeDate = Some(SomeModule.Datetime.serialize(beforeDate))
  let args = {"statuses": [Some(#Idle), onlineStatus], "beforeDate": beforeDate, "objTest": {"str": Some("123"), "bool": Some(false), "float": Some(12.2), "int": Some(64), "recursive": {"str": Some("234"), "bool": bool}}}
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


module Utils = {
  @@ocaml.warning("-33")
  open Types
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
      "defaultValue": null,
      "kind": "LocalArgument",
      "name": "bool"
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
      "defaultValue": null,
      "kind": "LocalArgument",
      "name": "onlineStatus"
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
  "name": "TestConnectionsWithConstantValues_user",
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
          "fields": [
            {
              "kind": "Literal",
              "name": "bool",
              "value": false
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
              "fields": [
                {
                  "kind": "Variable",
                  "name": "bool",
                  "variableName": "bool"
                },
                {
                  "kind": "Literal",
                  "name": "str",
                  "value": "234"
                }
              ],
              "kind": "ObjectValue",
              "name": "recursive"
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
      "name": "__TestConnectionsWithonstantValues_user_friendsConnection_connection",
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

