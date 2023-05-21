(* @sourceLoc Test_mutation.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type fragment = {
    firstName: string;
    id: string [@live];
    lastName: string;
    onlineStatus: RelaySchemaAssets_graphql.enum_OnlineStatus option;
  }
end

module Internal = struct
  type fragmentRaw
  let fragmentConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{}|json}
  ]
  let fragmentConverterMap = ()
  let convertFragment v = Melange_relay.convertObj v 
    fragmentConverter 
    fragmentConverterMap 
    Js.undefined
  end

type t
type fragmentRef
external getFragmentRef:
  [> | `TestMutationInline_user] Melange_relay.fragmentRefs -> fragmentRef = "%identity"

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
type operationType = relayOperationNode Melange_relay.fragmentNode


let node: operationType = [%bs.raw {json| {
  "kind": "InlineDataFragment",
  "name": "TestMutationInline_user"
} |json}]

