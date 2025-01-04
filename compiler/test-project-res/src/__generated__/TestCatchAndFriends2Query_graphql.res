/* @sourceLoc Test_catchAndFriends.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @tag("__typename") type response_member_value_User_memberOfSingular_value = 
    | @live User(
      {
        @live __typename: [ | #User],
        createdAt: SomeModule.Datetime.t,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  @tag("__typename") type response_member_value = 
    | @live User(
      {
        @live __typename: [ | #User],
        @live id: string,
        memberOfSingular: RescriptRelay.CatchResult.t<response_member_value_User_memberOfSingular_value>,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  type response = {
    member: RescriptRelay.CatchResult.t<response_member_value>,
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
let unwrap_response_member_value_User_memberOfSingular_value: Types.response_member_value_User_memberOfSingular_value => Types.response_member_value_User_memberOfSingular_value = RescriptRelay_Internal.unwrapUnion(_, ["User"])
@live
let wrap_response_member_value_User_memberOfSingular_value: Types.response_member_value_User_memberOfSingular_value => Types.response_member_value_User_memberOfSingular_value = RescriptRelay_Internal.wrapUnion
@live
let unwrap_response_member_value: Types.response_member_value => Types.response_member_value = RescriptRelay_Internal.unwrapUnion(_, ["User"])
@live
let wrap_response_member_value: Types.response_member_value => Types.response_member_value = RescriptRelay_Internal.wrapUnion

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
    json`{"__root":{"member_value_User_memberOfSingular_value_User_createdAt":{"c":"SomeModule.Datetime"},"member_value_User_memberOfSingular_value":{"u":"response_member_value_User_memberOfSingular_value"},"member_value":{"u":"response_member_value"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "SomeModule.Datetime": SomeModule.Datetime.serialize,
    "response_member_value_User_memberOfSingular_value": wrap_response_member_value_User_memberOfSingular_value,
    "response_member_value": wrap_response_member_value,
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
    json`{"__root":{"member_value_User_memberOfSingular_value_User_createdAt":{"c":"SomeModule.Datetime"},"member_value_User_memberOfSingular_value":{"u":"response_member_value_User_memberOfSingular_value"},"member_value":{"u":"response_member_value"}}}`
  )
  @live
  let responseConverterMap = {
    "SomeModule.Datetime": SomeModule.Datetime.parse,
    "response_member_value_User_memberOfSingular_value": unwrap_response_member_value_User_memberOfSingular_value,
    "response_member_value": unwrap_response_member_value,
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
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v3 = {
  "kind": "InlineFragment",
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
},
v4 = [
  (v2/*: any*/)
],
v5 = {
  "kind": "InlineFragment",
  "selections": (v4/*: any*/),
  "type": "Node",
  "abstractKey": "__isNode"
},
v6 = {
  "kind": "InlineFragment",
  "selections": (v4/*: any*/),
  "type": "person",
  "abstractKey": null
};
return {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestCatchAndFriends2Query",
    "selections": [
      {
        "kind": "CatchField",
        "field": {
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
                (v2/*: any*/),
                {
                  "kind": "CatchField",
                  "field": {
                    "alias": null,
                    "args": null,
                    "concreteType": null,
                    "kind": "LinkedField",
                    "name": "memberOfSingular",
                    "plural": false,
                    "selections": [
                      (v1/*: any*/),
                      (v3/*: any*/)
                    ],
                    "storageKey": null
                  },
                  "to": "RESULT"
                }
              ],
              "type": "User",
              "abstractKey": null
            }
          ],
          "storageKey": "member(id:\"123\")"
        },
        "to": "RESULT"
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "TestCatchAndFriends2Query",
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
              (v2/*: any*/),
              {
                "alias": null,
                "args": null,
                "concreteType": null,
                "kind": "LinkedField",
                "name": "memberOfSingular",
                "plural": false,
                "selections": [
                  (v1/*: any*/),
                  (v3/*: any*/),
                  (v5/*: any*/),
                  (v6/*: any*/)
                ],
                "storageKey": null
              }
            ],
            "type": "User",
            "abstractKey": null
          },
          (v5/*: any*/),
          (v6/*: any*/)
        ],
        "storageKey": "member(id:\"123\")"
      }
    ]
  },
  "params": {
    "cacheID": "409831d8a6bf938b462e1c61cb77f8cc",
    "id": null,
    "metadata": {},
    "name": "TestCatchAndFriends2Query",
    "operationKind": "query",
    "text": "query TestCatchAndFriends2Query {\n  member(id: \"123\") {\n    __typename\n    ... on User {\n      id\n      memberOfSingular {\n        __typename\n        ... on User {\n          createdAt\n        }\n        ... on Node {\n          __isNode: __typename\n          __typename\n          id\n        }\n        ... on person {\n          id\n        }\n      }\n    }\n    ... on Node {\n      __isNode: __typename\n      __typename\n      id\n    }\n    ... on person {\n      id\n    }\n  }\n}\n"
  }
};
})() `)

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
