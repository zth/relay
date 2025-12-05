/* @sourceLoc Test_preloadedQuery.res */
/* @generated */
%%raw("/* @generated */")
type queryRef = TestPreloadedQueryWithCodesplitQuery_graphql.queryRef
module Types = {
  @@warning("-30")

  @live
  type variables = unit
}

module Internal = {
  @live
  let variablesConverter: dict<dict<dict<string>>> = %raw(
    json`{}`
  )
  @live
  let variablesConverterMap = ()
  @live
  let convertVariables = v => v->RescriptRelay.convertObj(
    variablesConverter,
    variablesConverterMap,
    None
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
    "id": "258078f3456869cbf67a1f1aca9549a1",
    "metadata": {},
    "name": "TestPreloadedQueryWithCodesplitQuery",
    "operationKind": "query",
    "text": null
  }
} `)

let node = RescriptRelay_Internal.applyCodesplitMetadata(node, [
  ("member.$$u$$User", (_variables: dict<JSON.t>) => {import(UserAvatar.make)->ignore; import(UserName.make)->ignore}), 
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
