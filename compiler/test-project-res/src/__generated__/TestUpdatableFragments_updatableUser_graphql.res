/* @sourceLoc Test_updatableFragments.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type fragment = {
    /** This is the raw, not parsed value of the custom scalar `SomeModule.Datetime.t`. In updatable fragments you need to convert to and from the custom scalar manually as you read and make updates to it. */
    mutable createdAt: Js.Json.t,
    mutable isOnline: Js.Nullable.t<bool>,
  }
}

module Internal = {
}


type relayOperationNode

type updatableData = {updatableData: Types.fragment}

@send external readUpdatableFragment: (RescriptRelay.RecordSourceSelectorProxy.t, ~node: RescriptRelay.fragmentNode<relayOperationNode>, ~fragmentRefs: RescriptRelay.updatableFragmentRefs<[> | #TestUpdatableFragments_updatableUser]>) => updatableData = "readUpdatableFragment"
module Utils = {
  @@warning("-33")
  open Types
}

type operationType = RescriptRelay.fragmentNode<relayOperationNode>


let node: operationType = %raw(json` {
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": null,
  "name": "TestUpdatableFragments_updatableUser",
  "selections": [
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "isOnline",
      "storageKey": null
    },
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


let readUpdatableFragment = (store, fragmentRefs) => store->readUpdatableFragment(~node, ~fragmentRefs)

