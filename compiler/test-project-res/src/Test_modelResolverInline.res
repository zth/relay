module Query = %relay(`
  query TestModelResolverInlineQuery {
    localUser {
      ... on LocalUser {
        name
        meta @required(action: NONE) {
          online
        }
      }
    }
  }
`)

