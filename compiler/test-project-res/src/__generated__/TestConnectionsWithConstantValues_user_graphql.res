/* @sourceLoc Test_connections.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

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

@live
let makeConnectionId = (connectionParentDataId: RescriptRelay.dataId, ~onlineStatus: RelaySchemaAssets_graphql.enum_OnlineStatus, ~beforeDate: SomeModule.Datetime.t, ~datetime: Js.null<SomeModule.Datetime.t>=Js.null, ~bool: option<bool>=?, ~flt: Js.null<float>=Js.null, ~datetime2: option<SomeModule.Datetime.t>=?, ~datetime3: SomeModule.Datetime.t, ()) => {
  let onlineStatus = Some(onlineStatus)
  let beforeDate = Some(SomeModule.Datetime.serialize(beforeDate))
  let datetime = datetime->Js.Null.toOption
  let datetime = switch datetime { | None => None | Some(v) => Some(SomeModule.Datetime.serialize(v)) }
  let flt = flt->Js.Null.toOption
  let datetime2 = switch datetime2 { | None => None | Some(v) => Some(SomeModule.Datetime.serialize(v)) }
  let datetime3 = Some(SomeModule.Datetime.serialize(datetime3))
  let args = {"statuses": [RescriptRelay_Internal.Arg(Some("Idle")), RescriptRelay_Internal.Arg(onlineStatus)], "beforeDate": beforeDate, "objTest": {"str": Some("123"), "bool": Some(false), "float": Some(12.2), "int": Some(64), "datetime": datetime, "recursive": {"str": Some("234"), "bool": bool, "float": flt, "int": Some(Js.null), "datetime": datetime2, "recursive": {"bool": bool, "datetime": datetime3}}}}
  internal_makeConnectionId(connectionParentDataId, args)
}
module Utils = {
  @@warning("-33")
  open Types

  @live
  let getConnectionNodes: Types.fragment_friendsConnection => array<Types.fragment_friendsConnection_edges_node> = connection => 
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
  "kind": "Variable",
  "name": "bool",
  "variableName": "bool"
};
return {
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
      "name": "datetime"
    },
    {
      "defaultValue": null,
      "kind": "LocalArgument",
      "name": "datetime2"
    },
    {
      "defaultValue": null,
      "kind": "LocalArgument",
      "name": "datetime3"
    },
    {
      "defaultValue": null,
      "kind": "LocalArgument",
      "name": "flt"
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
              "fields": [
                (v0/*: any*/),
                {
                  "kind": "Variable",
                  "name": "datetime",
                  "variableName": "datetime2"
                },
                {
                  "kind": "Variable",
                  "name": "float",
                  "variableName": "flt"
                },
                {
                  "kind": "Literal",
                  "name": "int",
                  "value": null
                },
                {
                  "fields": [
                    (v0/*: any*/),
                    {
                      "kind": "Variable",
                      "name": "datetime",
                      "variableName": "datetime3"
                    }
                  ],
                  "kind": "ObjectValue",
                  "name": "recursive"
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
};
})() `)

