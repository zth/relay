/* @sourceLoc ConnectionFragment.res */
/* @generated */
%%raw("/* @generated */")

module Types = {
  @@ocaml.warning("-30")
  
  type rec fragment_comments = {
    edges: option<array<option<fragment_comments_edges>>>,
  }
   and fragment_comments_edges = {
    node: option<fragment_comments_edges_node>,
  }
   and fragment_comments_edges_node = {
    id: string,
  }
  
  
  type fragment = {
    comments: option<fragment_comments>,
  }
}

module Internal = {
  type fragmentRaw
  let fragmentConverter: 
    Js.Dict.t<Js.Dict.t<Js.Dict.t<string>>> = 
    %raw(
      json`{"__root":{"comments":{"n":""},"comments_edges_node":{"n":""},"comments_edges":{"n":"","na":""}}}`
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
  RescriptRelay.fragmentRefs<[> | #ConnectionFragment_comment]> => fragmentRef = "%identity"


module Utils = {
  @@ocaml.warning("-33")
  open Types
  @inline
  let connectionKey = "ConnectionFragment_comment_comments"
  
  let getConnectionNodes:
    option<fragment_comments> => array<fragment_comments_edges_node> =
    connection => switch connection {
    | None => []
    | Some(connection) => switch connection.edges { 
     | None => []
     | Some(edges) => edges->Belt.Array.keepMap(edge => switch edge { 
      | None => None 
      | Some(edge) => edge.node
  
     })
    }}
}


type relayOperationNode
type operationType = RescriptRelay.fragmentNode<relayOperationNode>


let node: operationType = %raw(json`{
  "argumentDefinitions": [
    {
      "defaultValue": null,
      "kind": "LocalArgument",
      "name": "after"
    },
    {
      "defaultValue": 5,
      "kind": "LocalArgument",
      "name": "first"
    }
  ],
  "kind": "Fragment",
  "metadata": {
    "connection": [
      {
        "count": "first",
        "cursor": "after",
        "direction": "forward",
        "path": [
          "comments"
        ]
      }
    ]
  },
  "name": "ConnectionFragment_comment",
  "selections": [
    {
      "alias": "comments",
      "args": null,
      "concreteType": "CommentsConnection",
      "kind": "LinkedField",
      "name": "__ConnectionFragment_comment_comments_connection",
      "plural": false,
      "selections": [
        {
          "alias": null,
          "args": null,
          "concreteType": "CommentsEdge",
          "kind": "LinkedField",
          "name": "edges",
          "plural": true,
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
                },
                {
                  "alias": null,
                  "args": null,
                  "kind": "ScalarField",
                  "name": "__typename",
                  "storageKey": null
                }
              ],
              "storageKey": null
            },
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "cursor",
              "storageKey": null
            }
          ],
          "storageKey": null
        },
        {
          "alias": null,
          "args": null,
          "concreteType": "PageInfo",
          "kind": "LinkedField",
          "name": "pageInfo",
          "plural": false,
          "selections": [
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "endCursor",
              "storageKey": null
            },
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "hasNextPage",
              "storageKey": null
            }
          ],
          "storageKey": null
        }
      ],
      "storageKey": null
    }
  ],
  "type": "Comment",
  "abstractKey": null
}`)

