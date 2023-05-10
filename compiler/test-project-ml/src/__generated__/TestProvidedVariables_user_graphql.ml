(* @sourceLoc Test_providedVariables.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type fragment = {
    firstName: string;
    onlineStatus: RelaySchemaAssets_graphql.enum_OnlineStatus option;
  }
end

module Internal = struct
  type fragmentRaw
  let fragmentConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{}|json}
  ]
  let fragmentConverterMap = ()
  let convertFragment v = RescriptRelay.convertObj v 
    fragmentConverter 
    fragmentConverterMap 
    Js.undefined
  end

type t
type fragmentRef
external getFragmentRef:
  [> | `TestProvidedVariables_user] RescriptRelay.fragmentRefs -> fragmentRef = "%identity"

module Utils = struct
  [@@@ocaml.warning "-33"]
  open Types
  external onlineStatus_toString: RelaySchemaAssets_graphql.enum_OnlineStatus -> string = "%identity"
  external onlineStatus_input_toString: RelaySchemaAssets_graphql.enum_OnlineStatus_input -> string = "%identity"
  let onlineStatus_decode (enum: RelaySchemaAssets_graphql.enum_OnlineStatus): RelaySchemaAssets_graphql.enum_OnlineStatus_input option =
    (match enum with
      | #RelaySchemaAssets_graphql.enum_OnlineStatus_input as valid -> Some(valid)
      | _ -> None
    )
    let onlineStatus_fromString (str: string): RelaySchemaAssets_graphql.enum_OnlineStatus_input option =
    onlineStatus_decode (Obj.magic str)
  end

type relayOperationNode
type operationType = relayOperationNode RescriptRelay.fragmentNode


let node: operationType = [%bs.raw {json| {
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
} |json}]

