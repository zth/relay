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
  [> | `TestConnectionsWithConstantValues_user] RescriptRelay.fragmentRefs -> fragmentRef = "%identity"

let connectionKey = "TestConnectionsWithonstantValues_user_friendsConnection"

[@@bs.inline]
[%%private
  external internal_makeConnectionId: RescriptRelay.dataId -> (_ [@bs.as "TestConnectionsWithonstantValues_user_friendsConnection"]) -> 'arguments -> RescriptRelay.dataId = "getConnectionID"
[@@live] [@@bs.module "relay-runtime"] [@@bs.scope "ConnectionHandler"]

]let makeConnectionId (connectionParentDataId: RescriptRelay.dataId) ~(onlineStatus: [`Online | `Idle | `Offline]) ~(beforeDate: SomeModule.Datetime.t) ?(datetime: SomeModule.Datetime.t Js.null=Js.null) ?(bool: bool option) ?(flt: float Js.null=Js.null) ?(datetime2: SomeModule.Datetime.t option) ~(datetime3: SomeModule.Datetime.t) () =
  let onlineStatus = Some onlineStatus in
  let beforeDate = Some (SomeModule.Datetime.serialize beforeDate) in
  let datetime = datetime |. Js.Null.toOption in
  let datetime = match datetime with | None -> None | Some v -> Some (SomeModule.Datetime.serialize v) in
  let flt = flt |. Js.Null.toOption in
  let datetime2 = match datetime2 with | None -> None | Some v -> Some (SomeModule.Datetime.serialize v) in
  let datetime3 = Some (SomeModule.Datetime.serialize datetime3) in
  let args = [%bs.obj {statuses= [RescriptRelay_Internal.Arg(Some(`Idle)); RescriptRelay_Internal.Arg(onlineStatus)]; beforeDate= beforeDate; objTest= [%bs.obj {"str" = Some("123"); "bool" = Some(false); "float" = Some(12.2); "int" = Some(64); "datetime" = datetime; "recursive" = [%bs.obj {"str" = Some("234"); "bool" = bool; "float" = flt; "int" = Some(Js.null); "datetime" = datetime2; "recursive" = [%bs.obj {"bool" = bool; "datetime" = datetime3}]}]}]}] in
  internal_makeConnectionId(connectionParentDataId, args)
module Utils = struct
  [@@@ocaml.warning "-33"]
  open Types

  let getConnectionNodes: Types.fragment_friendsConnection -> Types.fragment_friendsConnection_edges_node array = fun connection -> 
    begin match connection.edges with
      | None -> []
      | Some edges -> edges
        |. Belt.Array.keepMap(function 
          | None -> None
          | Some edge -> edge.node
        )
    end


end

type relayOperationNode
type operationType = relayOperationNode RescriptRelay.fragmentNode


let node: operationType = [%bs.raw {json| (function(){
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
})() |json}]

