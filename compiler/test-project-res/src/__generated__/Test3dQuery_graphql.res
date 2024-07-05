/* @sourceLoc Test_3d.res */
/* @generated */
%%raw("/* @generated */")
// @dataDrivenDependency Test3dQuery.member {"branches":{"Group":{"component":"GroupAvatar","fragment":"GroupAvatar_group_normalization_graphql"},"User":{"component":"UserAvatar","fragment":"UserAvatar_user_normalization_graphql"}},"plural":false}

module Types = {
  @@warning("-30")

  @tag("__typename") type response_member = 
    | @live Group(
      {
        @live __typename: [ | #Group],
        __fragmentPropName: option<string>,
        __module_component: option<string>,
        fragmentRefs: RescriptRelay.fragmentRefs<[ | #GroupAvatar_group]>,
      }
    )
    | @live User(
      {
        @live __typename: [ | #User],
        __fragmentPropName: option<string>,
        __module_component: option<string>,
        fragmentRefs: RescriptRelay.fragmentRefs<[ | #UserAvatar_user]>,
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
    json`{"__root":{"member_User":{"f":""},"member_Group":{"f":""},"member":{"u":"response_member"}}}`
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
    json`{"__root":{"member_User":{"f":""},"member_Group":{"f":""},"member":{"u":"response_member"}}}`
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

type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = [
  {
    "kind": "Literal",
    "name": "id",
    "value": "123"
  },
  {
    "kind": "Literal",
    "name": "supported",
    "value": "3YDuAc"
  }
],
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
  "storageKey": null
},
v2 = {
  "kind": "InlineFragment",
  "selections": [
    {
      "args": null,
      "documentName": "Test3dQuery",
      "fragmentName": "GroupAvatar_group",
      "fragmentPropName": "group",
      "kind": "ModuleImport"
    }
  ],
  "type": "Group",
  "abstractKey": null
},
v3 = {
  "kind": "InlineFragment",
  "selections": [
    {
      "args": null,
      "documentName": "Test3dQuery",
      "fragmentName": "UserAvatar_user",
      "fragmentPropName": "user",
      "kind": "ModuleImport"
    }
  ],
  "type": "User",
  "abstractKey": null
},
v4 = [
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
    "name": "Test3dQuery",
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
          (v2/*: any*/),
          (v3/*: any*/)
        ],
        "storageKey": "member(id:\"123\",supported:\"3YDuAc\")"
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "Test3dQuery",
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
          (v2/*: any*/),
          (v3/*: any*/),
          {
            "kind": "InlineFragment",
            "selections": (v4/*: any*/),
            "type": "Node",
            "abstractKey": "__isNode"
          },
          {
            "kind": "InlineFragment",
            "selections": (v4/*: any*/),
            "type": "person",
            "abstractKey": null
          }
        ],
        "storageKey": "member(id:\"123\",supported:\"3YDuAc\")"
      }
    ]
  },
  "params": {
    "cacheID": "1b6e0b7d1387b3514bab0d59542d043a",
    "id": null,
    "metadata": {},
    "name": "Test3dQuery",
    "operationKind": "query",
    "text": "query Test3dQuery {\n  member(id: \"123\", supported: [\"Group\", \"User\"]) {\n    __typename\n    ... on Group {\n      ...GroupAvatar_group\n      __module_operation_Test3dQuery: js(module: \"GroupAvatar_group_normalization.graphql\", id: \"Test3dQuery.member\")\n      __module_component_Test3dQuery: js(module: \"GroupAvatar\", id: \"Test3dQuery.member\")\n    }\n    ... on User {\n      ...UserAvatar_user\n      __module_operation_Test3dQuery: js(module: \"UserAvatar_user_normalization.graphql\", id: \"Test3dQuery.member\")\n      __module_component_Test3dQuery: js(module: \"UserAvatar\", id: \"Test3dQuery.member\")\n    }\n    ... on Node {\n      __isNode: __typename\n      __typename\n      id\n    }\n    ... on person {\n      id\n    }\n  }\n}\n\nfragment GroupAvatar_group on Group {\n  name\n}\n\nfragment UserAvatar_user on User {\n  avatarUrl\n  ...UserName_user\n}\n\nfragment UserName_user on User {\n  firstName\n  lastName\n}\n"
  }
};
})() `)

let node = RescriptRelay_Internal.applyCodesplitMetadata(node, [
  ("member.$$u$$User.$$u$$User", () => {Js.import(UserName.make)->ignore}), 
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
