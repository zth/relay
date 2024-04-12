/* @sourceLoc Test_customScalars.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @tag("__typename") type response_member = 
    | @live User(
      {
        @live __typename: [ | #User],
        createdAt: SomeModule.Datetime.t,
        datetimes: option<array<option<SomeModule.Datetime.t>>>,
        onlineStatus: option<RelaySchemaAssets_graphql.enum_OnlineStatus>,
        onlineStatus2: option<RelaySchemaAssets_graphql.enum_OnlineStatus>,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  type rec response_loggedInUser_friends = {
    createdAt: SomeModule.Datetime.t,
  }
  and response_loggedInUser = {
    createdAt: SomeModule.Datetime.t,
    datetimes: option<array<option<SomeModule.Datetime.t>>>,
    friends: array<response_loggedInUser_friends>,
    onlineStatus: option<RelaySchemaAssets_graphql.enum_OnlineStatus>,
    onlineStatus2: option<RelaySchemaAssets_graphql.enum_OnlineStatus>,
  }
  type response = {
    loggedInUser: response_loggedInUser,
    member: option<response_member>,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    beforeDate?: SomeModule.Datetime.t,
    datetimes?: array<SomeModule.Datetime.t>,
  }
  @live
  type refetchVariables = {
    beforeDate: option<option<SomeModule.Datetime.t>>,
    datetimes: option<option<array<SomeModule.Datetime.t>>>,
  }
  @live let makeRefetchVariables = (
    ~beforeDate=?,
    ~datetimes=?,
  ): refetchVariables => {
    beforeDate: beforeDate,
    datetimes: datetimes
  }

}

@live
let unwrap_response_member: Types.response_member => Types.response_member = RescriptRelay_Internal.unwrapUnion(_, ["User"])
@live
let wrap_response_member: Types.response_member => Types.response_member = RescriptRelay_Internal.wrapUnion

type queryRef

module Internal = {
  @live
  let variablesConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"__root":{"datetimes":{"ca":"SomeModule.Datetime"},"beforeDate":{"c":"SomeModule.Datetime"}}}`
  )
  @live
  let variablesConverterMap = {
    "SomeModule.Datetime": SomeModule.Datetime.serialize,
  }
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
    json`{"__root":{"member_User_datetimes":{"ca":"SomeModule.Datetime"},"member_User_createdAt":{"c":"SomeModule.Datetime"},"member":{"u":"response_member"},"loggedInUser_friends_createdAt":{"c":"SomeModule.Datetime"},"loggedInUser_datetimes":{"ca":"SomeModule.Datetime"},"loggedInUser_createdAt":{"c":"SomeModule.Datetime"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "SomeModule.Datetime": SomeModule.Datetime.serialize,
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
    json`{"__root":{"member_User_datetimes":{"ca":"SomeModule.Datetime"},"member_User_createdAt":{"c":"SomeModule.Datetime"},"member":{"u":"response_member"},"loggedInUser_friends_createdAt":{"c":"SomeModule.Datetime"},"loggedInUser_datetimes":{"ca":"SomeModule.Datetime"},"loggedInUser_createdAt":{"c":"SomeModule.Datetime"}}}`
  )
  @live
  let responseConverterMap = {
    "SomeModule.Datetime": SomeModule.Datetime.parse,
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
  @live
  external onlineStatus_toString: RelaySchemaAssets_graphql.enum_OnlineStatus => string = "%identity"
  @live
  external onlineStatus_input_toString: RelaySchemaAssets_graphql.enum_OnlineStatus_input => string = "%identity"
  @live
  let onlineStatus_decode = (enum: RelaySchemaAssets_graphql.enum_OnlineStatus): option<RelaySchemaAssets_graphql.enum_OnlineStatus_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let onlineStatus_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_OnlineStatus_input> => {
    onlineStatus_decode(Obj.magic(str))
  }
}

type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "beforeDate"
  },
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "datetimes"
  }
],
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "createdAt",
  "storageKey": null
},
v2 = [
  {
    "kind": "Variable",
    "name": "beforeDate",
    "variableName": "beforeDate"
  }
],
v3 = {
  "alias": null,
  "args": [
    {
      "kind": "Literal",
      "name": "dateTimes",
      "value": [
        "2024-01-17T00:00:00.000Z"
      ]
    }
  ],
  "kind": "ScalarField",
  "name": "onlineStatus",
  "storageKey": "onlineStatus(dateTimes:[\"2024-01-17T00:00:00.000Z\"])"
},
v4 = {
  "alias": "onlineStatus2",
  "args": [
    {
      "kind": "Variable",
      "name": "dateTimes",
      "variableName": "datetimes"
    }
  ],
  "kind": "ScalarField",
  "name": "onlineStatus",
  "storageKey": null
},
v5 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "datetimes",
  "storageKey": null
},
v6 = [
  {
    "kind": "Literal",
    "name": "id",
    "value": "user-1"
  }
],
v7 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
  "storageKey": null
},
v8 = {
  "kind": "InlineFragment",
  "selections": [
    (v1/*: any*/),
    (v3/*: any*/),
    (v4/*: any*/),
    (v5/*: any*/)
  ],
  "type": "User",
  "abstractKey": null
},
v9 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v10 = [
  (v9/*: any*/)
];
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": null,
    "name": "TestCustomScalarsQuery",
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "loggedInUser",
        "plural": false,
        "selections": [
          (v1/*: any*/),
          {
            "alias": null,
            "args": (v2/*: any*/),
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "friends",
            "plural": true,
            "selections": [
              (v1/*: any*/)
            ],
            "storageKey": null
          },
          (v3/*: any*/),
          (v4/*: any*/),
          (v5/*: any*/)
        ],
        "storageKey": null
      },
      {
        "alias": null,
        "args": (v6/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "member",
        "plural": false,
        "selections": [
          (v7/*: any*/),
          (v8/*: any*/)
        ],
        "storageKey": "member(id:\"user-1\")"
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "TestCustomScalarsQuery",
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "loggedInUser",
        "plural": false,
        "selections": [
          (v1/*: any*/),
          {
            "alias": null,
            "args": (v2/*: any*/),
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "friends",
            "plural": true,
            "selections": [
              (v1/*: any*/),
              (v9/*: any*/)
            ],
            "storageKey": null
          },
          (v3/*: any*/),
          (v4/*: any*/),
          (v5/*: any*/),
          (v9/*: any*/)
        ],
        "storageKey": null
      },
      {
        "alias": null,
        "args": (v6/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "member",
        "plural": false,
        "selections": [
          (v7/*: any*/),
          (v8/*: any*/),
          {
            "kind": "InlineFragment",
            "selections": (v10/*: any*/),
            "type": "Node",
            "abstractKey": "__isNode"
          },
          {
            "kind": "InlineFragment",
            "selections": (v10/*: any*/),
            "type": "person",
            "abstractKey": null
          }
        ],
        "storageKey": "member(id:\"user-1\")"
      }
    ]
  },
  "params": {
    "cacheID": "c636269d11ee6352165ad30b9808d4a0",
    "id": null,
    "metadata": {},
    "name": "TestCustomScalarsQuery",
    "operationKind": "query",
    "text": "query TestCustomScalarsQuery(\n  $beforeDate: Datetime\n  $datetimes: [Datetime!]\n) {\n  loggedInUser {\n    createdAt\n    friends(beforeDate: $beforeDate) {\n      createdAt\n      id\n    }\n    onlineStatus(dateTimes: [\"2024-01-17T00:00:00.000Z\"])\n    onlineStatus2: onlineStatus(dateTimes: $datetimes)\n    datetimes\n    id\n  }\n  member(id: \"user-1\") {\n    __typename\n    ... on User {\n      createdAt\n      onlineStatus(dateTimes: [\"2024-01-17T00:00:00.000Z\"])\n      onlineStatus2: onlineStatus(dateTimes: $datetimes)\n      datetimes\n    }\n    ... on Node {\n      __isNode: __typename\n      __typename\n      id\n    }\n    ... on person {\n      id\n    }\n  }\n}\n"
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
