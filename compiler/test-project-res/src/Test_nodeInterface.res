module Query = %relay(`
    query TestNodeInterfaceQuery {
      node(id: "123") {
        ... on User {
          firstName
        }
      }
    }
`)
