module Query = %relay(`
    query TestRefetchingInNodeQuery($userId: ID!) {
      node(id: $userId) {
        __typename
        ... on User {
          ...TestRefetchingInNode_user
        }
      }
    }
`)

module Fragment = %relay(`
    fragment TestRefetchingInNode_user on User
      @refetchable(queryName: "TestRefetchingInNodeRefetchQuery")
      @argumentDefinitions(
        showOnlineStatus: { type: "Boolean", defaultValue: false }
        friendsOnlineStatuses: { type: "[OnlineStatus!]", defaultValue: [Online, offline]}
      ) {
      firstName
      onlineStatus @include(if: $showOnlineStatus)
      friendsConnection(statuses: $friendsOnlineStatuses) {
        totalCount
      }
    }
`)
