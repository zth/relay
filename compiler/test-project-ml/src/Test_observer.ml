module Query = [%relay{|
  query TestObserverQuery {
    loggedInUser {
      id
    }
    }
|}]
