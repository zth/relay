/* @sourceLoc Test_providedVariables.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @live type someInput = RelaySchemaAssets_graphql.input_SomeInput
  @live type inputB = RelaySchemaAssets_graphql.input_InputB
  @live type inputA = RelaySchemaAssets_graphql.input_InputA
  type rec response_loggedInUser = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #TestProvidedVariables_user]>,
  }
  type response = {
    loggedInUser: response_loggedInUser,
  }
  @live
  type rawResponse = response
  @live
  type variables = unit
  @live
  type refetchVariables = unit
  @live let makeRefetchVariables = () => ()
}


type queryRef

module Internal = {
  @live
  let variablesConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"someInput":{"recursive":{"r":"someInput"},"datetime":{"c":"SomeModule.Datetime"}},"inputA":{"usingB":{"r":"inputB"},"timestamps":{"b":"a"},"timestamp":{"b":""},"time":{"c":"SomeModule.Datetime"},"recursiveA":{"r":"inputA"}},"inputB":{"usingA":{"r":"inputA"},"time":{"c":"SomeModule.Datetime"}},"__root":{"__relay_internal__pv__TestProvidedVariablesSomeInput":{"r":"someInput"},"__relay_internal__pv__TestProvidedVariablesInputB":{"r":"inputB"},"__relay_internal__pv__TestProvidedVariablesDatetimes":{"ca":"SomeModule.Datetime"},"__relay_internal__pv__TestProvidedVariablesDatetime":{"c":"SomeModule.Datetime"}}}`
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
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestProvidedVariablesQuery",
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
            "name": "TestProvidedVariables_user"
          }
        ],
        "storageKey": null
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [
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
    "name": "TestProvidedVariablesQuery",
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
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "firstName",
            "storageKey": null
          },
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
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "id",
            "storageKey": null
          }
        ],
        "storageKey": null
      }
    ]
  },
  "params": {
    "cacheID": "e126b7abfa263019306c87047185b1ff",
    "id": null,
    "metadata": {},
    "name": "TestProvidedVariablesQuery",
    "operationKind": "query",
    "text": "query TestProvidedVariablesQuery(\n  $__relay_internal__pv__TestProvidedVariablesSomeInput: SomeInput!\n  $__relay_internal__pv__TestProvidedVariablesInputB: InputB!\n  $__relay_internal__pv__TestProvidedVariablesBool: Boolean!\n  $__relay_internal__pv__TestProvidedVariablesStr: String!\n  $__relay_internal__pv__TestProvidedVariablesFloat: Float!\n  $__relay_internal__pv__TestProvidedVariablesInt: Int\n  $__relay_internal__pv__TestProvidedVariablesID: ID\n  $__relay_internal__pv__TestProvidedVariablesDatetime: Datetime\n  $__relay_internal__pv__TestProvidedVariablesDatetimes: [Datetime!]\n) {\n  loggedInUser {\n    ...TestProvidedVariables_user\n    id\n  }\n}\n\nfragment TestProvidedVariables_user on User {\n  firstName\n  onlineStatus(someInput: $__relay_internal__pv__TestProvidedVariablesSomeInput, inputB: $__relay_internal__pv__TestProvidedVariablesInputB, bool: $__relay_internal__pv__TestProvidedVariablesBool, str: $__relay_internal__pv__TestProvidedVariablesStr, float: $__relay_internal__pv__TestProvidedVariablesFloat, int: $__relay_internal__pv__TestProvidedVariablesInt, id: $__relay_internal__pv__TestProvidedVariablesID, dateTime: $__relay_internal__pv__TestProvidedVariablesDatetime, dateTimes: $__relay_internal__pv__TestProvidedVariablesDatetimes)\n}\n",
    "providedVariables": providedVariablesDefinition
  }
}`)
})
let node: operationType = makeNode(providedVariablesDefinition)

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
