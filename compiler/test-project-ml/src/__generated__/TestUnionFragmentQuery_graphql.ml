(* @sourceLoc Test_unionFragment.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type response_member = {
    __typename: string [@live];
    fragmentRefs: [ | `TestUnionFragment_member | `TestUnionFragment_plural_member] Melange_relay.fragmentRefs;
  }
  type response = {
    member: response_member option;
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
  let convertVariables v = Melange_relay.convertObj v 
    variablesConverter 
    variablesConverterMap 
    Js.undefined
    type wrapResponseRaw
  let wrapResponseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"__root":{"member":{"f":""}}}|json}
  ]
  let wrapResponseConverterMap = ()
  let convertWrapResponse v = Melange_relay.convertObj v 
    wrapResponseConverter 
    wrapResponseConverterMap 
    Js.null
    type responseRaw
  let responseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"__root":{"member":{"f":""}}}|json}
  ]
  let responseConverterMap = ()
  let convertResponse v = Melange_relay.convertObj v 
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
  external makeVariables: unit -> unit = "" [@@bs.obj]
end

type relayOperationNode
type operationType = relayOperationNode Melange_relay.queryNode


let node: operationType = [%bs.raw {json| (function(){
var v0 = [
  {
    "kind": "Literal",
    "name": "id",
    "value": "123"
  }
],
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
  "storageKey": null
};
return {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestUnionFragmentQuery",
    "selections": [
      {
        "alias": null,
        "args": (v0/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "member",
        "plural": false,
        "selections": [
          (v1/*: any*/),
          {
            "args": null,
            "kind": "FragmentSpread",
            "name": "TestUnionFragment_member"
          },
          {
            "args": null,
            "kind": "FragmentSpread",
            "name": "TestUnionFragment_plural_member"
          }
        ],
        "storageKey": "member(id:\"123\")"
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "TestUnionFragmentQuery",
    "selections": [
      {
        "alias": null,
        "args": (v0/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "member",
        "plural": false,
        "selections": [
          (v1/*: any*/),
          {
            "kind": "TypeDiscriminator",
            "abstractKey": "__isMember"
          },
          {
            "kind": "InlineFragment",
            "selections": [
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "firstName",
                "storageKey": null
              },
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "onlineStatus",
                "storageKey": null
              }
            ],
            "type": "User",
            "abstractKey": null
          },
          {
            "kind": "InlineFragment",
            "selections": [
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "name",
                "storageKey": null
              }
            ],
            "type": "Group",
            "abstractKey": null
          },
          {
            "kind": "InlineFragment",
            "selections": [
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "id",
                "storageKey": null
              }
            ],
            "type": "Node",
            "abstractKey": "__isNode"
          }
        ],
        "storageKey": "member(id:\"123\")"
      }
    ]
  },
  "params": {
    "cacheID": "21ff5bfa26571b6c0dd392207d7bf454",
    "id": null,
    "metadata": {},
    "name": "TestUnionFragmentQuery",
    "operationKind": "query",
    "text": "query TestUnionFragmentQuery {\n  member(id: \"123\") {\n    __typename\n    ...TestUnionFragment_member\n    ...TestUnionFragment_plural_member\n    ... on Node {\n      __isNode: __typename\n      __typename\n      id\n    }\n  }\n}\n\nfragment TestUnionFragmentUser_user on User {\n  firstName\n  onlineStatus\n}\n\nfragment TestUnionFragment_member on Member {\n  __isMember: __typename\n  __typename\n  ... on User {\n    firstName\n    onlineStatus\n    ...TestUnionFragmentUser_user\n  }\n  ... on Group {\n    name\n  }\n}\n\nfragment TestUnionFragment_plural_member on Member {\n  __isMember: __typename\n  __typename\n  ... on User {\n    firstName\n    onlineStatus\n    ...TestUnionFragmentUser_user\n  }\n  ... on Group {\n    name\n  }\n}\n"
  }
};
})() |json}]

include Melange_relay.MakeLoadQuery(struct
            type variables = Types.variables
            type loadedQueryRef = queryRef
            type response = Types.response
            type node = relayOperationNode
            let query = node
            let convertVariables = Internal.convertVariables
        end)
