/* @sourceLoc Test_customScalars.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type response = {
    customScalarArray: option<string>,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    asArray: array<SomeModule.Datetime.t>,
  }
  @live
  type refetchVariables = {
    asArray?: array<SomeModule.Datetime.t>,
  }
  @live let makeRefetchVariables = (
    ~asArray=?,
  ): refetchVariables => {
    asArray: ?asArray
  }

}


type queryRef

module Internal = {
  %%private(
  @live
  let variablesConverter: JSON.t = %raw(json`{"roots":{"__root":[{"list":1,"path":["asArray"],"scalar":"0"}]},"version":2}`)
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
  @live
  let convertWrapResponse = value => RescriptRelay.convertWithoutPlan(value, null)
  @live
  type responseRaw
  @live
  let convertResponse = value => RescriptRelay.convertWithoutPlan(value, None)
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
}

type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "asArray"
  }
],
v1 = [
  {
    "alias": null,
    "args": [
      {
        "kind": "Variable",
        "name": "asArray",
        "variableName": "asArray"
      }
    ],
    "kind": "ScalarField",
    "name": "customScalarArray",
    "storageKey": null
  }
];
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": null,
    "name": "TestCustomScalars2Query",
    "selections": (v1/*: any*/),
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "TestCustomScalars2Query",
    "selections": (v1/*: any*/)
  },
  "params": {
    "cacheID": "c8b3ec175f5f5908a091fe548358af1d",
    "id": null,
    "metadata": {},
    "name": "TestCustomScalars2Query",
    "operationKind": "query",
    "text": "query TestCustomScalars2Query(\n  $asArray: [Datetime!]!\n) {\n  customScalarArray(asArray: $asArray)\n}\n"
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
