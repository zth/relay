module Query = %relay(`
  query TestQuery($status: OnlineStatus) @preloadable {
    users(status: $status) {
      edges {
        node {
          id
          firstName
          onlineStatus
        }
      }
    }
  }
`)
