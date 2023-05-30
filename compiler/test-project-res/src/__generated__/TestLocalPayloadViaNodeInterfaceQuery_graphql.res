/* @sourceLoc Test_localPayload.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@ocaml.warning("-30")

  type rec response_node_User = {
    @live __typename: [ | #User],
    avatarUrl: option<string>,
    firstName: string,
    onlineStatus: option<RelaySchemaAssets_graphql.enum_OnlineStatus>,
  }
  @live
  and rawResponse_node_User = {
    @live __typename: [ | #User],
    avatarUrl: option<string>,
    firstName: string,
    @live id: string,
    onlineStatus: option<[
      | #Idle
      | #Offline
      | #Online
    ]>,
  }
  and response_node = [
    | #User(response_node_User)
    | #UnselectedUnionMember(string)
  ]

  and rawResponse_node = [
    | #User(rawResponse_node_User)
    | #UnselectedUnionMember(string)
  ]

  type response = {
    node: option<response_node>,
  }
  @live
  type rawResponse = {
    node: option<rawResponse_node>,
  }
  @live
  type variables = {
    @live id: string,
  }
  @live
  type refetchVariables = {
    @live id: option<string>,
  }
  @live let makeRefetchVariables = (
    ~id=?,
    ()
  ): refetchVariables => {
    id: id
  }

}

@live
let unwrap_response_node: {. "__typename": string } => [
  | #User(Types.response_node_User)
  | #UnselectedUnionMember(string)
] = u => switch u["__typename"] {
  | "User" => #User(u->Obj.magic)
  | v => #UnselectedUnionMember(v)
}

@live
let wrap_response_node: [
  | #User(Types.response_node_User)
  | #UnselectedUnionMember(string)
] => {. "__typename": string } = v => switch v {
  | #User(v) => v->Obj.magic
  | #UnselectedUnionMember(v) => {"__typename": v}
}
@live
let unwrap_rawResponse_node: {. "__typename": string } => [
  | #User(Types.rawResponse_node_User)
  | #UnselectedUnionMember(string)
] = u => switch u["__typename"] {
  | "User" => #User(u->Obj.magic)
  | v => #UnselectedUnionMember(v)
}

@live
let wrap_rawResponse_node: [
  | #User(Types.rawResponse_node_User)
  | #UnselectedUnionMember(string)
] => {. "__typename": string } = v => switch v {
  | #User(v) => v->Obj.magic
  | #UnselectedUnionMember(v) => {"__typename": v}
}
module Internal = {
  @live
  let variablesConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{}`
  )
  @live
  let variablesConverterMap = ()
  @live
  let convertVariables = v => v->RescriptRelay.convertObj(
    variablesConverter,
    variablesConverterMap,
    Js.undefined
  )
  @live
  type wrapResponseRaw
  @live
  let wrapResponseConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"__root":{"node":{"u":"response_node"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "response_node": wrap_response_node,
  }
  @live
  let convertWrapResponse = v => v->RescriptRelay.convertObj(
    wrapResponseConverter,
    wrapResponseConverterMap,
    Js.null
  )
  @live
  type responseRaw
  @live
  let responseConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"__root":{"node":{"u":"response_node"}}}`
  )
  @live
  let responseConverterMap = {
    "response_node": unwrap_response_node,
  }
  @live
  let convertResponse = v => v->RescriptRelay.convertObj(
    responseConverter,
    responseConverterMap,
    Js.undefined
  )
  @live
  type wrapRawResponseRaw
  @live
  let wrapRawResponseConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"__root":{"node":{"u":"rawResponse_node"}}}`
  )
  @live
  let wrapRawResponseConverterMap = {
    "rawResponse_node": wrap_rawResponse_node,
  }
  @live
  let convertWrapRawResponse = v => v->RescriptRelay.convertObj(
    wrapRawResponseConverter,
    wrapRawResponseConverterMap,
    Js.null
  )
  @live
  type rawResponseRaw
  @live
  let rawResponseConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"__root":{"node":{"u":"rawResponse_node"}}}`
  )
  @live
  let rawResponseConverterMap = {
    "rawResponse_node": unwrap_rawResponse_node,
  }
  @live
  let convertRawResponse = v => v->RescriptRelay.convertObj(
    rawResponseConverter,
    rawResponseConverterMap,
    Js.undefined
  )
}

type queryRef

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
      | #...RelaySchemaAssets_graphql.enum_OnlineStatus_input as valid => Some(valid)
      | _ => None
    }
  }
  @live
  let onlineStatus_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_OnlineStatus_input> => {
    onlineStatus_decode(Obj.magic(str))
  }
  @live @obj external makeVariables: (
    ~id: string,
  ) => variables = ""


}

type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "id"
  }
],
v1 = [
  {
    "kind": "Variable",
    "name": "id",
    "variableName": "id"
  }
],
v2 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
  "storageKey": null
},
v3 = {
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
      "name": "avatarUrl",
      "storageKey": null
    },
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "onlineStatus",
      "storageKey": null
    }
  ],
  "type": "User",
  "abstractKey": null
};
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": null,
    "name": "TestLocalPayloadViaNodeInterfaceQuery",
    "selections": [
      {
        "alias": null,
        "args": (v1/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "node",
        "plural": false,
        "selections": [
          (v2/*: any*/),
          (v3/*: any*/)
        ],
        "storageKey": null
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "TestLocalPayloadViaNodeInterfaceQuery",
    "selections": [
      {
        "alias": null,
        "args": (v1/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "node",
        "plural": false,
        "selections": [
          (v2/*: any*/),
          (v3/*: any*/),
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "id",
            "storageKey": null
          }
        ],
        "storageKey": null
      }
    ]
  },
  "params": {
    "cacheID": "57a3671d69a0878acc900be78a50b6ed",
    "id": null,
    "metadata": {},
    "name": "TestLocalPayloadViaNodeInterfaceQuery",
    "operationKind": "query",
    "text": "query TestLocalPayloadViaNodeInterfaceQuery(\n  $id: ID!\n) {\n  node(id: $id) {\n    __typename\n    ... on User {\n      firstName\n      avatarUrl\n      onlineStatus\n    }\n    id\n  }\n}\n"
  }
};
})() `)

include RescriptRelay.MakeLoadQuery({
    type variables = Types.variables
    type loadedQueryRef = queryRef
    type response = Types.response
    type node = relayOperationNode
    let query = node
    let convertVariables = Internal.convertVariables
});
