/* @sourceLoc Test_fragment.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@ocaml.warning("-30")

  type rec fragment_Group = {
    @live __typename: [ | #Group],
    name: string,
  }
  and fragment_User = {
    @live __typename: [ | #User],
    firstName: string,
    isOnline: bool,
    lastName: string,
  }
  type fragment_t = [
    | #Group(fragment_Group)
    | #User(fragment_User)
    | #UnselectedUnionMember(string)
  ]

  type fragment = array<option<fragment_t>>
}

@live
let unwrap_fragment: {. "__typename": string } => [
  | #Group(Types.fragment_Group)
  | #User(Types.fragment_User)
  | #UnselectedUnionMember(string)
] = u => switch u["__typename"] {
  | "Group" => #Group(u->Obj.magic)
  | "User" => #User(u->Obj.magic)
  | v => #UnselectedUnionMember(v)
}

@live
let wrap_fragment: [
  | #Group(Types.fragment_Group)
  | #User(Types.fragment_User)
  | #UnselectedUnionMember(string)
] => {. "__typename": string } = v => switch v {
  | #Group(v) => v->Obj.magic
  | #User(v) => v->Obj.magic
  | #UnselectedUnionMember(v) => {"__typename": v}
}
module Internal = {
  @live
  type fragmentRaw
  @live
  let fragmentConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"__root":{"":{"u":"fragment"}}}`
  )
  @live
  let fragmentConverterMap = {
    "fragment": unwrap_fragment,
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
  array<RescriptRelay.fragmentRefs<[> | #TestFragment_requiredUnionPlural_member]>> => fragmentRef = "%identity"

module Utils = {
  @@ocaml.warning("-33")
  open Types
}

type relayOperationNode
type operationType = RescriptRelay.fragmentNode<relayOperationNode>


let node: operationType = %raw(json` {
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": {
    "plural": true
  },
  "name": "TestFragment_requiredUnionPlural_member",
  "selections": [
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "__typename",
      "storageKey": null
    },
    {
      "kind": "InlineFragment",
      "selections": [
        {
          "kind": "RequiredField",
          "field": {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "isOnline",
            "storageKey": null
          },
          "action": "NONE",
          "path": "isOnline"
        },
        {
          "alias": null,
          "args": null,
          "kind": "ScalarField",
          "name": "lastName",
          "storageKey": null
        },
        {
          "alias": null,
          "args": null,
          "kind": "ScalarField",
          "name": "firstName",
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
    }
  ],
  "type": "Member",
  "abstractKey": "__isMember"
} `)

