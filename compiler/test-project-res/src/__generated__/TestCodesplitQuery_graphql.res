/* @sourceLoc Test_codesplit.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type rec response_member_GroupAvatar_group = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #GroupAvatar_group]>,
  }
  and response_member_UserAvatar_user = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #UserAvatar_user]>,
  }
  and response_member_UserNode_node = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #UserNode_node]>,
  }
  and response_member_bestFriend_FriendComponent2_user = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #FriendComponent2_user]>,
  }
  and response_member_bestFriend_FriendComponent_user = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #FriendComponent_user]>,
  }
  and response_member_bestFriend = {
    @as("FriendComponent2_user") friendComponent2_user: response_member_bestFriend_FriendComponent2_user,
    @as("FriendComponent_user") friendComponent_user: option<response_member_bestFriend_FriendComponent_user>,
  }
  and response_member_description_RichContent_content = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #RichContent_content]>,
  }
  and response_member_description = {
    @as("RichContent_content") richContent_content: response_member_description_RichContent_content,
  }
  and response_member = {
    @live __typename: string,
    @as("GroupAvatar_group") groupAvatar_group: option<response_member_GroupAvatar_group>,
    @as("UserAvatar_user") userAvatar_user: option<response_member_UserAvatar_user>,
    @as("UserNode_node") userNode_node: option<response_member_UserNode_node>,
    bestFriend: option<response_member_bestFriend>,
    description: option<response_member_description>,
  }
  type response = {
    member: option<response_member>,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    includeFriendAvatar: bool,
  }
  @live
  type refetchVariables = {
    includeFriendAvatar: option<bool>,
  }
  @live let makeRefetchVariables = (
    ~includeFriendAvatar=?,
  ): refetchVariables => {
    includeFriendAvatar: includeFriendAvatar
  }

}


type queryRef

module Internal = {
  @live
  let variablesConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{}`
  )
  @live
  let variablesConverterMap = ()
  @live
  let convertVariables = v => v->RescriptRelay.convertObj(
    variablesConverter,
    variablesConverterMap,
    Js.undefined
  )
  @live
  type wrapResponseRaw
  @live
  let wrapResponseConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"__root":{"member_description_RichContent_content":{"f":""},"member_bestFriend_FriendComponent_user":{"f":""},"member_bestFriend_FriendComponent2_user":{"f":""},"member_UserNode_node":{"f":""},"member_UserAvatar_user":{"f":""},"member_GroupAvatar_group":{"f":""}}}`
  )
  @live
  let wrapResponseConverterMap = ()
  @live
  let convertWrapResponse = v => v->RescriptRelay.convertObj(
    wrapResponseConverter,
    wrapResponseConverterMap,
    Js.null
  )
  @live
  type responseRaw
  @live
  let responseConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"__root":{"member_description_RichContent_content":{"f":""},"member_bestFriend_FriendComponent_user":{"f":""},"member_bestFriend_FriendComponent2_user":{"f":""},"member_UserNode_node":{"f":""},"member_UserAvatar_user":{"f":""},"member_GroupAvatar_group":{"f":""}}}`
  )
  @live
  let responseConverterMap = ()
  @live
  let convertResponse = v => v->RescriptRelay.convertObj(
    responseConverter,
    responseConverterMap,
    Js.undefined
  )
  type wrapRawResponseRaw = wrapResponseRaw
  @live
  let convertWrapRawResponse = convertWrapResponse
  type rawResponseRaw = responseRaw
  @live
  let convertRawResponse = convertResponse
  type rawPreloadToken<'response> = {source: Js.Nullable.t<RescriptRelay.Observable.t<'response>>}
  external tokenToRaw: queryRef => rawPreloadToken<Types.response> = "%identity"
}
module Utils = {
  @@warning("-33")
  open Types
}

module CodesplitComponents = {
  module UserAvatar = {
    let make = React.lazy_(() => Js.import(UserAvatar.make))
  }
  module RichContent = {
    let make = React.lazy_(() => Js.import(RichContent.make))
  }
  module FriendComponent = {
    let make = React.lazy_(() => Js.import(FriendComponent.make))
  }
  module FriendComponent2 = {
    let make = React.lazy_(() => Js.import(FriendComponent2.make))
  }
  module GroupAvatar = {
    let make = React.lazy_(() => Js.import(GroupAvatar.make))
  }
  module UserNode = {
    let make = React.lazy_(() => Js.import(UserNode.make))
  }
}


type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "includeFriendAvatar"
  }
],
v1 = [
  {
    "kind": "Literal",
    "name": "id",
    "value": "123"
  }
],
v2 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
  "storageKey": null
},
v3 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "firstName",
  "storageKey": null
},
v4 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "lastName",
  "storageKey": null
},
v5 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v6 = [
  (v5/*: any*/)
],
v7 = {
  "kind": "InlineFragment",
  "selections": (v6/*: any*/),
  "type": "Node",
  "abstractKey": "__isNode"
};
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": null,
    "name": "TestCodesplitQuery",
    "selections": [
      {
        "alias": null,
        "args": (v1/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "member",
        "plural": false,
        "selections": [
          (v2/*: any*/),
          {
            "kind": "InlineFragment",
            "selections": [
              {
                "fragment": {
                  "args": null,
                  "kind": "FragmentSpread",
                  "name": "UserAvatar_user"
                },
                "kind": "AliasedFragmentSpread",
                "name": "UserAvatar_user",
                "type": "User",
                "abstractKey": null
              },
              {
                "alias": null,
                "args": null,
                "concreteType": "RichContent",
                "kind": "LinkedField",
                "name": "description",
                "plural": false,
                "selections": [
                  {
                    "fragment": {
                      "args": null,
                      "kind": "FragmentSpread",
                      "name": "RichContent_content"
                    },
                    "kind": "AliasedFragmentSpread",
                    "name": "RichContent_content",
                    "type": "RichContent",
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
                    "condition": "includeFriendAvatar",
                    "kind": "Condition",
                    "passingValue": true,
                    "selections": [
                      {
                        "fragment": {
                          "args": null,
                          "kind": "FragmentSpread",
                          "name": "FriendComponent_user"
                        },
                        "kind": "AliasedFragmentSpread",
                        "name": "FriendComponent_user",
                        "type": "User",
                        "abstractKey": null
                      }
                    ]
                  },
                  {
                    "fragment": {
                      "args": null,
                      "kind": "FragmentSpread",
                      "name": "FriendComponent2_user"
                    },
                    "kind": "AliasedFragmentSpread",
                    "name": "FriendComponent2_user",
                    "type": "User",
                    "abstractKey": null
                  }
                ],
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
                "fragment": {
                  "args": null,
                  "kind": "FragmentSpread",
                  "name": "GroupAvatar_group"
                },
                "kind": "AliasedFragmentSpread",
                "name": "GroupAvatar_group",
                "type": "Group",
                "abstractKey": null
              }
            ],
            "type": "Group",
            "abstractKey": null
          },
          {
            "fragment": {
              "args": null,
              "kind": "FragmentSpread",
              "name": "UserNode_node"
            },
            "kind": "AliasedFragmentSpread",
            "name": "UserNode_node",
            "type": "Node",
            "abstractKey": "__isNode"
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
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "TestCodesplitQuery",
    "selections": [
      {
        "alias": null,
        "args": (v1/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "member",
        "plural": false,
        "selections": [
          (v2/*: any*/),
          {
            "kind": "InlineFragment",
            "selections": [
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "avatarUrl",
                "storageKey": null
              },
              (v3/*: any*/),
              (v4/*: any*/),
              {
                "alias": null,
                "args": null,
                "concreteType": "RichContent",
                "kind": "LinkedField",
                "name": "description",
                "plural": false,
                "selections": [
                  {
                    "alias": null,
                    "args": null,
                    "kind": "ScalarField",
                    "name": "content",
                    "storageKey": null
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
                    "condition": "includeFriendAvatar",
                    "kind": "Condition",
                    "passingValue": true,
                    "selections": [
                      (v3/*: any*/)
                    ]
                  },
                  (v4/*: any*/),
                  (v5/*: any*/)
                ],
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
          (v7/*: any*/),
          (v7/*: any*/),
          {
            "kind": "InlineFragment",
            "selections": (v6/*: any*/),
            "type": "person",
            "abstractKey": null
          }
        ],
        "storageKey": "member(id:\"123\")"
      }
    ]
  },
  "params": {
    "cacheID": "1f5b59585a0a99fa9838f79de1c7257e",
    "id": null,
    "metadata": {},
    "name": "TestCodesplitQuery",
    "operationKind": "query",
    "text": "query TestCodesplitQuery(\n  $includeFriendAvatar: Boolean!\n) {\n  member(id: \"123\") {\n    __typename\n    ... on User {\n      ...UserAvatar_user\n      description {\n        ...RichContent_content\n      }\n      bestFriend {\n        ...FriendComponent_user @include(if: $includeFriendAvatar)\n        ...FriendComponent2_user\n        id\n      }\n    }\n    ... on Group {\n      ...GroupAvatar_group\n    }\n    ...UserNode_node\n    ... on Node {\n      __isNode: __typename\n      __typename\n      id\n    }\n    ... on person {\n      id\n    }\n  }\n}\n\nfragment FriendComponent2_user on User {\n  lastName\n}\n\nfragment FriendComponent_user on User {\n  firstName\n}\n\nfragment GroupAvatar_group on Group {\n  name\n}\n\nfragment RichContent_content on RichContent {\n  content\n}\n\nfragment UserAvatar_user on User {\n  avatarUrl\n  ...UserName_user\n}\n\nfragment UserName_user on User {\n  firstName\n  lastName\n}\n\nfragment UserNode_node on Node {\n  __isNode: __typename\n  __typename\n  id\n}\n"
  }
};
})() `)

let node = RescriptRelay_Internal.applyCodesplitMetadata(node, [
  ("member.$$u$$User", (_variables: dict<Js.Json.t>) => {Js.import(UserAvatar.make)->ignore; Js.import(UserName.make)->ignore}), 
  ("member.$$u$$User.description", (_variables: dict<Js.Json.t>) => {Js.import(RichContent.make)->ignore}), 
  ("member.$$u$$User.bestFriend", (variables: dict<Js.Json.t>) => {if variables->Js.Dict.get("includeFriendAvatar") === Some(Js.Json.Boolean(true)) {Js.import(FriendComponent.make)->ignore}; Js.import(FriendComponent2.make)->ignore}), 
  ("member.$$u$$Group", (_variables: dict<Js.Json.t>) => {Js.import(GroupAvatar.make)->ignore}), 
  ("member.$$i$$Node", (_variables: dict<Js.Json.t>) => {Js.import(UserNode.make)->ignore}), 
])
@live let load: (
  ~environment: RescriptRelay.Environment.t,
  ~variables: Types.variables,
  ~fetchPolicy: RescriptRelay.fetchPolicy=?,
  ~fetchKey: string=?,
  ~networkCacheConfig: RescriptRelay.cacheConfig=?,
) => queryRef = (
  ~environment,
  ~variables,
  ~fetchPolicy=?,
  ~fetchKey=?,
  ~networkCacheConfig=?,
) =>
  RescriptRelay.loadQuery(
    environment,
    node,
    variables->Internal.convertVariables,
    {
      fetchKey,
      fetchPolicy,
      networkCacheConfig,
    },
  )

@live
let queryRefToObservable = token => {
  let raw = token->Internal.tokenToRaw
  raw.source->Js.Nullable.toOption
}
  
@live
let queryRefToPromise = token => {
  Js.Promise.make((~resolve, ~reject as _) => {
    switch token->queryRefToObservable {
    | None => resolve(Error())
    | Some(o) =>
      open RescriptRelay.Observable
      let _: subscription = o->subscribe(makeObserver(~complete=() => resolve(Ok())))
    }
  })
}
