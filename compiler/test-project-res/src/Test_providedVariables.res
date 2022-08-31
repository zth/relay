module Query = %relay(`
    query TestProvidedVariablesQuery {
      loggedInUser {
        ...TestProvidedVariables_user
      }
    }
`)

module Fragment = %relay(`
  fragment TestProvidedVariables_user on User @argumentDefinitions(includeOnlineStatus: { 
      type: "SomeInput!"
      provider: "TestProvidedVariables"
    }) {
    firstName
    onlineStatus(show: $includeOnlineStatus)
  }
`)
