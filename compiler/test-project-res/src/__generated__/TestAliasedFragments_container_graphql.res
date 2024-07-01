/* @sourceLoc Test_aliasedFragments.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type rec fragment_TestAliasedFragments_one = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #TestAliasedFragments_one]>,
  }
  and fragment_TestAliasedFragments_two = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #TestAliasedFragments_two]>,
  }
  type fragment = {
    @as("TestAliasedFragments_one") testAliasedFragments_one: fragment_TestAliasedFragments_one,
    @as("TestAliasedFragments_two") testAliasedFragments_two: fragment_TestAliasedFragments_two,
    firstName: string,
  }
}

module Internal = {
  @live
  type fragmentRaw
  @live
  let fragmentConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"__root":{"TestAliasedFragments_two":{"f":""},"TestAliasedFragments_one":{"f":""}}}`
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
  RescriptRelay.fragmentRefs<[> | #TestAliasedFragments_container]> => fragmentRef = "%identity"

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
  "name": "TestAliasedFragments_container",
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
        "args": null,
        "kind": "FragmentSpread",
        "name": "TestAliasedFragments_one"
      },
      "kind": "AliasedFragmentSpread",
      "name": "TestAliasedFragments_one",
      "type": "User",
      "abstractKey": null
    },
    {
      "fragment": {
        "args": null,
        "kind": "FragmentSpread",
        "name": "TestAliasedFragments_two"
      },
      "kind": "AliasedFragmentSpread",
      "name": "TestAliasedFragments_two",
      "type": "User",
      "abstractKey": null
    }
  ],
  "type": "User",
  "abstractKey": null
} `)

