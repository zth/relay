/* @sourceLoc Component.res */
/* @generated */
%%raw("/* @generated */")
type relayOperationNode
type operationType = RescriptRelay.fragmentNode<relayOperationNode>

module Types = {
  @@ocaml.warning("-30")
  
  type fragment = {
    id: string,
  }
}

module Internal = {
  type fragmentRaw
  let fragmentConverter: 
    Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = 
    %raw(
      json`{}`
    )
  
  let fragmentConverterMap = ()
  let convertFragment = v => v->RescriptRelay.convertObj(
    fragmentConverter, 
    fragmentConverterMap, 
    Js.undefined
  )
}
type t
type fragmentRef
external getFragmentRef:
  RescriptRelay.fragmentRefs<[> | #Component_node]> => fragmentRef = "%identity"


module Utils = {

}


let node: operationType = %raw(json`{
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": {
    "refetch": {
      "connection": null,
      "fragmentPathInResult": [
        "node"
      ],
      "operation": node_ComponentRefetchQuery,
      "identifierField": "id"
    }
  },
  "name": "Component_node",
  "selections": [
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "id",
      "storageKey": null
    }
  ],
  "type": "Node",
  "abstractKey": "__isNode"
}`)
