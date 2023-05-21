(* @sourceLoc Test_fragment.ml *)
(* @generated *)
[%%bs.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type fragment = {
    greeting: TestRelayResolver.t option;
    lastName: string;
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
  [> | `TestFragment_sub_user] Melange_relay.fragmentRefs -> fragmentRef = "%identity"

module Utils = struct
  [@@@ocaml.warning "-33"]
  open Types
end

type relayOperationNode
type operationType = relayOperationNode Melange_relay.fragmentNode


[%%private let makeNode rescript_module_TestRelayResolver: operationType = 
  ignore rescript_module_TestRelayResolver;
  [%raw {json|{
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": null,
  "name": "TestFragment_sub_user",
  "selections": [
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
      "fragment": {
        "args": null,
        "kind": "FragmentSpread",
        "name": "TestRelayResolver"
      },
      "kind": "RelayResolver",
      "name": "greeting",
      "resolverModule": rescript_module_TestRelayResolver,
      "path": "greeting"
    }
  ],
  "type": "User",
  "abstractKey": null
}|json}]
]
let node: operationType = makeNode TestRelayResolver.default

