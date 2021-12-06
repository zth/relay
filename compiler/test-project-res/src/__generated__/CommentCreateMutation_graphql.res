/* @sourceLoc CommentCreate.res */
/* @generated */
%%raw("/* @generated */")

module Types = {
  @@ocaml.warning("-30")
  
  type rec response_commentCreate = {
    feedbackCommentEdge: option<response_commentCreate_feedbackCommentEdge>,
  }
   and response_commentCreate_feedbackCommentEdge = {
    node: option<response_commentCreate_feedbackCommentEdge_node>,
  }
   and response_commentCreate_feedbackCommentEdge_node = {
    id: string,
  }
  
  
  type response = {
    commentCreate: option<response_commentCreate>,
  }
  type rawResponse = response
  type variables = {
    connections: array<RescriptRelay.dataId>,
  }
}

module Internal = {
  type wrapResponseRaw
  let wrapResponseConverter: 
    Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = 
    %raw(
      json`{"__root":{"commentCreate":{"n":""},"commentCreate_feedbackCommentEdge":{"n":""},"commentCreate_feedbackCommentEdge_node":{"n":""}}}`
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
      json`{"__root":{"commentCreate":{"n":""},"commentCreate_feedbackCommentEdge":{"n":""},"commentCreate_feedbackCommentEdge_node":{"n":""}}}`
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
    ~connections
  ): variables => {
    connections: connections
  }
  let make_response_commentCreate_feedbackCommentEdge_node = (
    ~id
  ): response_commentCreate_feedbackCommentEdge_node => {
    id: id
  }
  let make_response_commentCreate_feedbackCommentEdge = (
    ~node=?,
    ()
  ): response_commentCreate_feedbackCommentEdge => {
    node: node
  }
  let make_response_commentCreate = (
    ~feedbackCommentEdge=?,
    ()
  ): response_commentCreate => {
    feedbackCommentEdge: feedbackCommentEdge
  }
  let makeOptimisticResponse = (
    ~commentCreate=?,
    ()
  ): rawResponse => {
    commentCreate: commentCreate
  }
}


type relayOperationNode
type operationType = RescriptRelay.mutationNode<relayOperationNode>


let node: operationType = %raw(json`(function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "connections"
  }
],
v1 = [
  {
    "kind": "Literal",
    "name": "input",
    "value": {
      "feedbackId": "some-id"
    }
  }
],
v2 = {
  "alias": null,
  "args": null,
  "concreteType": "CommentsEdge",
  "kind": "LinkedField",
  "name": "feedbackCommentEdge",
  "plural": false,
  "selections": [
    {
      "alias": null,
      "args": null,
      "concreteType": "Comment",
      "kind": "LinkedField",
      "name": "node",
      "plural": false,
      "selections": [
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
};
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": null,
    "name": "CommentCreateMutation",
    "selections": [
      {
        "alias": null,
        "args": (v1/*: any*/),
        "concreteType": "CommentCreateResponsePayload",
        "kind": "LinkedField",
        "name": "commentCreate",
        "plural": false,
        "selections": [
          (v2/*: any*/)
        ],
        "storageKey": "commentCreate(input:{\"feedbackId\":\"some-id\"})"
      }
    ],
    "type": "Mutation",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "CommentCreateMutation",
    "selections": [
      {
        "alias": null,
        "args": (v1/*: any*/),
        "concreteType": "CommentCreateResponsePayload",
        "kind": "LinkedField",
        "name": "commentCreate",
        "plural": false,
        "selections": [
          (v2/*: any*/),
          {
            "alias": null,
            "args": null,
            "filters": null,
            "handle": "appendEdge",
            "key": "",
            "kind": "LinkedHandle",
            "name": "feedbackCommentEdge",
            "handleArgs": [
              {
                "kind": "Variable",
                "name": "connections",
                "variableName": "connections"
              }
            ]
          }
        ],
        "storageKey": "commentCreate(input:{\"feedbackId\":\"some-id\"})"
      }
    ]
  },
  "params": {
    "cacheID": "5327123f0e01d9eea13f3de32bb4d769",
    "id": null,
    "metadata": {},
    "name": "CommentCreateMutation",
    "operationKind": "mutation",
    "text": "mutation CommentCreateMutation {\n  commentCreate(input: {feedbackId: \"some-id\"}) {\n    feedbackCommentEdge {\n      node {\n        id\n      }\n    }\n  }\n}\n"
  }
};
})()`)


