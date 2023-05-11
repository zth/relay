(* @sourceLoc Test_refetching.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type response = {
    fragmentRefs: [ | `TestRefetchingNoArgs_query] RescriptRelay.fragmentRefs;
  }
  type rawResponse = response
  type variables = unit
  type refetchVariables = unit
  let makeRefetchVariables () = ()
end

module Internal = struct
  let variablesConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{}|json}
  ]
  let variablesConverterMap = ()
  let convertVariables v = RescriptRelay.convertObj v 
    variablesConverter 
    variablesConverterMap 
    Js.undefined
    type wrapResponseRaw
  let wrapResponseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"__root":{"":{"f":""}}}|json}
  ]
  let wrapResponseConverterMap = ()
  let convertWrapResponse v = RescriptRelay.convertObj v 
    wrapResponseConverter 
    wrapResponseConverterMap 
    Js.null
    type responseRaw
  let responseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"__root":{"":{"f":""}}}|json}
  ]
  let responseConverterMap = ()
  let convertResponse v = RescriptRelay.convertObj v 
    responseConverter 
    responseConverterMap 
    Js.undefined
    type wrapRawResponseRaw = wrapResponseRaw
  let convertWrapRawResponse = convertWrapResponse
  type rawResponseRaw = responseRaw
  let convertRawResponse = convertResponse
end

type queryRef

module Utils = struct
  [@@@ocaml.warning "-33"]
  open Types
  external makeVariables: unit -> unit = ""
end

type relayOperationNode
type operationType = relayOperationNode RescriptRelay.queryNode


let node: operationType = [%bs.raw {json| {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestRefetchingNoArgsRefetchQuery",
    "selections": [
      {
        "args": null,
        "kind": "FragmentSpread",
        "name": "TestRefetchingNoArgs_query"
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "TestRefetchingNoArgsRefetchQuery",
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
    ]
  },
  "params": {
    "cacheID": "0a2bcc83daa255e2dd47697493a008fe",
    "id": null,
    "metadata": {},
    "name": "TestRefetchingNoArgsRefetchQuery",
    "operationKind": "query",
    "text": "query TestRefetchingNoArgsRefetchQuery {\n  ...TestRefetchingNoArgs_query\n}\n\nfragment TestRefetchingNoArgs_query on Query {\n  loggedInUser {\n    id\n  }\n}\n"
  }
} |json}]

include RescriptRelay.MakeLoadQuery(struct
            type variables = Types.variables
            type loadedQueryRef = queryRef
            type response = Types.response
            type node = relayOperationNode
            let query = node
            let convertVariables = Internal.convertVariables
        end)
