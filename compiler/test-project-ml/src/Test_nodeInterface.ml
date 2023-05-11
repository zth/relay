module Query1 = [%relay{|
    query TestNodeInterfaceQuery {
      node(id: "123") {
        ... on User {
          firstName
        }
        }
      }
|}]

module Query2 = [%relay{|
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

module Query3 = [%relay{|
    query TestNodeInterfaceOnInterfaceQuery {
      node(id: "123") {
        ... on HasName {
          name
}
        }
      }
|}]
