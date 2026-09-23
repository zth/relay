/* @sourceLoc Test_fragment.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @tag("__typename") type fragment_t = 
    | @live Group(
      {
        name: string,
      }
    )
    | @live User(
      {
        firstName: string,
        isOnline: bool,
        lastName: string,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  type fragment = option<fragment_t>
}

@live
let unwrap_fragment: Types.fragment => Types.fragment = RescriptRelay_Internal.unwrapUnion(_, ["Group", "User"])
@live
let wrap_fragment: Types.fragment => Types.fragment = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  type fragmentRaw
  %%private(
  @live
  let fragmentConverter: JSON.t = %raw(json`{"roots":{"__root":[{"path":[],"union":"0"}]},"version":2}`)
  @live
  let fragmentCallbacks = {
    "0": unwrap_fragment,
  }
  @live
  let preparedFragmentConverter = RescriptRelay.prepareConversion(
    fragmentConverter,
    fragmentCallbacks,
    None
  )
  )
  @live
  let convertFragment = value => RescriptRelay.runConversion(preparedFragmentConverter, value)
}

type t
type fragmentRef
external getFragmentRef:
  RescriptRelay.fragmentRefs<[> | #TestFragment_requiredUnion_member]> => fragmentRef = "%identity"

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
  "name": "TestFragment_requiredUnion_member",
  "selections": [
    (v0/*: any*/),
    {
      "kind": "InlineFragment",
      "selections": [
        (v0/*: any*/),
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
};
})() `)

