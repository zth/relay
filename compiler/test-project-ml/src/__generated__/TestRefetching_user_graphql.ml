(* @sourceLoc Test_refetching.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type fragment_friendsConnection = {
    totalCount: int;
  }
  type fragment = {
    firstName: string;
    friendsConnection: fragment_friendsConnection;
    id: string [@live];
    onlineStatus: RelaySchemaAssets_graphql.enum_OnlineStatus option;
  }
end

module Internal = struct
  type fragmentRaw
  let fragmentConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{}|json}
  ]
  let fragmentConverterMap = ()
  let convertFragment v = Melange_relay.convertObj v 
    fragmentConverter 
    fragmentConverterMap 
    Js.undefined
  end

type t
type fragmentRef
external getFragmentRef:
  [> | `TestRefetching_user] Melange_relay.fragmentRefs -> fragmentRef = "%identity"

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
  end

type relayOperationNode
type operationType = relayOperationNode Melange_relay.fragmentNode


[%%private let makeNode rescript_graphql_node_TestRefetchingRefetchQuery: operationType = 
  ignore rescript_graphql_node_TestRefetchingRefetchQuery;
  [%raw {json|{
  "argumentDefinitions": [
    {
      "defaultValue": null,
      "kind": "LocalArgument",
      "name": "friendsOnlineStatuses"
    },
    {
      "defaultValue": false,
      "kind": "LocalArgument",
      "name": "showOnlineStatus"
    }
  ],
  "kind": "Fragment",
  "metadata": {
    "refetch": {
      "connection": null,
      "fragmentPathInResult": [
        "node"
      ],
      "operation": rescript_graphql_node_TestRefetchingRefetchQuery,
      "identifierField": "id"
    }
  },
  "name": "TestRefetching_user",
  "selections": [
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "firstName",
      "storageKey": null
    },
    {
      "condition": "showOnlineStatus",
      "kind": "Condition",
      "passingValue": true,
      "selections": [
        {
          "alias": null,
          "args": null,
          "kind": "ScalarField",
          "name": "onlineStatus",
          "storageKey": null
        }
      ]
    },
    {
      "alias": null,
      "args": [
        {
          "kind": "Variable",
          "name": "statuses",
          "variableName": "friendsOnlineStatuses"
        }
      ],
      "concreteType": "UserConnection",
      "kind": "LinkedField",
      "name": "friendsConnection",
      "plural": false,
      "selections": [
        {
          "alias": null,
          "args": null,
          "kind": "ScalarField",
          "name": "totalCount",
          "storageKey": null
        }
      ],
      "storageKey": null
    },
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "id",
      "storageKey": null
    }
  ],
  "type": "User",
  "abstractKey": null
}|json}]
]
let node: operationType = makeNode TestRefetchingRefetchQuery_graphql.node

