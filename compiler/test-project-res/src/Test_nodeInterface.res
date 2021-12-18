module Query = %relay(`
    query TestNodeInterfaceQuery {
      node(id: "123") {
        __typename
        ... on User {
          firstName
        }
      }
    }
`)
