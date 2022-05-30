module Query = [%relay {|
  query TestReQuery($status: OnlineStatus) {
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
  |}];

module QueryWithRequired = [%relay {|
  query TestReQueryWithRequiredQuery {
    loggedInUser {
      avatarUrl @required(action: NONE)
    }
  }
|}];

module QueryWithRequired_BubbleToTop = [%relay {|
  query TestReQueryWithRequired_BubbleToTop_Query {
    loggedInUser @required(action: NONE) {
      avatarUrl @required(action: NONE)
    }
  }
|}];
