module Query = %relay(`
  query TestRelayResolversAllQuery {
    localUser {
      name
      meta @required(action: NONE) { 
        online
      }
    }
  }
`)
