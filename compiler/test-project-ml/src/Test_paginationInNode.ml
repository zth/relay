module Query = [%relay{|
    query TestPaginationInNodeQuery($userId: ID!) {
      node(id: $userId) {
        id
        __typename
        ... on User {
          ...TestPaginationInNode_query
        }
        }
      }
|}]

 (* This is just to ensure that fragments on unions work *)
module UserFragment = [%relay{|
  fragment TestPaginationInNode_user on User {
    id
    firstName
    friendsConnection(first: 1) {
      totalCount
}
    }
|}]

module Fragment = [%relay{|
    fragment TestPaginationInNode_query on User
      @refetchable(queryName: "TestPaginationInNodeRefetchQuery")
      @argumentDefinitions(
        onlineStatuses: { type: "[OnlineStatus!]" }
        count: { type: "Int", defaultValue: 2 }
        cursor: { type: "String", defaultValue: "" }
      ) {
        friendsConnection(
          statuses: $onlineStatuses
        first: $count
        after: $cursor
      ) @connection(key: "TestPaginationInNode_friendsConnection") {
        edges {
          node {
            id
            ...TestPaginationInNode_user
        }
          }
        }
      }
|}]
