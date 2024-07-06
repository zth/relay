/* @sourceLoc Test_codesplit.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type rec response_member_Group_GroupAvatar_group = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #GroupAvatar_group]>,
  }
  and response_member_User_UserAvatar_user = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #UserAvatar_user]>,
  }
  and response_member_User_description_RichContent_content = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #RichContent_content]>,
  }
  and response_member_User_description = {
    @as("RichContent_content") richContent_content: response_member_User_description_RichContent_content,
  }
  @tag("__typename") and response_member = 
    | @live Group(
      {
        @live __typename: [ | #Group],
        @as("GroupAvatar_group") groupAvatar_group: option<response_member_Group_GroupAvatar_group>,
      }
    )
    | @live User(
      {
        @live __typename: [ | #User],
        @as("UserAvatar_user") userAvatar_user: option<response_member_User_UserAvatar_user>,
        description: option<response_member_User_description>,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

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

@live
let unwrap_response_member: Types.response_member => Types.response_member = RescriptRelay_Internal.unwrapUnion(_, ["Group", "User"])
@live
let wrap_response_member: Types.response_member => Types.response_member = RescriptRelay_Internal.wrapUnion

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
    json`{"__root":{"member_User_description_RichContent_content":{"f":""},"member_User_UserAvatar_user":{"f":""},"member_Group_GroupAvatar_group":{"f":""},"member":{"u":"response_member"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "response_member": wrap_response_member,
  }
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
    json`{"__root":{"member_User_description_RichContent_content":{"f":""},"member_User_UserAvatar_user":{"f":""},"member_Group_GroupAvatar_group":{"f":""},"member":{"u":"response_member"}}}`
  )
  @live
  let responseConverterMap = {
    "response_member": unwrap_response_member,
  }
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
];
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
          {
            "kind": "InlineFragment",
            "selections": (v2/*: any*/),
            "type": "Node",
            "abstractKey": "__isNode"
          },
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
    "cacheID": "8d020a37332d84aeeb0a33c6b779c8a6",
    "id": null,
    "metadata": {},
    "name": "TestCodesplitQuery",
    "operationKind": "query",
    "text": "query TestCodesplitQuery {\n  member(id: \"123\") {\n    __typename\n    ... on User {\n      ...UserAvatar_user\n      description {\n        ...RichContent_content\n      }\n    }\n    ... on Group {\n      ...GroupAvatar_group\n    }\n    ... on Node {\n      __isNode: __typename\n      __typename\n      id\n    }\n    ... on person {\n      id\n    }\n  }\n}\n\nfragment GroupAvatar_group on Group {\n  name\n}\n\nfragment RichContent_content on RichContent {\n  content\n}\n\nfragment UserAvatar_user on User {\n  avatarUrl\n  ...UserName_user\n}\n\nfragment UserName_user on User {\n  firstName\n  lastName\n}\n"
  }
};
})() `)

let node = RescriptRelay_Internal.applyCodesplitMetadata(node, [
  ("member.$$u$$User", () => {Js.import(UserAvatar.make)->ignore; Js.import(UserName.make)->ignore}), 
  ("member.$$u$$Group", () => {Js.import(GroupAvatar.make)->ignore}), 
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
