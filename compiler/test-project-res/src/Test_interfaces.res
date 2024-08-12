module Fragment = %relay(`
  fragment TestInterfaces_hasName on HasName {
    name
    ... @alias(as: "byType") {
      __typename
      ... on Group {
        avatarUrl
      }
      ... on Organization {
        slug
      }
    }
  }
`)
