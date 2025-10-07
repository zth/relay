/* @sourceLoc Test_updatableQuery.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type rec response_user = {
    mutable firstName: string,
  }
  type response = {
    user: Nullable.t<response_user>,
  }
  @live
  type variables = {
    @live id: string,
  }
}


type queryRef

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


type relayOperationNode

type updatableData = {updatableData: Types.response}

@send external readUpdatableQuery: (RescriptRelay.RecordSourceSelectorProxy.t, ~node: RescriptRelay.queryNode<relayOperationNode>, ~variables: Types.variables) => updatableData = "readUpdatableQuery"
module Utils = {
  @@warning("-33")
  open Types
}
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json` {
  "fragment": {
    "argumentDefinitions": [
      {
        "defaultValue": null,
        "kind": "LocalArgument",
        "name": "id"
      }
    ],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestUpdatableQuery",
    "selections": [
      {
        "alias": null,
        "args": [
          {
            "kind": "Variable",
            "name": "id",
            "variableName": "id"
          }
        ],
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "user",
        "plural": false,
        "selections": [
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "firstName",
            "storageKey": null
          }
        ],
        "storageKey": null
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "UpdatableQuery"
} `)


let readUpdatableQuery = (store, variables: Types.variables) => store->readUpdatableQuery(~node, ~variables=Internal.convertVariables(variables))

