module Fragment = %relay(`
  fragment ConnectionFragment_comment on Comment @argumentDefinitions(first: {type: "Int", defaultValue: 5}, after: {type: "ID"}) {
      comments(first: $first, after: $after) @connection(key: "ConnectionFragment_comment_comments") {
          edges {
              node {
                  id
              }
          }
      }
  }
`)