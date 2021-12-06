module Fragment = %relay(`
  fragment Component_node on Node @refetchable(queryName: "ComponentRefetchQuery") {
    id
    ... on Comment {
      commentBody(supported: []) {
        ... on PlainCommentBody {
          text {
            text
          }
        }
        ... on MarkdownCommentBody {
          text {
            text
          }
        }
      }
    }
  }
`)
