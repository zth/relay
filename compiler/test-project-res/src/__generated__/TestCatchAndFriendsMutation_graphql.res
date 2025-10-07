/* @sourceLoc Test_catchAndFriends.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live
  type rec response_value_updateUserAvatar_user = {
    @live id: string,
  }
  @live
  and response_value_updateUserAvatar = {
    user: option<response_value_updateUserAvatar_user>,
  }
  @live
  type response_value = {
    updateUserAvatar: option<response_value_updateUserAvatar>,
  }
  type response = RescriptRelay.CatchResult.t<response_value>
  @live
  type rawResponse = response_value
  @live
  type variables = unit
}

module Internal = {
  @live
  let variablesConverter: dict<dict<dict<string>>> = %raw(
    json`{}`
  )
  @live
  let variablesConverterMap = ()
  @live
  let convertVariables = v => v->RescriptRelay.convertObj(
    variablesConverter,
    variablesConverterMap,
    None
  )
  @live
  type wrapResponseRaw
  @live
  let wrapResponseConverter: dict<dict<dict<string>>> = %raw(
    json`{}`
  )
  @live
  let wrapResponseConverterMap = ()
  @live
  let convertWrapResponse = v => v->RescriptRelay.convertObj(
    wrapResponseConverter,
    wrapResponseConverterMap,
    null
  )
  @live
  type responseRaw
  @live
  let responseConverter: dict<dict<dict<string>>> = %raw(
    json`{}`
  )
  @live
  let responseConverterMap = ()
  @live
  let convertResponse = v => v->RescriptRelay.convertObj(
    responseConverter,
    responseConverterMap,
    None
  )
  type wrapRawResponseRaw = wrapResponseRaw
  @live
  let convertWrapRawResponse = convertWrapResponse
  type rawResponseRaw = responseRaw
  @live
  let convertRawResponse = convertResponse
}
module Utils = {
  @@warning("-33")
  open Types
}

type relayOperationNode
type operationType = RescriptRelay.mutationNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = [
  {
    "alias": null,
    "args": [
      {
        "kind": "Literal",
        "name": "avatarUrl",
        "value": "https://avatars.com/avatar/user"
      }
    ],
    "concreteType": "UpdateUserAvatarPayload",
    "kind": "LinkedField",
    "name": "updateUserAvatar",
    "plural": false,
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "user",
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
    ],
    "storageKey": "updateUserAvatar(avatarUrl:\"https://avatars.com/avatar/user\")"
  }
];
return {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": {
      "catchTo": "RESULT"
    },
    "name": "TestCatchAndFriendsMutation",
    "selections": (v0/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "TestCatchAndFriendsMutation",
    "selections": (v0/*: any*/)
  },
  "params": {
    "cacheID": "65a04919576c8cf004f73142d2e7e232",
    "id": null,
    "metadata": {},
    "name": "TestCatchAndFriendsMutation",
    "operationKind": "mutation",
    "text": "mutation TestCatchAndFriendsMutation {\n  updateUserAvatar(avatarUrl: \"https://avatars.com/avatar/user\") {\n    user {\n      id\n    }\n  }\n}\n"
  }
};
})() `)


