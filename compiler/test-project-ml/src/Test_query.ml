module Query = [%relay{|
  query TestQuery($status: OnlineStatus) {
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
|}]

module QueryWithRequired = [%relay{|
  query TestQueryWithRequiredQuery {
    loggedInUser {
      avatarUrl @required(action: NONE)
  }
    }
|}]

module QueryWithRequired_BubbleToTop = [%relay{|
  query TestQueryWithRequired_BubbleToTop_Query {
    loggedInUser @required(action: NONE) {
      avatarUrl @required(action: NONE)
  }
    }
|}]
