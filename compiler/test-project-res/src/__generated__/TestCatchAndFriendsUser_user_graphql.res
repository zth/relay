/* @sourceLoc Test_catchAndFriends.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type fragment_t = {
    createdAt: SomeModule.Datetime.t,
  }
  type fragment = RescriptRelay.CatchResult.t<fragment_t>
}

module Internal = {
  @live
  type fragmentRaw
  @live
  let fragmentConverter: dict<dict<dict<string>>> = %raw(
    json`{"__root":{"value_createdAt":{"c":"SomeModule.Datetime"}}}`
  )
  @live
  let fragmentConverterMap = {
    "SomeModule.Datetime": SomeModule.Datetime.parse,
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
  RescriptRelay.fragmentRefs<[> | #TestCatchAndFriendsUser_user]> => fragmentRef = "%identity"

module Utils = {
  @@warning("-33")
  open Types
}

type relayOperationNode
type operationType = RescriptRelay.fragmentNode<relayOperationNode>


let node: operationType = %raw(json` {
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": {
    "catchTo": "RESULT"
  },
  "name": "TestCatchAndFriendsUser_user",
  "selections": [
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "createdAt",
      "storageKey": null
    }
  ],
  "type": "User",
  "abstractKey": null
} `)

