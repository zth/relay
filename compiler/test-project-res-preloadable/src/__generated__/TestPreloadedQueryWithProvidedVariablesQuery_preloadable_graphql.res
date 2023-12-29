/* @sourceLoc Test_preloadedQuery.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  type variables = TestPreloadedQueryWithProvidedVariablesQuery_graphql.Types.variables
}
module Internal = {
  module Variables = {
    include TestPreloadedQueryWithProvidedVariablesQuery_graphql.Internal.Variables
  }
  let convertVariables = Variables.convertVariables
}
module ProvidedVariables = {
  include TestPreloadedQueryWithProvidedVariablesQuery_graphql.ProvidedVariables
  }
let providedVariablesDefinition = ProvidedVariables.providedVariablesDefinition
type queryRef = TestPreloadedQueryWithProvidedVariablesQuery_graphql.queryRef

type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>


%%private(let makeNode = (providedVariablesDefinition): operationType => {
  ignore(providedVariablesDefinition)
  %raw(json`{
  "kind": "PreloadableConcreteRequest",
  "params": {
    "id": "e2103af665a0e792e8f00f56ebb0c3e4",
    "metadata": {},
    "name": "TestPreloadedQueryWithProvidedVariablesQuery",
    "operationKind": "query",
    "text": null,
    "providedVariables": providedVariablesDefinition
  }
}`)
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
