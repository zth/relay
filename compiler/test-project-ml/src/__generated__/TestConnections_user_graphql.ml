(* @sourceLoc Test_connections.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type fragment_friendsConnection_edges_node = {
    id: string [@live];
  }
  and fragment_friendsConnection_edges = {
    node: fragment_friendsConnection_edges_node option;
  }
  and fragment_friendsConnection = {
    edges: fragment_friendsConnection_edges option array option;
  }
  type fragment = {
    friendsConnection: fragment_friendsConnection;
  }
end

module Internal = struct
  type fragmentRaw
  let fragmentConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{}|json}
  ]
  let fragmentConverterMap = ()
  let convertFragment v = RescriptRelay.convertObj v 
    fragmentConverter 
    fragmentConverterMap 
    Js.undefined
  end

type t
type fragmentRef
external getFragmentRef:
  [> | `TestConnections_user] RescriptRelay.fragmentRefs -> fragmentRef = "%identity"

let connectionKey = "TestConnections_user_friendsConnection"

[@@bs.inline]
[%%private
  external internal_makeConnectionId: RescriptRelay.dataId -> (_ [@bs.as "TestConnections_user_friendsConnection"]) -> 'arguments -> RescriptRelay.dataId = "getConnectionID"
[@@live] [@@bs.module "relay-runtime"] [@@bs.scope "ConnectionHandler"]

]let makeConnectionId (connectionParentDataId: RescriptRelay.dataId) ?(onlineStatuses: [`Online | `Idle | `Offline] array=[| `Idle |]) ~(beforeDate: SomeModule.Datetime.t) () =
  let onlineStatuses = Some onlineStatuses in
  let beforeDate = Some (SomeModule.Datetime.serialize beforeDate) in
  let args = [%bs.obj {statuses= onlineStatuses; beforeDate= beforeDate}] in
  internal_makeConnectionId connectionParentDataId args
module Utils = struct
  [@@@ocaml.warning "-33"]
  open Types

  let getConnectionNodes: Types.fragment_friendsConnection -> Types.fragment_friendsConnection_edges_node array = fun connection -> 
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
type operationType = relayOperationNode RescriptRelay.fragmentNode


let node: operationType = [%bs.raw {json| {
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
  "name": "TestConnections_user",
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
} |json}]

