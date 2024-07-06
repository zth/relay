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
    description: option<response_member_description>,
  }
  type response = {
    member: option<response_member>,
  }
  @live
  type rawResponse = response
  @live
  type variables = unit
  @live
  type refetchVariables = unit
  @live let makeRefetchVariables = () => ()
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
    json`{"__root":{"member_description_RichContent_content":{"f":""},"member_UserNode_node":{"f":""},"member_UserAvatar_user":{"f":""},"member_GroupAvatar_group":{"f":""}}}`
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
    json`{"__root":{"member_description_RichContent_content":{"f":""},"member_UserNode_node":{"f":""},"member_UserAvatar_user":{"f":""},"member_GroupAvatar_group":{"f":""}}}`
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
    "kind": "Literal",
    "name": "id",
    "value": "123"
  }
],
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
  "storageKey": null
},
v2 = [
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "id",
    "storageKey": null
  }
],
v3 = {
  "kind": "InlineFragment",
  "selections": (v2/*: any*/),
  "type": "Node",
  "abstractKey": "__isNode"
};
return {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestCodesplitQuery",
    "selections": [
      {
        "alias": null,
        "args": (v0/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "member",
        "plural": false,
        "selections": [
          (v1/*: any*/),
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
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "TestCodesplitQuery",
    "selections": [
      {
        "alias": null,
        "args": (v0/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "member",
        "plural": false,
        "selections": [
          (v1/*: any*/),
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
              {
                "alias": null,
                "args": null,
                "kind": "ScalarField",
                "name": "firstName",
                "storageKey": null
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
          (v3/*: any*/),
          (v3/*: any*/),
          {
            "kind": "InlineFragment",
            "selections": (v2/*: any*/),
            "type": "person",
            "abstractKey": null
          }
        ],
        "storageKey": "member(id:\"123\")"
      }
    ]
  },
  "params": {
    "cacheID": "32a7a55f13bf72c10405e7e1e3779462",
    "id": null,
    "metadata": {},
    "name": "TestCodesplitQuery",
    "operationKind": "query",
    "text": "query TestCodesplitQuery {\n  member(id: \"123\") {\n    __typename\n    ... on User {\n      ...UserAvatar_user\n      description {\n        ...RichContent_content\n      }\n    }\n    ... on Group {\n      ...GroupAvatar_group\n    }\n    ...UserNode_node\n    ... on Node {\n      __isNode: __typename\n      __typename\n      id\n    }\n    ... on person {\n      id\n    }\n  }\n}\n\nfragment GroupAvatar_group on Group {\n  name\n}\n\nfragment RichContent_content on RichContent {\n  content\n}\n\nfragment UserAvatar_user on User {\n  avatarUrl\n  ...UserName_user\n}\n\nfragment UserName_user on User {\n  firstName\n  lastName\n}\n\nfragment UserNode_node on Node {\n  __isNode: __typename\n  __typename\n  id\n}\n"
  }
};
})() `)

let node = RescriptRelay_Internal.applyCodesplitMetadata(node, [
  ("member.$$u$$User", () => {Js.import(UserAvatar.make)->ignore; Js.import(UserName.make)->ignore}), 
  ("member.$$u$$User.description", () => {Js.import(RichContent.make)->ignore}), 
  ("member.$$u$$Group", () => {Js.import(GroupAvatar.make)->ignore}), 
  ("member.$$i$$Node", () => {Js.import(UserNode.make)->ignore}), 
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
