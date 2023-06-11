/* @sourceLoc Test_customScalars.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  type response_member = 
    | User(
      {
        @live __typename: [ | #User],
        createdAt: SomeModule.Datetime.t,
      }
    )
    | @as("__unselected") UnselectedUnionMember(string)

  type rec response_loggedInUser_friends = {
    createdAt: SomeModule.Datetime.t,
  }
  and response_loggedInUser = {
    createdAt: SomeModule.Datetime.t,
    friends: array<response_loggedInUser_friends>,
  }
  type response = {
    loggedInUser: response_loggedInUser,
    member: option<response_member>,
  }
  @live
  type rawResponse = response
  @live
  type variables = {
    beforeDate?: SomeModule.Datetime.t,
  }
  @live
  type refetchVariables = {
    beforeDate: option<option<SomeModule.Datetime.t>>,
  }
  @live let makeRefetchVariables = (
    ~beforeDate=?,
  ): refetchVariables => {
    beforeDate: beforeDate
  }

}

@live
let unwrap_response_member: response_member => response_member = RescriptRelay_Internal.unwrapUnion
@live
let wrap_response_member: response_member => response_member = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  let variablesConverter: Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = %raw(
    json`{"__root":{"beforeDate":{"c":"SomeModule.Datetime"}}}`
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
    json`{"__root":{"member_User_createdAt":{"c":"SomeModule.Datetime"},"member":{"u":"response_member"},"loggedInUser_friends_createdAt":{"c":"SomeModule.Datetime"},"loggedInUser_createdAt":{"c":"SomeModule.Datetime"}}}`
  )
  @live
  let wrapResponseConverterMap = {
    "SomeModule.Datetime": SomeModule.Datetime.serialize,
    "response_member": wrap_response_member,
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
    json`{"__root":{"member_User_createdAt":{"c":"SomeModule.Datetime"},"member":{"u":"response_member"},"loggedInUser_friends_createdAt":{"c":"SomeModule.Datetime"},"loggedInUser_createdAt":{"c":"SomeModule.Datetime"}}}`
  )
  @live
  let responseConverterMap = {
    "SomeModule.Datetime": SomeModule.Datetime.parse,
    "response_member": unwrap_response_member,
  }
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

type queryRef

module Utils = {
  @@warning("-33")
  open Types
}

type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json` (function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "beforeDate"
  }
],
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "createdAt",
  "storageKey": null
},
v2 = [
  {
    "kind": "Variable",
    "name": "beforeDate",
    "variableName": "beforeDate"
  }
],
v3 = [
  (v1/*: any*/)
],
v4 = [
  {
    "kind": "Literal",
    "name": "id",
    "value": "user-1"
  }
],
v5 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
  "storageKey": null
},
v6 = {
  "kind": "InlineFragment",
  "selections": (v3/*: any*/),
  "type": "User",
  "abstractKey": null
},
v7 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v8 = [
  (v7/*: any*/)
];
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": null,
    "name": "TestCustomScalarsQuery",
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "loggedInUser",
        "plural": false,
        "selections": [
          (v1/*: any*/),
          {
            "alias": null,
            "args": (v2/*: any*/),
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "friends",
            "plural": true,
            "selections": (v3/*: any*/),
            "storageKey": null
          }
        ],
        "storageKey": null
      },
      {
        "alias": null,
        "args": (v4/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "member",
        "plural": false,
        "selections": [
          (v5/*: any*/),
          (v6/*: any*/)
        ],
        "storageKey": "member(id:\"user-1\")"
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "TestCustomScalarsQuery",
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "loggedInUser",
        "plural": false,
        "selections": [
          (v1/*: any*/),
          {
            "alias": null,
            "args": (v2/*: any*/),
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "friends",
            "plural": true,
            "selections": [
              (v1/*: any*/),
              (v7/*: any*/)
            ],
            "storageKey": null
          },
          (v7/*: any*/)
        ],
        "storageKey": null
      },
      {
        "alias": null,
        "args": (v4/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "member",
        "plural": false,
        "selections": [
          (v5/*: any*/),
          (v6/*: any*/),
          {
            "kind": "InlineFragment",
            "selections": (v8/*: any*/),
            "type": "Node",
            "abstractKey": "__isNode"
          },
          {
            "kind": "InlineFragment",
            "selections": (v8/*: any*/),
            "type": "person",
            "abstractKey": null
          }
        ],
        "storageKey": "member(id:\"user-1\")"
      }
    ]
  },
  "params": {
    "cacheID": "b14b357212de86a79ffcdd7bf57fa972",
    "id": null,
    "metadata": {},
    "name": "TestCustomScalarsQuery",
    "operationKind": "query",
    "text": "query TestCustomScalarsQuery(\n  $beforeDate: Datetime\n) {\n  loggedInUser {\n    createdAt\n    friends(beforeDate: $beforeDate) {\n      createdAt\n      id\n    }\n    id\n  }\n  member(id: \"user-1\") {\n    __typename\n    ... on User {\n      createdAt\n    }\n    ... on Node {\n      __isNode: __typename\n      __typename\n      id\n    }\n    ... on person {\n      id\n    }\n  }\n}\n"
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
