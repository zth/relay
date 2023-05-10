module Query = [%relay{|
    query TestSubscriptionQuery {
      loggedInUser {
        ...TestSubscription_user
      }
      }
|}]

module Fragment = [%relay{|
    fragment TestSubscription_user on User {
      id
      firstName
      avatarUrl
      onlineStatus
}
|}]

module UserUpdatedSubscription = [%relay{|
  subscription TestSubscriptionUserUpdatedSubscription($userId: ID!) {
    userUpdated(id: $userId) {
      user {
        id
        onlineStatus
        ...TestSubscription_user
}
      }
    }
|}]
