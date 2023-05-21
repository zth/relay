(* @sourceLoc Test_fragment.ml *)
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
    isOnline: bool;
    lastName: string;
  }
  type fragment_t = [
    | `Group of fragment_Group
    | `User of fragment_User
    | `UnselectedUnionMember of string
  ]

  type fragment = fragment_t option
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
    {json|{"__root":{"":{"u":"fragment"}}}|json}
  ]
  let fragmentConverterMap = let o = Js.Dict.empty () in 
    Js.Dict.set o "fragment" (Obj.magic unwrap_fragment : unit);
  o
  let convertFragment v = Melange_relay.convertObj v 
    fragmentConverter 
    fragmentConverterMap 
    Js.undefined
  end

type t
type fragmentRef
external getFragmentRef:
  [> | `TestFragment_requiredUnion_member] Melange_relay.fragmentRefs -> fragmentRef = "%identity"

module Utils = struct
  [@@@ocaml.warning "-33"]
  open Types
end

type relayOperationNode
type operationType = relayOperationNode Melange_relay.fragmentNode


let node: operationType = [%bs.raw {json| (function(){
var v0 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
  "storageKey": null
};
return {
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": null,
  "name": "TestFragment_requiredUnion_member",
  "selections": [
    (v0/*: any*/),
    {
      "kind": "InlineFragment",
      "selections": [
        (v0/*: any*/),
        {
          "kind": "RequiredField",
          "field": {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "isOnline",
            "storageKey": null
          },
          "action": "NONE",
          "path": "isOnline"
        },
        {
          "alias": null,
          "args": null,
          "kind": "ScalarField",
          "name": "lastName",
          "storageKey": null
        },
        {
          "alias": null,
          "args": null,
          "kind": "ScalarField",
          "name": "firstName",
          "storageKey": null
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
};
})() |json}]

