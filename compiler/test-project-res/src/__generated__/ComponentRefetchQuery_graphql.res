/* @sourceLoc Component.res */
/* @generated */
%%raw("/* @generated */")
type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>
type queryRef

module Types = {
  @@ocaml.warning("-30")
  
  type rec response_node = {
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #Component_node]>
  }
  type response = {
    node: option<response_node>,
  }
  type rawResponse = response
  type refetchVariables = {
    id: option<string>,
  }
  let makeRefetchVariables = (
    ~id=?,
    ()
  ): refetchVariables => {
    id: id
  }
  
  type variables = {
    id: string,
  }
}

module Internal = {
  type wrapResponseRaw
  let wrapResponseConverter: 
    Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = 
    %raw(
      json`{"__root":{"node":{"f":"","n":""}}}`
    )
  
  let wrapResponseConverterMap = ()
  let convertWrapResponse = v => v->RescriptRelay.convertObj(
    wrapResponseConverter, 
    wrapResponseConverterMap, 
    Js.null
  )
  type responseRaw
  let responseConverter: 
    Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = 
    %raw(
      json`{"__root":{"node":{"f":"","n":""}}}`
    )
  
  let responseConverterMap = ()
  let convertResponse = v => v->RescriptRelay.convertObj(
    responseConverter, 
    responseConverterMap, 
    Js.undefined
  )
  type wrapRawResponseRaw = wrapResponseRaw
  let convertWrapRawResponse = convertWrapResponse
  type rawResponseRaw = responseRaw
  let convertRawResponse = convertResponse
  let variablesConverter: 
    Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = 
    %raw(
      json`{}`
    )
  
  let variablesConverterMap = ()
  let convertVariables = v => v->RescriptRelay.convertObj(
    variablesConverter, 
    variablesConverterMap, 
    Js.undefined
  )
}


module Utils = {
  @@ocaml.warning("-33")
  open Types
  let makeVariables = (
    ~id
  ): variables => {
    id: id
  }
}


