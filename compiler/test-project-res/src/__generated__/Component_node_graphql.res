/* @sourceLoc Component.res */
/* @generated */
%%raw("/* @generated */")

module Types = {
  @@ocaml.warning("-30")
  
  type fragment_commentBody_PlainCommentBody_text = {
    text: option<string>,
  }
  
  type fragment_commentBody_PlainCommentBody = {
    text: option<fragment_commentBody_PlainCommentBody_text>,
  }
  
  type fragment_commentBody_MarkdownCommentBody_text = {
    text: option<string>,
  }
  
  type fragment_commentBody_MarkdownCommentBody = {
    text: option<fragment_commentBody_MarkdownCommentBody_text>,
  }
  
  
  type fragment_commentBody = [
    | #PlainCommentBody(fragment_commentBody_PlainCommentBody)
  
    | #MarkdownCommentBody(fragment_commentBody_MarkdownCommentBody)
    | #UnselectedUnionMember(string)
  ]
  type fragment = {
    __isNode: string,
    id: string,
    commentBody: option<[
      | #PlainCommentBody(fragment_commentBody_PlainCommentBody)
  
      | #MarkdownCommentBody(fragment_commentBody_MarkdownCommentBody)
      | #UnselectedUnionMember(string)
    ]>,
  }
}

let unwrap_fragment_commentBody: {. "__typename": string } => [
  | #PlainCommentBody(Types.fragment_commentBody_PlainCommentBody)

  | #MarkdownCommentBody(Types.fragment_commentBody_MarkdownCommentBody)
  | #UnselectedUnionMember(string)
] = u => switch u["__typename"] {
 | "PlainCommentBody" => #PlainCommentBody(u->Obj.magic) 
 | "MarkdownCommentBody" => #MarkdownCommentBody(u->Obj.magic) 
 | v => #UnselectedUnionMember(v)
}

let wrap_fragment_commentBody: [
  | #PlainCommentBody(Types.fragment_commentBody_PlainCommentBody)

  | #MarkdownCommentBody(Types.fragment_commentBody_MarkdownCommentBody)
  | #UnselectedUnionMember(string)
] => {. "__typename": string } = v => switch v {
 | #PlainCommentBody(v) => v->Obj.magic 
 | #MarkdownCommentBody(v) => v->Obj.magic 
 | #UnselectedUnionMember(v) => {"__typename": v} 
}

module Internal = {
  type fragmentRaw
  let fragmentConverter: 
    Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = 
    %raw(
      json`{"__root":{"commentBody_markdowncommentbody_text":{"n":""},"commentBody_plaincommentbody_text_text":{"n":""},"commentBody_plaincommentbody_text":{"n":""},"commentBody":{"n":"","u":"fragment_commentBody"},"commentBody_markdowncommentbody_text_text":{"n":""}}}`
    )
  
  let fragmentConverterMap = {
    "fragment_commentBody": unwrap_fragment_commentBody,
  }
  
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


type relayOperationNode
type operationType = RescriptRelay.fragmentNode<relayOperationNode>


%%private(let makeNode = (rescript_graphql_node_ComponentRefetchQuery): operationType => {
  ignore(rescript_graphql_node_ComponentRefetchQuery)
  %raw(json`(function(){
var v0 = [
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
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": {
    "refetch": {
      "connection": null,
      "fragmentPathInResult": [
        "node"
      ],
      "operation": rescript_graphql_node_ComponentRefetchQuery,
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
            {
              "kind": "InlineFragment",
              "selections": (v0/*: any*/),
              "type": "PlainCommentBody",
              "abstractKey": null
            },
            {
              "kind": "InlineFragment",
              "selections": (v0/*: any*/),
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
  "type": "Node",
  "abstractKey": "__isNode"
};
})()`)
})
let node: operationType = makeNode(ComponentRefetchQuery_graphql.node)

