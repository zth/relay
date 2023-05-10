module Query = [%relay{|
    query TestMissingFieldHandlersQuery {
      node(id: "123") {
        __typename
        ... on User {
          firstName
        }
        }
      }
    |}]

module MeQuery = [%relay{|
    query TestMissingFieldHandlersMeQuery {
      loggedInUser {
        firstName
}
      }
|}]
