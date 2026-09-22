/* @sourceLoc Test_customScalars.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @tag("__typename") type response_member = 
    | @live User(
      {
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
    beforeDate?: option<SomeModule.Datetime.t>,
    datetimes?: option<array<SomeModule.Datetime.t>>,
  }
  @live let makeRefetchVariables = (
    ~beforeDate=?,
    ~datetimes=?,
  ): refetchVariables => {
    beforeDate: ?beforeDate,
    datetimes: ?datetimes
  }

}

@live
let unwrap_response_member: Types.response_member => Types.response_member = RescriptRelay_Internal.unwrapUnion(_, ["User"])
@live
let wrap_response_member: Types.response_member => Types.response_member = RescriptRelay_Internal.wrapUnion

type queryRef

module Internal = {
  %%private(
  @live
  let variablesConverter: JSON.t = %raw(json`{"roots":{"__root":[{"path":["beforeDate"],"scalar":"0"},{"list":1,"path":["datetimes"],"scalar":"0"}]},"version":2}`)
  @live
  let variablesCallbacks = {
    "0": SomeModule.Datetime.serialize,
  }
  @live
  let preparedVariablesConverter = RescriptRelay.prepareConversion(
    variablesConverter,
    variablesCallbacks,
    None
  )
  )
  @live
  let convertVariables = value => RescriptRelay.runConversion(preparedVariablesConverter, value)
  @live
  type wrapResponseRaw
  %%private(
  @live
  let wrapResponseConverter: JSON.t = %raw(json`{"roots":{"__root":[{"path":["loggedInUser","createdAt"],"scalar":"0"},{"list":1,"path":["loggedInUser","datetimes"],"scalar":"0"},{"list":1,"path":["loggedInUser","friends"]},{"path":["loggedInUser","friends","createdAt"],"scalar":"0"},{"path":["member"],"union":"1"},{"path":["member","User","createdAt"],"scalar":"0"},{"list":1,"path":["member","User","datetimes"],"scalar":"0"}]},"version":2}`)
  @live
  let wrapResponseCallbacks = {
    "0": SomeModule.Datetime.serialize,
    "1": wrap_response_member,
  }
  @live
  let preparedWrapResponseConverter = RescriptRelay.prepareConversion(
    wrapResponseConverter,
    wrapResponseCallbacks,
    null
  )
  )
  @live
  let convertWrapResponse = value => RescriptRelay.runConversion(preparedWrapResponseConverter, value)
  @live
  type responseRaw
  %%private(
  @live
  let responseConverter = wrapResponseConverter
  @live
  let responseCallbacks = {
    "0": SomeModule.Datetime.parse,
    "1": unwrap_response_member,
  }
  @live
  let preparedResponseConverter = RescriptRelay.prepareConversion(
    responseConverter,
    responseCallbacks,
    None
  )
  )
  @live
  let convertResponse = value => RescriptRelay.runConversion(preparedResponseConverter, value)
  type wrapRawResponseRaw = wrapResponseRaw
  @live
  let convertWrapRawResponse = convertWrapResponse
  type rawResponseRaw = responseRaw
  @live
  let convertRawResponse = convertResponse
  type rawPreloadToken<'response> = {source: Nullable.t<RescriptRelay.Observable.t<'response>>}
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
  RescriptRelayReact.loadQuery(
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
  raw.source->Nullable.toOption
}
  
@live
let queryRefToPromise = token => {
  Promise.make((resolve, _reject) => {
    switch token->queryRefToObservable {
    | None => resolve(Error())
    | Some(o) =>
      open RescriptRelay.Observable
      let _: subscription = o->subscribe(makeObserver(~complete=() => resolve(Ok())))
    }
  })
}
