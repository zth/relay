module Query = %relay(`
    query TestFragmentQuery {
      loggedInUser {
        ...TestFragment_user
        ...TestFragment_inline
      }
      users {
        edges {
          node {
            id
            onlineStatus
            ...TestFragment_plural_user
          }
        }
      }
    }
`)

module SubFragment = %relay(`
    fragment TestFragment_sub_user on User {
      lastName
    }
`)

module Fragment = %relay(`
    fragment TestFragment_user on User {
      __id
      firstName
      onlineStatus
      ...TestFragment_sub_user
    }
`)

module InlineFragment = %relay(`
    fragment TestFragment_inline on User @inline {
      firstName
      onlineStatus
    }
`)

module PluralFragment = %relay(`
    fragment TestFragment_plural_user on User @relay(plural: true) {
      id
      firstName
      onlineStatus
    }
`)


