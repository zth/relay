/* @sourceLoc Test_preloadedQuery.res */
/* @generated */
%%raw("/* @generated */")
// @relayRequestID e2103af665a0e792e8f00f56ebb0c3e4

module Types = {
  @@warning("-30")

  @live type someInput = RelaySchemaAssets_graphql.input_SomeInput
  @live type inputB = RelaySchemaAssets_graphql.input_InputB
  @live type inputA = RelaySchemaAssets_graphql.input_InputA
  type rec response_loggedInUser = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #TestPreloadedQuery_user]>,
  }
  and response_users_edges_node = {
    firstName: string,
    @live id: string,
    onlineStatus: option<RelaySchemaAssets_graphql.enum_OnlineStatus>,
  }
  and response_users_edges = {
    node: option<response_users_edges_node>,
  }
  and response_users = {
    edges: option<array<option<response_users_edges>>>,
  }
  type response = {
    loggedInUser: response_loggedInUser,
    users: option<response_users>,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    status?: RelaySchemaAssets_graphql.enum_OnlineStatus_input,
  }
  @live
  type refetchVariables = {
    status: option<option<RelaySchemaAssets_graphql.enum_OnlineStatus_input>>,
  }
  @live let makeRefetchVariables = (
    ~status=?,
  ): refetchVariables => {
    status: status
  }

}


type queryRef

module Internal = {
  @live
  let variablesConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"someInput":{"recursive":{"r":"someInput"},"datetime":{"c":"SomeModule.Datetime"}},"inputA":{"usingB":{"r":"inputB"},"timestamps":{"b":"a"},"timestamp":{"b":""},"time":{"c":"SomeModule.Datetime"},"recursiveA":{"r":"inputA"}},"inputB":{"usingA":{"r":"inputA"},"time":{"c":"SomeModule.Datetime"}},"__root":{"__relay_internal__pv__TestProvidedVariablesSomeInput":{"r":"someInput"},"__relay_internal__pv__TestProvidedVariablesInputB":{"r":"inputB"},"__relay_internal__pv__TestProvidedVariablesDatetimes":{"c":"SomeModule.Datetime"},"__relay_internal__pv__TestProvidedVariablesDatetime":{"c":"SomeModule.Datetime"}}}`
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
    json`{"__root":{"loggedInUser":{"f":""}}}`
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
    json`{"__root":{"loggedInUser":{"f":""}}}`
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
type providedVariable<'t> = { providedVariable: unit => 't, get: unit => 't }
type providedVariablesType = {
  __relay_internal__pv__TestProvidedVariablesBool: providedVariable<bool>,
  __relay_internal__pv__TestProvidedVariablesDatetime: providedVariable<option<SomeModule.Datetime.t>>,
  __relay_internal__pv__TestProvidedVariablesDatetimes: providedVariable<option<array<SomeModule.Datetime.t>>>,
  __relay_internal__pv__TestProvidedVariablesFloat: providedVariable<float>,
  __relay_internal__pv__TestProvidedVariablesID: providedVariable<option<string>>,
  __relay_internal__pv__TestProvidedVariablesInputB: providedVariable<RelaySchemaAssets_graphql.input_InputB>,
  __relay_internal__pv__TestProvidedVariablesInt: providedVariable<option<int>>,
  __relay_internal__pv__TestProvidedVariablesSomeInput: providedVariable<RelaySchemaAssets_graphql.input_SomeInput>,
  __relay_internal__pv__TestProvidedVariablesStr: providedVariable<string>,
}
let providedVariablesDefinition: providedVariablesType = {
  __relay_internal__pv__TestProvidedVariablesSomeInput: {
    providedVariable: TestProvidedVariables.SomeInput.get,
    get: () => Internal.convertVariables(Js.Dict.fromArray([("__relay_internal__pv__TestProvidedVariablesSomeInput", TestProvidedVariables.SomeInput.get())]))->Js.Dict.unsafeGet("__relay_internal__pv__TestProvidedVariablesSomeInput"),
  },
  __relay_internal__pv__TestProvidedVariablesInputB: {
    providedVariable: TestProvidedVariables.InputB.get,
    get: () => Internal.convertVariables(Js.Dict.fromArray([("__relay_internal__pv__TestProvidedVariablesInputB", TestProvidedVariables.InputB.get())]))->Js.Dict.unsafeGet("__relay_internal__pv__TestProvidedVariablesInputB"),
  },
  __relay_internal__pv__TestProvidedVariablesBool: {
    providedVariable: TestProvidedVariables.Bool.get,
    get: TestProvidedVariables.Bool.get,
  },
  __relay_internal__pv__TestProvidedVariablesStr: {
    providedVariable: TestProvidedVariables.Str.get,
    get: TestProvidedVariables.Str.get,
  },
  __relay_internal__pv__TestProvidedVariablesFloat: {
    providedVariable: TestProvidedVariables.Float.get,
    get: TestProvidedVariables.Float.get,
  },
  __relay_internal__pv__TestProvidedVariablesInt: {
    providedVariable: TestProvidedVariables.Int.get,
    get: TestProvidedVariables.Int.get,
  },
  __relay_internal__pv__TestProvidedVariablesID: {
    providedVariable: TestProvidedVariables.ID.get,
    get: TestProvidedVariables.ID.get,
  },
  __relay_internal__pv__TestProvidedVariablesDatetime: {
    providedVariable: TestProvidedVariables.Datetime.get,
    get: () => Internal.convertVariables(Js.Dict.fromArray([("__relay_internal__pv__TestProvidedVariablesDatetime", TestProvidedVariables.Datetime.get())]))->Js.Dict.unsafeGet("__relay_internal__pv__TestProvidedVariablesDatetime"),
  },
  __relay_internal__pv__TestProvidedVariablesDatetimes: {
    providedVariable: TestProvidedVariables.Datetimes.get,
    get: () => Internal.convertVariables(Js.Dict.fromArray([("__relay_internal__pv__TestProvidedVariablesDatetimes", TestProvidedVariables.Datetimes.get())]))->Js.Dict.unsafeGet("__relay_internal__pv__TestProvidedVariablesDatetimes"),
  },
}

type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>


%%private(let makeNode = (providedVariablesDefinition): operationType => {
  ignore(providedVariablesDefinition)
  %raw(json`(function(){
var v0 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "status"
},
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v2 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "firstName",
  "storageKey": null
},
v3 = {
  "alias": null,
  "args": [
    {
      "kind": "Variable",
      "name": "status",
      "variableName": "status"
    }
  ],
  "concreteType": "UserConnection",
  "kind": "LinkedField",
  "name": "users",
  "plural": false,
  "selections": [
    {
      "alias": null,
      "args": null,
      "concreteType": "UserEdge",
      "kind": "LinkedField",
      "name": "edges",
      "plural": true,
      "selections": [
        {
          "alias": null,
          "args": null,
          "concreteType": "User",
          "kind": "LinkedField",
          "name": "node",
          "plural": false,
          "selections": [
            (v1/*: any*/),
            (v2/*: any*/),
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "onlineStatus",
              "storageKey": null
            }
          ],
          "storageKey": null
        }
      ],
      "storageKey": null
    }
  ],
  "storageKey": null
};
return {
  "fragment": {
    "argumentDefinitions": [
      (v0/*: any*/)
    ],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestPreloadedQueryWithProvidedVariablesQuery",
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "loggedInUser",
        "plural": false,
        "selections": [
          {
            "args": null,
            "kind": "FragmentSpread",
            "name": "TestPreloadedQuery_user"
          }
        ],
        "storageKey": null
      },
      (v3/*: any*/)
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [
      (v0/*: any*/),
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesSomeInput"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesInputB"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesBool"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesStr"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesFloat"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesInt"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesID"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesDatetime"
      },
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "__relay_internal__pv__TestProvidedVariablesDatetimes"
      }
    ],
    "kind": "Operation",
    "name": "TestPreloadedQueryWithProvidedVariablesQuery",
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "loggedInUser",
        "plural": false,
        "selections": [
          (v2/*: any*/),
          {
            "alias": null,
            "args": [
              {
                "kind": "Variable",
                "name": "bool",
                "variableName": "__relay_internal__pv__TestProvidedVariablesBool"
              },
              {
                "kind": "Variable",
                "name": "dateTime",
                "variableName": "__relay_internal__pv__TestProvidedVariablesDatetime"
              },
              {
                "kind": "Variable",
                "name": "dateTimes",
                "variableName": "__relay_internal__pv__TestProvidedVariablesDatetimes"
              },
              {
                "kind": "Variable",
                "name": "float",
                "variableName": "__relay_internal__pv__TestProvidedVariablesFloat"
              },
              {
                "kind": "Variable",
                "name": "id",
                "variableName": "__relay_internal__pv__TestProvidedVariablesID"
              },
              {
                "kind": "Variable",
                "name": "inputB",
                "variableName": "__relay_internal__pv__TestProvidedVariablesInputB"
              },
              {
                "kind": "Variable",
                "name": "int",
                "variableName": "__relay_internal__pv__TestProvidedVariablesInt"
              },
              {
                "kind": "Variable",
                "name": "someInput",
                "variableName": "__relay_internal__pv__TestProvidedVariablesSomeInput"
              },
              {
                "kind": "Variable",
                "name": "str",
                "variableName": "__relay_internal__pv__TestProvidedVariablesStr"
              }
            ],
            "kind": "ScalarField",
            "name": "onlineStatus",
            "storageKey": null
          },
          (v1/*: any*/)
        ],
        "storageKey": null
      },
      (v3/*: any*/)
    ]
  },
  "params": {
    "id": "e2103af665a0e792e8f00f56ebb0c3e4",
    "metadata": {},
    "name": "TestPreloadedQueryWithProvidedVariablesQuery",
    "operationKind": "query",
    "text": null,
    "providedVariables": providedVariablesDefinition
  }
};
})()`)
})
let node: operationType = makeNode(providedVariablesDefinition)

let load: (
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
  
let queryRefToObservable = token => {
  let raw = token->Internal.tokenToRaw
  raw.source->Js.Nullable.toOption
}
  
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
type operationId
type operationTypeParams = {id: operationId}
@get external getOperationTypeParams: operationType => operationTypeParams = "params"
@module("relay-runtime") @scope("PreloadableQueryRegistry") external setPreloadQuery: (operationId, operationType) => unit = "set"
getOperationTypeParams(node).id->setPreloadQuery(node)
