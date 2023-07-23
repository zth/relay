(* @sourceLoc Test_mutation.ml *)
(* @generated *)
[%%mel.raw "/* @generated */"]
module Types = struct
  [@@@ocaml.warning "-30"]

  type response_addFriend_addedFriend_friends = {
    id: string [@live];
  }
  and response_addFriend_addedFriend = {
    friends: response_addFriend_addedFriend_friends array;
    id: string [@live];
  }
  and response_addFriend = {
    addedFriend: response_addFriend_addedFriend option;
  }
  and response_testIntInput1 = {
    success: bool option;
  }
  and response_testIntInput2 = {
    success: bool option;
  }
  and rawResponse_addFriend_addedFriend_friends = {
    id: string [@live];
  }
  and rawResponse_addFriend_addedFriend = {
    friends: rawResponse_addFriend_addedFriend_friends array;
    id: string [@live];
  }
  and rawResponse_addFriend = {
    addedFriend: rawResponse_addFriend_addedFriend option;
  }
  and rawResponse_testIntInput1 = {
    success: bool option;
  }
  and rawResponse_testIntInput2 = {
    success: bool option;
  }
  type response = {
    addFriend: response_addFriend option;
    testIntInput1: response_testIntInput1 option;
    testIntInput2: response_testIntInput2 option;
  }
  type rawResponse = {
    addFriend: rawResponse_addFriend option;
    testIntInput1: rawResponse_testIntInput1 option;
    testIntInput2: rawResponse_testIntInput2 option;
  }
  type variables = {
    friendId: string;
    id: int [@live];
    ids: int array;
  }
end

module Internal = struct
  let variablesConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
    {json|{}|json}
  ]
  let variablesConverterMap = ()
  let convertVariables v = Melange_relay.convertObj v 
    variablesConverter 
    variablesConverterMap 
    Js.undefined
    type wrapResponseRaw
  let wrapResponseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
    {json|{}|json}
  ]
  let wrapResponseConverterMap = ()
  let convertWrapResponse v = Melange_relay.convertObj v 
    wrapResponseConverter 
    wrapResponseConverterMap 
    Js.null
    type responseRaw
  let responseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
    {json|{}|json}
  ]
  let responseConverterMap = ()
  let convertResponse v = Melange_relay.convertObj v 
    responseConverter 
    responseConverterMap 
    Js.undefined
    type wrapRawResponseRaw
  let wrapRawResponseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
    {json|{}|json}
  ]
  let wrapRawResponseConverterMap = ()
  let convertWrapRawResponse v = Melange_relay.convertObj v 
    wrapRawResponseConverter 
    wrapRawResponseConverterMap 
    Js.null
    type rawResponseRaw
  let rawResponseConverter: string Js.Dict.t Js.Dict.t Js.Dict.t = [%mel.raw 
    {json|{}|json}
  ]
  let rawResponseConverterMap = ()
  let convertRawResponse v = Melange_relay.convertObj v 
    rawResponseConverter 
    rawResponseConverterMap 
    Js.undefined
  end
module Utils = struct
  [@@@ocaml.warning "-33"]
  open Types
  external makeVariables:     friendId: string-> 
    id: int-> 
    ids: int array-> 
   variables = "" [@@mel.obj]


  external makeOptimisticResponse:     ?addFriend: rawResponse_addFriend-> 
    ?testIntInput1: rawResponse_testIntInput1-> 
    ?testIntInput2: rawResponse_testIntInput2-> 
    unit ->
   rawResponse = "" [@@mel.obj]


  external make_rawResponse_addFriend_addedFriend_friends:     id: string-> 
   rawResponse_addFriend_addedFriend_friends = "" [@@mel.obj]


  external make_rawResponse_addFriend_addedFriend:     friends: rawResponse_addFriend_addedFriend_friends array-> 
    id: string-> 
   rawResponse_addFriend_addedFriend = "" [@@mel.obj]


  external make_rawResponse_addFriend:     ?addedFriend: rawResponse_addFriend_addedFriend-> 
    unit ->
   rawResponse_addFriend = "" [@@mel.obj]


  external make_rawResponse_testIntInput1:     ?success: bool-> 
    unit ->
   rawResponse_testIntInput1 = "" [@@mel.obj]


  external make_rawResponse_testIntInput2:     ?success: bool-> 
    unit ->
   rawResponse_testIntInput2 = "" [@@mel.obj]


end

type relayOperationNode
type operationType = relayOperationNode Melange_relay.mutationNode


let node: operationType = [%mel.raw {json| (function(){
var v0 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "friendId"
},
v1 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "id"
},
v2 = {
  "defaultValue": null,
  "kind": "LocalArgument",
  "name": "ids"
},
v3 = [
  {
    "alias": null,
    "args": null,
    "kind": "ScalarField",
    "name": "success",
    "storageKey": null
  }
],
v4 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v5 = [
  {
    "alias": null,
    "args": [
      {
        "kind": "Variable",
        "name": "id",
        "variableName": "id"
      }
    ],
    "concreteType": "TestIntInputPayload",
    "kind": "LinkedField",
    "name": "testIntInput1",
    "plural": false,
    "selections": (v3/*: any*/),
    "storageKey": null
  },
  {
    "alias": null,
    "args": [
      {
        "kind": "Variable",
        "name": "ids",
        "variableName": "ids"
      }
    ],
    "concreteType": "TestIntInputPayload",
    "kind": "LinkedField",
    "name": "testIntInput2",
    "plural": false,
    "selections": (v3/*: any*/),
    "storageKey": null
  },
  {
    "alias": null,
    "args": [
      {
        "kind": "Variable",
        "name": "friendId",
        "variableName": "friendId"
      }
    ],
    "concreteType": "AddFriendPayload",
    "kind": "LinkedField",
    "name": "addFriend",
    "plural": false,
    "selections": [
      {
        "alias": null,
        "args": null,
        "concreteType": "User",
        "kind": "LinkedField",
        "name": "addedFriend",
        "plural": false,
        "selections": [
          (v4/*: any*/),
          {
            "alias": null,
            "args": null,
            "concreteType": "User",
            "kind": "LinkedField",
            "name": "friends",
            "plural": true,
            "selections": [
              (v4/*: any*/)
            ],
            "storageKey": null
          }
        ],
        "storageKey": null
      }
    ],
    "storageKey": null
  }
];
return {
  "fragment": {
    "argumentDefinitions": [
      (v0/*: any*/),
      (v1/*: any*/),
      (v2/*: any*/)
    ],
    "kind": "Fragment",
    "metadata": null,
    "name": "TestMutationWithMultipleTargetsMutation",
    "selections": (v5/*: any*/),
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [
      (v1/*: any*/),
      (v2/*: any*/),
      (v0/*: any*/)
    ],
    "kind": "Operation",
    "name": "TestMutationWithMultipleTargetsMutation",
    "selections": (v5/*: any*/)
  },
  "params": {
    "cacheID": "312aa067064fe644c9b2e4d14ad21bbd",
    "id": null,
    "metadata": {},
    "name": "TestMutationWithMultipleTargetsMutation",
    "operationKind": "mutation",
    "text": "mutation TestMutationWithMultipleTargetsMutation(\n  $id: Int!\n  $ids: [Int!]!\n  $friendId: ID!\n) {\n  testIntInput1(id: $id) {\n    success\n  }\n  testIntInput2(ids: $ids) {\n    success\n  }\n  addFriend(friendId: $friendId) {\n    addedFriend {\n      id\n      friends {\n        id\n      }\n    }\n  }\n}\n"
  }
};
})() |json}]


