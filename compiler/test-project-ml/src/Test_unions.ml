module Query = [%relay{|
  query TestUnionsQuery {
    members(groupId: "123") {
      edges {
        node {
          __typename
          ... on User {
            id
            firstName
            onlineStatus
          }

          ... on Group {
            id
            name
            avatarUrl
            members {
              __typename
                ... on User {
                  id
                    firstName
                    onlineStatus
          }
                ... on Group {
                  id
                    name
                    avatarUrl
                }
                }
            }
          }
        }
      }
    }
|}]
