module Query = [%relay {|
  query TestMlQuery($status: OnlineStatus) {
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

module QueryWithRequired = [%relay {|
  query TestMlQueryWithRequiredQuery {
    loggedInUser {
      avatarUrl @required(action: NONE)
    }
  }
|}]

module QueryWithRequired_BubbleToTop = [%relay {|
  query TestMlQueryWithRequired_BubbleToTop_Query {
    loggedInUser @required(action: NONE) {
      avatarUrl @required(action: NONE)
    }
  }
|}]
