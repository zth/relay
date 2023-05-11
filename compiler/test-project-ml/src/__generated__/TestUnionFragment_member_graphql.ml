(* @sourceLoc Test_unionFragment.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type fragment_Group = {
    __typename: [ | `Group] [@live];
    name: string;
  }
  and fragment_User = {
    __typename: [ | `User] [@live];
    firstName: string;
    onlineStatus: RelaySchemaAssets_graphql.enum_OnlineStatus option;
    fragmentRefs: [ | `TestUnionFragmentUser_user] RescriptRelay.fragmentRefs;
  }
  type fragment = [
    | `Group of fragment_Group
    | `User of fragment_User
    | `UnselectedUnionMember of string
  ]

end

let unwrap_fragment: < __typename: string > Js.t -> [
  | `Group of Types.fragment_Group
  | `User of Types.fragment_User
  | `UnselectedUnionMember of string
] = fun u -> match u##__typename with 
  | "Group" -> `Group (Obj.magic u)
  | "User" -> `User (Obj.magic u)
  | v -> `UnselectedUnionMember v
let wrap_fragment: [
  | `Group of Types.fragment_Group
  | `User of Types.fragment_User
  | `UnselectedUnionMember of string
] -> < __typename: string > Js.t = function 
  | `Group(v) -> Obj.magic v
  | `User(v) -> Obj.magic v
  | `UnselectedUnionMember v -> [%bs.obj { __typename = v }]
module Internal = struct
  type fragmentRaw
  let fragmentConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%bs.raw 
    {json|{"__root":{"User":{"f":""},"":{"u":"fragment"}}}|json}
  ]
  let fragmentConverterMap = let o = Js.Dict.empty () in 
    Js.Dict.set o "fragment" (Obj.magic unwrap_fragment : unit);
  o
  let convertFragment v = RescriptRelay.convertObj v 
    fragmentConverter 
    fragmentConverterMap 
    Js.undefined
  end

type t
type fragmentRef
external getFragmentRef:
  [> | `TestUnionFragment_member] RescriptRelay.fragmentRefs -> fragmentRef = "%identity"

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
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": null,
  "name": "TestUnionFragment_member",
  "selections": [
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "__typename",
      "storageKey": null
    },
    {
      "kind": "InlineFragment",
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
          "args": null,
          "kind": "ScalarField",
          "name": "onlineStatus",
          "storageKey": null
        },
        {
          "args": null,
          "kind": "FragmentSpread",
          "name": "TestUnionFragmentUser_user"
        }
      ],
      "type": "User",
      "abstractKey": null
    },
    {
      "kind": "InlineFragment",
      "selections": [
        {
          "alias": null,
          "args": null,
          "kind": "ScalarField",
          "name": "name",
          "storageKey": null
        }
      ],
      "type": "Group",
      "abstractKey": null
    }
  ],
  "type": "Member",
  "abstractKey": "__isMember"
} |json}]

