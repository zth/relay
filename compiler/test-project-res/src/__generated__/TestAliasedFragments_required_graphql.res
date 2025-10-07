/* @sourceLoc Test_aliasedFragments.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type rec fragment_requiredFields = {
    avatarUrl: string,
    isOnline: bool,
  }
  type fragment = {
    firstName: string,
    requiredFields: option<fragment_requiredFields>,
  }
}

module Internal = {
  @live
  type fragmentRaw
  @live
  let fragmentConverter: dict<dict<dict<string>>> = %raw(
    json`{}`
  )
  @live
  let fragmentConverterMap = ()
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
  RescriptRelay.fragmentRefs<[> | #TestAliasedFragments_required]> => fragmentRef = "%identity"

module Utils = {
  @@warning("-33")
  open Types
}

type relayOperationNode
type operationType = RescriptRelay.fragmentNode<relayOperationNode>


let node: operationType = %raw(json` {
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": null,
  "name": "TestAliasedFragments_required",
  "selections": [
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "firstName",
      "storageKey": null
    },
    {
      "fragment": {
        "kind": "InlineFragment",
        "selections": [
          {
            "kind": "RequiredField",
            "field": {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "avatarUrl",
              "storageKey": null
            },
            "action": "NONE"
          },
          {
            "kind": "RequiredField",
            "field": {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "isOnline",
              "storageKey": null
            },
            "action": "NONE"
          }
        ],
        "type": null,
        "abstractKey": null
      },
      "kind": "AliasedInlineFragmentSpread",
      "name": "requiredFields"
    }
  ],
  "type": "User",
  "abstractKey": null
} `)

