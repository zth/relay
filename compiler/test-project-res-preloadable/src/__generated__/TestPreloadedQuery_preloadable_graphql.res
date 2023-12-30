/* @sourceLoc Test_preloadedQuery.res */
/* @generated */
%%raw("/* @generated */")
type queryRef = TestPreloadedQuery_graphql.queryRef
module Types = {
  @@warning("-30")

  @live
  type variables = {
    status?: RelaySchemaAssets_graphql.enum_OnlineStatus_input,
  }
}

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
}
module Utils = {
  @@warning("-33")
  open Types
}

type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json` {
  "kind": "PreloadableConcreteRequest",
  "params": {
    "id": "64e1bd5c44a860103e5980b544f5e454",
    "metadata": {},
    "name": "TestPreloadedQuery",
    "operationKind": "query",
    "text": null
  }
} `)

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
