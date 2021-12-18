module Query = %relay(`
    query TestRefetchingQuery {
      loggedInUser {
        ...TestRefetching_user
      }
    }
`)

module Fragment = %relay(`
    fragment TestRefetching_user on User
      @refetchable(queryName: "TestRefetchingRefetchQuery")
      @argumentDefinitions(
        friendsOnlineStatuses: { type: "[OnlineStatus!]" }
        showOnlineStatus: { type: "Boolean", defaultValue: false }
      ) {
      firstName
      onlineStatus @include(if: $showOnlineStatus)
      friendsConnection(statuses: $friendsOnlineStatuses) {
        totalCount
      }
    }
`)

module FragmentWithNoArgs = %relay(`
    fragment TestRefetchingNoArgs_query on Query
      @refetchable(queryName: "TestRefetchingNoArgsRefetchQuery")
      {
      loggedInUser {
        id
      }
    }
`)
