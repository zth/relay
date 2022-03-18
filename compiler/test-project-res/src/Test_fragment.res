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
      greeting
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

module FragmentWithRequired = %relay(`
    fragment TestFragment_required_user on User {
      isOnline @required(action: NONE)
      lastName
      firstName
    }
`)

module FragmentWithRequiredPlural = %relay(`
    fragment TestFragment_requiredPlural_user on User @relay(plural: true) {
      isOnline @required(action: NONE)
      lastName
      firstName
    }
`)

module FragmentWithRequiredUnion = %relay(`
    fragment TestFragment_requiredUnion_member on Member {
      ... on User {
        __typename
        isOnline @required(action: NONE)
        lastName
        firstName
      }
      ... on Group {
        name
      }
    }
`)

module FragmentWithRequiredUnionPlural = %relay(`
    fragment TestFragment_requiredUnionPlural_member on Member @relay(plural: true) {
      ... on User {
        isOnline @required(action: NONE)
        lastName
        firstName
      }
      ... on Group {
        name
      }
    }
`)

