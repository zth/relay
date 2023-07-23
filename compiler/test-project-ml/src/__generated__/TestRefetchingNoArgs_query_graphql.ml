(* @sourceLoc Test_refetching.ml *)
(* @generated *)
[%%mel.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type fragment_loggedInUser = {
    id: string [@live];
  }
  type fragment = {
    loggedInUser: fragment_loggedInUser;
  }
end

module Internal = struct
  type fragmentRaw
  let fragmentConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
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
  [> | `TestRefetchingNoArgs_query] Melange_relay.fragmentRefs -> fragmentRef = "%identity"

module Utils = struct
  [@@@ocaml.warning "-33"]
  open Types
end

type relayOperationNode
type operationType = relayOperationNode Melange_relay.fragmentNode


[%%private let makeNode rescript_graphql_node_TestRefetchingNoArgsRefetchQuery: operationType = 
  ignore rescript_graphql_node_TestRefetchingNoArgsRefetchQuery;
  [%raw {json|{
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": {
    "refetch": {
      "connection": null,
      "fragmentPathInResult": [],
      "operation": rescript_graphql_node_TestRefetchingNoArgsRefetchQuery
    }
  },
  "name": "TestRefetchingNoArgs_query",
  "selections": [
    {
      "alias": null,
      "args": null,
      "concreteType": "User",
      "kind": "LinkedField",
      "name": "loggedInUser",
      "plural": false,
      "selections": [
        {
          "alias": null,
          "args": null,
          "kind": "ScalarField",
          "name": "id",
          "storageKey": null
        }
      ],
      "storageKey": null
    }
  ],
  "type": "Query",
  "abstractKey": null
}|json}]
]
let node: operationType = makeNode TestRefetchingNoArgsRefetchQuery_graphql.node

