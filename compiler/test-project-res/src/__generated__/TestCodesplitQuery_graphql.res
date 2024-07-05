/* @sourceLoc Test_codesplit.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type rec response_member = {
    @live __typename: string,
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #GroupAvatar_group | #UserAvatar_user]>,
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
    json`{"__root":{"member":{"f":""}}}`
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
    json`{"__root":{"member":{"f":""}}}`
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
  module GroupAvatar = {
    let make = React.lazy_(() => Js.import(GroupAvatar.make))
  }
  module UserAvatar = {
    let make = React.lazy_(() => Js.import(UserAvatar.make))
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
            "args": null,
            "kind": "FragmentSpread",
            "name": "GroupAvatar_group"
          },
          {
            "args": null,
            "kind": "FragmentSpread",
            "name": "UserAvatar_user"
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
                "name": "name",
                "storageKey": null
              }
            ],
            "type": "Group",
            "abstractKey": null
          },
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
              }
            ],
            "type": "User",
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
    "cacheID": "7e3206466011725006269386f0d151b7",
    "id": null,
    "metadata": {},
    "name": "TestCodesplitQuery",
    "operationKind": "query",
    "text": "query TestCodesplitQuery {\n  member(id: \"123\") {\n    __typename\n    ...GroupAvatar_group\n    ...UserAvatar_user\n    ... on Node {\n      __isNode: __typename\n      __typename\n      id\n    }\n    ... on person {\n      id\n    }\n  }\n}\n\nfragment GroupAvatar_group on Group {\n  name\n}\n\nfragment UserAvatar_user on User {\n  avatarUrl\n  ...UserName_user\n}\n\nfragment UserName_user on User {\n  firstName\n  lastName\n}\n"
  }
};
})() `)

let node = RescriptRelay_Internal.applyCodesplitMetadata(node, [
  ("member.$$u$$Group", () => {Js.import(GroupAvatar.make)->ignore}), 
  ("member.$$u$$User", () => {Js.import(UserName.make)->ignore; Js.import(UserAvatar.make)->ignore}), 
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
