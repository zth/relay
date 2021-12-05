/* @sourceLoc Component.res */
/* @generated */
%%raw("/* @generated */")

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


