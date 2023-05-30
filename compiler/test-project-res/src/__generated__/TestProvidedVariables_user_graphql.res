/* @sourceLoc Test_providedVariables.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@ocaml.warning("-30")

  type fragment = {
    firstName: string,
    onlineStatus: option<RelaySchemaAssets_graphql.enum_OnlineStatus>,
  }
}

module Internal = {
  @live
  type fragmentRaw
  @live
  let fragmentConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{}`
  )
  @live
  let fragmentConverterMap = ()
  @live
  let convertFragment = v => v->RescriptRelay.convertObj(
    fragmentConverter,
    fragmentConverterMap,
    Js.undefined
  )
}

type t
type fragmentRef
external getFragmentRef:
  RescriptRelay.fragmentRefs<[> | #TestProvidedVariables_user]> => fragmentRef = "%identity"

module Utils = {
  @@ocaml.warning("-33")
  open Types
  @live
  external onlineStatus_toString: RelaySchemaAssets_graphql.enum_OnlineStatus => string = "%identity"
  @live
  external onlineStatus_input_toString: RelaySchemaAssets_graphql.enum_OnlineStatus_input => string = "%identity"
  @live
  let onlineStatus_decode = (enum: RelaySchemaAssets_graphql.enum_OnlineStatus): option<RelaySchemaAssets_graphql.enum_OnlineStatus_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let onlineStatus_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_OnlineStatus_input> => {
    onlineStatus_decode(Obj.magic(str))
  }
}

type relayOperationNode
type operationType = RescriptRelay.fragmentNode<relayOperationNode>


let node: operationType = %raw(json` {
  "argumentDefinitions": [
    {
      "kind": "RootArgument",
      "name": "__relay_internal__pv__TestProvidedVariablesBool"
    },
    {
      "kind": "RootArgument",
      "name": "__relay_internal__pv__TestProvidedVariablesDatetime"
    },
    {
      "kind": "RootArgument",
      "name": "__relay_internal__pv__TestProvidedVariablesDatetimes"
    },
    {
      "kind": "RootArgument",
      "name": "__relay_internal__pv__TestProvidedVariablesFloat"
    },
    {
      "kind": "RootArgument",
      "name": "__relay_internal__pv__TestProvidedVariablesID"
    },
    {
      "kind": "RootArgument",
      "name": "__relay_internal__pv__TestProvidedVariablesInputB"
    },
    {
      "kind": "RootArgument",
      "name": "__relay_internal__pv__TestProvidedVariablesInt"
    },
    {
      "kind": "RootArgument",
      "name": "__relay_internal__pv__TestProvidedVariablesSomeInput"
    },
    {
      "kind": "RootArgument",
      "name": "__relay_internal__pv__TestProvidedVariablesStr"
    }
  ],
  "kind": "Fragment",
  "metadata": null,
  "name": "TestProvidedVariables_user",
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
    }
  ],
  "type": "User",
  "abstractKey": null
} `)

