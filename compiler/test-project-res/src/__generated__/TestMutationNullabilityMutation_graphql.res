/* @sourceLoc Test_mutation.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@ocaml.warning("-30")

  @live type someInput = RelaySchemaAssets_graphql.input_SomeInput_nullable
  @live
  type rec response_setOnlineStatus_user_friendsConnection = {
    @live __typename: [ | #UserConnection],
  }
  @live
  and response_setOnlineStatus_user = {
    friendsConnection: response_setOnlineStatus_user_friendsConnection,
  }
  @live
  and response_setOnlineStatus = {
    user: option<response_setOnlineStatus_user>,
  }
  @live
  type response = {
    setOnlineStatus: option<response_setOnlineStatus>,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    datetime?: Js.Nullable.t<SomeModule.Datetime.t>,
    onlineStatus: [
      | #Idle
      | #Offline
      | #Online
    ],
    recursive?: Js.Nullable.t<someInput>,
  }
}

module Internal = {
  @live
  let variablesConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"someInput":{"recursive":{"r":"someInput"},"datetime":{"c":"SomeModule.Datetime"}},"__root":{"recursive":{"r":"someInput"},"datetime":{"c":"SomeModule.Datetime"}}}`
  )
  @live
  let variablesConverterMap = {
    "SomeModule.Datetime": SomeModule.Datetime.serialize,
  }
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
    json`{}`
  )
  @live
  let wrapResponseConverterMap = ()
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
    json`{}`
  )
  @live
  let responseConverterMap = ()
  @live
  let convertResponse = v => v->RescriptRelay.convertObj(
    responseConverter,
    responseConverterMap,
    Js.undefined
  )
  type wrapRawResponseRaw = wrapResponseRaw
  @live
  let convertWrapRawResponse = convertWrapResponse
  type rawResponseRaw = responseRaw
  @live
  let convertRawResponse = convertResponse
}
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
  @live @obj external make_someInput: (
    ~bool: bool=?,
    ~datetime: SomeModule.Datetime.t=?,
    ~float: float=?,
    ~int: int=?,
    ~_private: bool=?,
    ~recursive: someInput=?,
    ~str: string=?,
    unit
  ) => someInput = ""


  @live @obj external makeVariables: (
    ~datetime: SomeModule.Datetime.t=?,
    ~onlineStatus: [
      | #Idle
      | #Offline
      | #Online
    ],
    ~recursive: someInput=?,
    unit
  ) => variables = ""


}

type relayOperationNode
type operationType = RescriptRelay.mutationNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "datetime"
},
v1 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "onlineStatus"
},
v2 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "recursive"
},
v3 = [
  {
    "kind": "Variable",
    "name": "onlineStatus",
    "variableName": "onlineStatus"
  }
],
v4 = {
  "alias": null,
  "args": [
    {
      "fields": [
        {
          "kind": "Literal",
          "name": "bool",
          "value": false
        },
        {
          "kind": "Variable",
          "name": "datetime",
          "variableName": "datetime"
        },
        {
          "kind": "Literal",
          "name": "float",
          "value": 12.2
        },
        {
          "kind": "Literal",
          "name": "int",
          "value": 64
        },
        {
          "kind": "Variable",
          "name": "recursive",
          "variableName": "recursive"
        },
        {
          "kind": "Literal",
          "name": "str",
          "value": "123"
        }
      ],
      "kind": "ObjectValue",
      "name": "objTest"
    },
    {
      "items": [
        {
          "kind": "Literal",
          "name": "statuses.0",
          "value": "Idle"
        },
        {
          "kind": "Variable",
          "name": "statuses.1",
          "variableName": "onlineStatus"
        }
      ],
      "kind": "ListValue",
      "name": "statuses"
    }
  ],
  "concreteType": "UserConnection",
  "kind": "LinkedField",
  "name": "friendsConnection",
  "plural": false,
  "selections": [
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "__typename",
      "storageKey": null
    }
  ],
  "storageKey": null
};
return {
  "fragment": {
    "argumentDefinitions": [
      (v0/*: any*/),
      (v1/*: any*/),
      (v2/*: any*/)
    ],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestMutationNullabilityMutation",
    "selections": [
      {
        "alias": null,
        "args": (v3/*: any*/),
        "concreteType": "SetOnlineStatusPayload",
        "kind": "LinkedField",
        "name": "setOnlineStatus",
        "plural": false,
        "selections": [
          {
            "alias": null,
            "args": null,
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "user",
            "plural": false,
            "selections": [
              (v4/*: any*/)
            ],
            "storageKey": null
          }
        ],
        "storageKey": null
      }
    ],
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [
      (v1/*: any*/),
      (v0/*: any*/),
      (v2/*: any*/)
    ],
    "kind": "Operation",
    "name": "TestMutationNullabilityMutation",
    "selections": [
      {
        "alias": null,
        "args": (v3/*: any*/),
        "concreteType": "SetOnlineStatusPayload",
        "kind": "LinkedField",
        "name": "setOnlineStatus",
        "plural": false,
        "selections": [
          {
            "alias": null,
            "args": null,
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "user",
            "plural": false,
            "selections": [
              (v4/*: any*/),
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
        ],
        "storageKey": null
      }
    ]
  },
  "params": {
    "cacheID": "8184be32c86e88c46d5ad837d9247590",
    "id": null,
    "metadata": {},
    "name": "TestMutationNullabilityMutation",
    "operationKind": "mutation",
    "text": "mutation TestMutationNullabilityMutation(\n  $onlineStatus: OnlineStatus!\n  $datetime: Datetime\n  $recursive: SomeInput\n) {\n  setOnlineStatus(onlineStatus: $onlineStatus) {\n    user {\n      friendsConnection(statuses: [Idle, $onlineStatus], objTest: {str: \"123\", bool: false, float: 12.2, int: 64, datetime: $datetime, recursive: $recursive}) {\n        __typename\n      }\n      id\n    }\n  }\n}\n"
  }
};
})() `)


