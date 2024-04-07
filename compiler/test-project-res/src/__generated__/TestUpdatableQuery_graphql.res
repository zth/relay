/* @sourceLoc Test_updatableQuery.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type rec response_user = {
    mutable firstName: string,
  }
  type response = {
    user: Js.Nullable.t<response_user>,
  }
  @live
  type variables = {
    @live id: string,
  }
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
}


type relayOperationNode

type updatableData = {updatableData: Types.response}

@send external readUpdatableQuery: (RescriptRelay.RecordSourceSelectorProxy.t, ~node: RescriptRelay.queryNode<relayOperationNode>, ~variables: Types.variables) => updatableData = "readUpdatableQuery"
module Utils = {
  @@warning("-33")
  open Types
}
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "id"
  }
],
v1 = [
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
];
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": null,
    "name": "TestUpdatableQuery",
    "selections": (v1/*: any*/),
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "TestUpdatableQuery",
    "selections": (v1/*: any*/)
  },
  "params": {
    "cacheID": "9347097cca4f285c18fcc402a649e445",
    "id": null,
    "metadata": {},
    "name": "TestUpdatableQuery",
    "operationKind": "query",
    "text": null
  }
};
})() `)


let readUpdatableQuery = (store, variables) => store->readUpdatableQuery(~node, ~variables=Internal.convertVariables(variables))

