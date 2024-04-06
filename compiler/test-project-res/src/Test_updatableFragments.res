module UpdatableFragment = %relay(`
  fragment TestUpdatableFragments_updatableUser on User @updatable {
    isOnline
    createdAt
  }
`)

module Fragment = %relay(`
  fragment TestUpdatableFragments_query on Query {
    loggedInUser {
      lastName
      firstName
      ...TestUpdatableFragments_updatableUser
    }
  }
`)
