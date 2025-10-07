module Query = %relay(`
  query TestModelResolverAliasedQuery {
    myLocal: localUser {
      name
      meta @required(action: NONE) {
        online
      }
    }
  }
`)

