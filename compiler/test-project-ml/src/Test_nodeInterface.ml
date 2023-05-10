module Query = [%relay{|
    query TestNodeInterfaceQuery {
      node(id: "123") {
        ... on User {
          firstName
        }
        }
      }
|}]

module Query = [%relay{|
    query TestNodeInterfaceOnUnionQuery {
      node(id: "123") {
        ... on Member {
          ... on Group {
            name
}
          ... on User {
            firstName
          }
          }
        }
      }
|}]

module Query = [%relay{|
    query TestNodeInterfaceOnInterfaceQuery {
      node(id: "123") {
        ... on HasName {
          name
}
        }
      }
|}]
