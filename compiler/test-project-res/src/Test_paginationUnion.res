module Query = %relay(`
    query TestPaginationUnionQuery($groupId: ID!) {
      ...TestPaginationUnion_query @arguments(groupId: $groupId)
    }
`)

// This is just to ensure that fragments on unions work
module UserFragment = %relay(`
  fragment TestPaginationUnion_user on User {
    firstName
    friendsConnection(first: 1) {
      totalCount
    }
  }
`)

module Fragment = %relay(`
    fragment TestPaginationUnion_query on Query
      @refetchable(queryName: "TestPaginationUnionRefetchQuery")
      @argumentDefinitions(
        groupId: { type: "ID!" }
        onlineStatuses: { type: "[OnlineStatus!]" }
        count: { type: "Int", defaultValue: 2 }
        cursor: { type: "String", defaultValue: "" }
      ) {
      members(
        groupId: $groupId
        onlineStatuses: $onlineStatuses
        first: $count
        after: $cursor
      ) @connection(key: "TestPaginationUnion_query_members") {
        edges {
          node {
            __typename
            ... on User {
              id
              ...TestPaginationUnion_user
            }

            ... on Group {
              id
              name
              adminsConnection(first: 1) {
                edges {
                  node {
                    id
                    firstName
                  }
                }
              }
            }
          }
        }
      }
    }
`)
