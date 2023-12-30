/* @sourceLoc Test_preloadedQuery.res */
/* @generated */
%%raw("/* @generated */")
type queryRef = TestPreloadedQueryWithProvidedVariablesQuery_graphql.queryRef
module Types = {
  @@warning("-30")

  @live type someInput = RelaySchemaAssets_graphql.input_SomeInput
  @live type inputB = RelaySchemaAssets_graphql.input_InputB
  @live type inputA = RelaySchemaAssets_graphql.input_InputA
  @live
  type variables = {
    status?: RelaySchemaAssets_graphql.enum_OnlineStatus_input,
  }
}

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
}
module Utils = {
  @@warning("-33")
  open Types
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
