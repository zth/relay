module Fragment = %relay(`
  fragment TestConnections_user on User
    @argumentDefinitions(
      onlineStatuses: { type: "[OnlineStatus!]", defaultValue: [Idle] }
      count: { type: "Int", defaultValue: 2 }
      cursor: { type: "String", defaultValue: "" }
      beforeDate: { type: "Datetime!" }
    ) {
    friendsConnection(
      statuses: $onlineStatuses
      first: $count
      after: $cursor
      beforeDate: $beforeDate
    ) @connection(key: "TestConnections_user_friendsConnection") {
      edges {
        node {
          id
        }
      }
    }
  }
`)

module Fragment = %relay(`
  fragment TestConnectionsWithFilters_user on User
    @argumentDefinitions(
      onlineStatuses: { type: "[OnlineStatus!]" }
      count: { type: "Int", defaultValue: 2 }
      cursor: { type: "String", defaultValue: "" }
      beforeDate: { type: "Datetime!" }
      objTest: { type: "SomeInput", defaultValue: {str: "123"} }
    ) {
    friendsConnection(
      statuses: $onlineStatuses
      beforeDate: $beforeDate
      first: $count
      after: $cursor
      objTest: $objTest
    ) @connection(key: "TestConnectionsWithFilters_user_friendsConnection", filters: ["statuses", "objTest"]) {
      edges {
        node {
          id
        }
      }
    }
  }
`)

module Fragment = %relay(`
  fragment TestConnectionsWithEmptyFilters_user on User
    @argumentDefinitions(
      onlineStatuses: { type: "[OnlineStatus!]" }
      count: { type: "Int", defaultValue: 2 }
      cursor: { type: "String", defaultValue: "" }
      beforeDate: { type: "Datetime!" }
    ) {
    friendsConnection(
      statuses: $onlineStatuses
      beforeDate: $beforeDate
      first: $count
      after: $cursor
    ) @connection(key: "TestConnectionsWithEmptyFilters_user_friendsConnection", filters: []) {
      edges {
        node {
          id
        }
      }
    }
  }
`)

module Fragment = %relay(`
  fragment TestConnectionsWithConstantValues_user on User
    @argumentDefinitions(
      onlineStatus: { type: "OnlineStatus!" }
      count: { type: "Int", defaultValue: 2 }
      cursor: { type: "String", defaultValue: "" }
      beforeDate: { type: "Datetime!" }
      bool: { type: "Boolean" }
    ) {
    friendsConnection(
      statuses: [Idle, $onlineStatus]
      beforeDate: $beforeDate
      first: $count
      after: $cursor
      objTest: {
        str: "123"
        bool: false
        float: 12.2
        int: 64
        recursive: {
          str: "234"
          bool: $bool
        }
      }
    ) @connection(key: "TestConnectionsWithonstantValues_user_friendsConnection") {
      edges {
        node {
          id
        }
      }
    }
  }
`)
