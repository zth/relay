/* @sourceLoc Test_fragment.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type fragment = {
    greeting: option<string>,
    lastName: string,
  }
  type fragment_useOpt = fragment
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
  RescriptRelay.fragmentRefs<[> | #TestFragment_sub_user]> => fragmentRef = "%identity"

module Utils = {
  @@warning("-33")
  open Types
}

type relayOperationNode
type operationType = RescriptRelay.fragmentNode<relayOperationNode>


%%private(let makeNode = (resolverDataInjector, rescript_module_TestRelayResolver_greeting): operationType => {
  ignore(resolverDataInjector)
  ignore(rescript_module_TestRelayResolver_greeting)
  %raw(json`{
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
      "resolverModule": rescript_module_TestRelayResolver_greeting,
      "path": "greeting"
    }
  ],
  "type": "User",
  "abstractKey": null
}`)
})
let node: operationType = makeNode(RescriptRelay.resolverDataInjector, TestRelayResolver.greeting)

