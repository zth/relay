/* @sourceLoc Test_queryInputObj.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type pesticideListSearchInput = RelaySchemaAssets_graphql.input_PesticideListSearchInput
  type response = {
    searchPesticie: option<string>,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    input: pesticideListSearchInput,
  }
  @live
  type refetchVariables = {
    input?: pesticideListSearchInput,
  }
  @live let makeRefetchVariables = (
    ~input=?,
  ): refetchVariables => {
    input: ?input
  }

}


type queryRef

module Internal = {
  %%private(
  @live
  let variablesConverter: JSON.t = %raw(json`{"roots":{"__root":[{"path":["input"],"reference":"pesticideListSearchInput"}],"pesticideListSearchInput":[]},"version":2}`)
  @live
  let variablesCallbacks = ()
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
    "name": "input"
  }
],
v1 = [
  {
    "alias": null,
    "args": [
      {
        "kind": "Variable",
        "name": "input",
        "variableName": "input"
      }
    ],
    "kind": "ScalarField",
    "name": "searchPesticie",
    "storageKey": null
  }
];
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": null,
    "name": "TestQueryInputObjQuery",
    "selections": (v1/*: any*/),
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "TestQueryInputObjQuery",
    "selections": (v1/*: any*/)
  },
  "params": {
    "cacheID": "379a28ab73fa483cd9cae404baa28064",
    "id": null,
    "metadata": {},
    "name": "TestQueryInputObjQuery",
    "operationKind": "query",
    "text": "query TestQueryInputObjQuery(\n  $input: PesticideListSearchInput!\n) {\n  searchPesticie(input: $input)\n}\n"
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
