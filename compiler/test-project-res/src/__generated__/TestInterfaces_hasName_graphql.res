/* @sourceLoc Test_interfaces.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @tag("__typename") type fragment_byType = 
    | @live Group(
      {
        avatarUrl: option<string>,
      }
    )
    | @live Organization(
      {
        slug: string,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  type fragment = {
    @live __typename: string,
    byType: fragment_byType,
    name: string,
  }
}

@live
let unwrap_fragment_byType: Types.fragment_byType => Types.fragment_byType = RescriptRelay_Internal.unwrapUnion(_, ["Group", "Organization"])
@live
let wrap_fragment_byType: Types.fragment_byType => Types.fragment_byType = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  type fragmentRaw
  @live
  let fragmentConverter: dict<dict<dict<string>>> = %raw(
    json`{"__root":{"byType":{"u":"fragment_byType"}}}`
  )
  @live
  let fragmentConverterMap = {
    "fragment_byType": unwrap_fragment_byType,
  }
  @live
  let convertFragment = v => v->RescriptRelay.convertObj(
    fragmentConverter,
    fragmentConverterMap,
    None
  )
}

type t
type fragmentRef
external getFragmentRef:
  RescriptRelay.fragmentRefs<[> | #TestInterfaces_hasName]> => fragmentRef = "%identity"

module Utils = {
  @@warning("-33")
  open Types
}

type relayOperationNode
type operationType = RescriptRelay.fragmentNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
  "storageKey": null
};
return {
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": null,
  "name": "TestInterfaces_hasName",
  "selections": [
    (v0/*: any*/),
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "name",
      "storageKey": null
    },
    {
      "fragment": {
        "kind": "InlineFragment",
        "selections": [
          (v0/*: any*/),
          {
            "kind": "InlineFragment",
            "selections": [
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "avatarUrl",
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
                "name": "slug",
                "storageKey": null
              }
            ],
            "type": "Organization",
            "abstractKey": null
          }
        ],
        "type": null,
        "abstractKey": null
      },
      "kind": "AliasedInlineFragmentSpread",
      "name": "byType"
    }
  ],
  "type": "HasName",
  "abstractKey": "__isHasName"
};
})() `)

