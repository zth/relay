/* @sourceLoc Test_modelResolverAliased.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type rec response_myLocal_meta = {
    online: option<bool>,
  }
  and response_myLocal = {
    meta: response_myLocal_meta,
    name: option<string>,
  }
  type response = {
    myLocal: option<response_myLocal>,
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
  @live
  type wrapResponseRaw
  @live
  let wrapResponseConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{}`
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
    json`{}`
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

type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>


%%private(let makeNode = (rescript_graphql_node_LocalUser__id, rescript_graphql_node_LocalUser____relay_model_instance, rescript_graphql_node_UserMeta____relay_model_instance, resolverDataInjector, rescript_module_TestRelayResolverMulti_LocalUser, rescript_module_TestRelayResolverMulti_localUser, rescript_module_TestRelayResolverMulti_name, rescript_module_TestRelayResolverMulti_meta, rescript_module_TestRelayResolverMulti_online): operationType => {
  ignore(rescript_graphql_node_LocalUser__id)
  ignore(rescript_graphql_node_LocalUser____relay_model_instance)
  ignore(rescript_graphql_node_UserMeta____relay_model_instance)
  ignore(resolverDataInjector)
  ignore(rescript_module_TestRelayResolverMulti_LocalUser)
  ignore(rescript_module_TestRelayResolverMulti_localUser)
  ignore(rescript_module_TestRelayResolverMulti_name)
  ignore(rescript_module_TestRelayResolverMulti_meta)
  ignore(rescript_module_TestRelayResolverMulti_online)
  %raw(json`(function(){
var v0 = {
  "args": null,
  "kind": "FragmentSpread",
  "name": "LocalUser____relay_model_instance"
},
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v2 = {
  "kind": "InlineFragment",
  "selections": [
    {
      "name": "__relay_model_instance",
      "args": null,
      "fragment": {
        "kind": "InlineFragment",
        "selections": [
          (v1/*: any*/)
        ],
        "type": "LocalUser",
        "abstractKey": null
      },
      "kind": "RelayResolver",
      "storageKey": null,
      "isOutputType": false
    }
  ],
  "type": "LocalUser",
  "abstractKey": null
};
return {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": {
      "hasClientEdges": true
    },
    "name": "TestModelResolverAliasedQuery",
    "selections": [
      {
        "kind": "ClientEdgeToClientObject",
        "concreteType": "LocalUser",
        "modelResolvers": {
          "LocalUser": {
            "alias": null,
            "args": null,
            "fragment": {
              "args": null,
              "kind": "FragmentSpread",
              "name": "LocalUser__id"
            },
            "kind": "RelayResolver",
            "name": "myLocal",
            "resolverModule": resolverDataInjector(rescript_graphql_node_LocalUser__id, rescript_module_TestRelayResolverMulti_LocalUser, 'id', true),
            "path": "myLocal.__relay_model_instance"
          }
        },
        "backingField": {
          "alias": "myLocal",
          "args": null,
          "fragment": null,
          "kind": "RelayResolver",
          "name": "localUser",
          "resolverModule": rescript_module_TestRelayResolverMulti_localUser,
          "path": "myLocal"
        },
        "linkedField": {
          "alias": "myLocal",
          "args": null,
          "concreteType": "LocalUser",
          "kind": "LinkedField",
          "name": "localUser",
          "plural": false,
          "selections": [
            {
              "alias": null,
              "args": null,
              "fragment": (v0/*: any*/),
              "kind": "RelayResolver",
              "name": "name",
              "resolverModule": resolverDataInjector(rescript_graphql_node_LocalUser____relay_model_instance, rescript_module_TestRelayResolverMulti_name, '__relay_model_instance', true),
              "path": "myLocal.name"
            },
            {
              "kind": "RequiredField",
              "field": {
                "kind": "ClientEdgeToClientObject",
                "concreteType": "UserMeta",
                "modelResolvers": null,
                "backingField": {
                  "alias": null,
                  "args": null,
                  "fragment": (v0/*: any*/),
                  "kind": "RelayResolver",
                  "name": "meta",
                  "resolverModule": resolverDataInjector(rescript_graphql_node_LocalUser____relay_model_instance, rescript_module_TestRelayResolverMulti_meta, '__relay_model_instance', true),
                  "path": "myLocal.meta",
                  "normalizationInfo": {
                    "kind": "WeakModel",
                    "concreteType": "UserMeta",
                    "plural": false
                  }
                },
                "linkedField": {
                  "alias": null,
                  "args": null,
                  "concreteType": "UserMeta",
                  "kind": "LinkedField",
                  "name": "meta",
                  "plural": false,
                  "selections": [
                    {
                      "alias": null,
                      "args": null,
                      "fragment": {
                        "args": null,
                        "kind": "FragmentSpread",
                        "name": "UserMeta____relay_model_instance"
                      },
                      "kind": "RelayResolver",
                      "name": "online",
                      "resolverModule": resolverDataInjector(rescript_graphql_node_UserMeta____relay_model_instance, rescript_module_TestRelayResolverMulti_online, '__relay_model_instance', true),
                      "path": "myLocal.meta.online"
                    }
                  ],
                  "storageKey": null
                }
              },
              "action": "NONE"
            }
          ],
          "storageKey": null
        }
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "TestModelResolverAliasedQuery",
    "selections": [
      {
        "kind": "ClientEdgeToClientObject",
        "backingField": {
          "name": "localUser",
          "args": null,
          "fragment": null,
          "kind": "RelayResolver",
          "storageKey": null,
          "isOutputType": false
        },
        "linkedField": {
          "alias": "myLocal",
          "args": null,
          "concreteType": "LocalUser",
          "kind": "LinkedField",
          "name": "localUser",
          "plural": false,
          "selections": [
            {
              "name": "name",
              "args": null,
              "fragment": (v2/*: any*/),
              "kind": "RelayResolver",
              "storageKey": null,
              "isOutputType": true
            },
            {
              "kind": "ClientEdgeToClientObject",
              "backingField": {
                "name": "meta",
                "args": null,
                "fragment": (v2/*: any*/),
                "kind": "RelayResolver",
                "storageKey": null,
                "isOutputType": true
              },
              "linkedField": {
                "alias": null,
                "args": null,
                "concreteType": "UserMeta",
                "kind": "LinkedField",
                "name": "meta",
                "plural": false,
                "selections": [
                  {
                    "name": "online",
                    "args": null,
                    "fragment": {
                      "kind": "InlineFragment",
                      "selections": [
                        {
                          "alias": null,
                          "args": null,
                          "kind": "ScalarField",
                          "name": "__relay_model_instance",
                          "storageKey": null
                        }
                      ],
                      "type": "UserMeta",
                      "abstractKey": null
                    },
                    "kind": "RelayResolver",
                    "storageKey": null,
                    "isOutputType": true
                  }
                ],
                "storageKey": null
              }
            },
            (v1/*: any*/)
          ],
          "storageKey": null
        }
      }
    ]
  },
  "params": {
    "cacheID": "30dd44ce0559e69a41cb47b9c70e13d8",
    "id": null,
    "metadata": {},
    "name": "TestModelResolverAliasedQuery",
    "operationKind": "query",
    "text": null
  }
};
})()`)
})
let node: operationType = makeNode(LocalUser__id_graphql.node, LocalUser____relay_model_instance_graphql.node, UserMeta____relay_model_instance_graphql.node, RescriptRelay.resolverDataInjector, TestRelayResolverMulti.localUser, TestRelayResolverMulti.localUser, TestRelayResolverMulti.name, TestRelayResolverMulti.meta, TestRelayResolverMulti.online)

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
