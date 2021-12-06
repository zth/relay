/* @sourceLoc App.res */
/* @generated */
%%raw("/* @generated */")

module Types = {
  @@ocaml.warning("-30")
  
  type rec response_node = {
    __typename: string,
    fragmentRefs: RescriptRelay.fragmentRefs<[ | #Component_node]>
  }
  type response = {
    node: option<response_node>,
  }
  type rawResponse = response
  type refetchVariables = unit
  let makeRefetchVariables = (
  ) => ()
  
  type variables = unit
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

}


type relayOperationNode
type operationType = RescriptRelay.queryNode<relayOperationNode>


let node: operationType = %raw(json`(function(){
var v0 = [
  {
    "kind": "Literal",
    "name": "id",
    "value": "test"
  }
],
v1 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "__typename",
  "storageKey": null
},
v2 = [
  {
    "alias": null,
    "args": null,
    "concreteType": "Text",
    "kind": "LinkedField",
    "name": "text",
    "plural": false,
    "selections": [
      {
        "alias": null,
        "args": null,
        "kind": "ScalarField",
        "name": "text",
        "storageKey": null
      }
    ],
    "storageKey": null
  }
];
return {
  "fragment": {
    "argumentDefinitions": [],
    "kind": "Fragment",
    "metadata": null,
    "name": "AppQuery",
    "selections": [
      {
        "alias": null,
        "args": (v0/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "node",
        "plural": false,
        "selections": [
          {
            "args": null,
            "kind": "FragmentSpread",
            "name": "Component_node"
          }
        ],
        "storageKey": "node(id:\"test\")"
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": [],
    "kind": "Operation",
    "name": "AppQuery",
    "selections": [
      {
        "alias": null,
        "args": (v0/*: any*/),
        "concreteType": null,
        "kind": "LinkedField",
        "name": "node",
        "plural": false,
        "selections": [
          (v1/*: any*/),
          {
            "kind": "TypeDiscriminator",
            "abstractKey": "__isNode"
          },
          {
            "alias": null,
            "args": null,
            "kind": "ScalarField",
            "name": "id",
            "storageKey": null
          },
          {
            "kind": "InlineFragment",
            "selections": [
              {
                "alias": null,
                "args": [
                  {
                    "kind": "Literal",
                    "name": "supported",
                    "value": []
                  }
                ],
                "concreteType": null,
                "kind": "LinkedField",
                "name": "commentBody",
                "plural": false,
                "selections": [
                  (v1/*: any*/),
                  {
                    "kind": "InlineFragment",
                    "selections": (v2/*: any*/),
                    "type": "PlainCommentBody",
                    "abstractKey": null
                  },
                  {
                    "kind": "InlineFragment",
                    "selections": (v2/*: any*/),
                    "type": "MarkdownCommentBody",
                    "abstractKey": null
                  }
                ],
                "storageKey": "commentBody(supported:[])"
              }
            ],
            "type": "Comment",
            "abstractKey": null
          }
        ],
        "storageKey": "node(id:\"test\")"
      }
    ]
  },
  "params": {
    "cacheID": "cc3eeaf046afcf1bc478d289fb99e5c0",
    "id": null,
    "metadata": {},
    "name": "AppQuery",
    "operationKind": "query",
    "text": "query AppQuery {\n  node(id: \"test\") {\n    __typename\n    ...Component_node\n    id\n  }\n}\n\nfragment Component_node on Node {\n  __isNode: __typename\n  id\n  ... on Comment {\n    commentBody(supported: []) {\n      __typename\n      ... on PlainCommentBody {\n        text {\n          text\n        }\n      }\n      ... on MarkdownCommentBody {\n        text {\n          text\n        }\n      }\n    }\n  }\n}\n"
  }
};
})()`)

type queryRef
include RescriptRelay.MakeLoadQuery({
    type variables = Types.variables
    type loadedQueryRef = queryRef
    type response = Types.response
    type node = relayOperationNode
    let query = node
    let convertVariables = Internal.convertVariables
});
