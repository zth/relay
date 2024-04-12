/* @sourceLoc Test_updatableFragments.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @tag("__typename") type fragment_memberOfSingular = 
    | @live Group(
      {
        @live __typename: [ | #Group],
        mutable name: string,
      }
    )
  type rec fragment_bestFriend = {
    mutable firstName: string,
  }
  type fragment = {
    /** This is the raw, not parsed value of the custom scalar `SomeModule.Datetime.t`. In updatable fragments you need to convert to and from the custom scalar manually as you read and make updates to it. */
    mutable createdAt: Js.Json.t,
    mutable isOnline: Js.Nullable.t<bool>,
    mutable onlineStatus: Js.Nullable.t<RelaySchemaAssets_graphql.enum_OnlineStatus>,
    bestFriend: Js.Nullable.t<fragment_bestFriend>,
    memberOfSingular: Js.Nullable.t<fragment_memberOfSingular>,
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
    },
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "onlineStatus",
      "storageKey": null
    },
    {
      "alias": null,
      "args": null,
      "concreteType": null,
      "kind": "LinkedField",
      "name": "memberOfSingular",
      "plural": false,
      "selections": [
        (v0/*: any*/),
        {
          "kind": "InlineFragment",
          "selections": [
            (v0/*: any*/),
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
      "storageKey": null
    },
    {
      "alias": null,
      "args": null,
      "concreteType": "User",
      "kind": "LinkedField",
      "name": "bestFriend",
      "plural": false,
      "selections": [
        {
          "alias": null,
          "args": null,
          "kind": "ScalarField",
          "name": "firstName",
          "storageKey": null
        }
      ],
      "storageKey": null
    }
  ],
  "type": "User",
  "abstractKey": null
};
})() `)


let readUpdatableFragment = (store, fragmentRefs) => store->readUpdatableFragment(~node, ~fragmentRefs)

