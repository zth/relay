// TODO:
// - Input objects with conversion instructions
module Query = %relay(`
  query TestPreloadedQuery($status: OnlineStatus) @preloadable {
    users(status: $status) {
      edges {
        node {
          id
          firstName
          onlineStatus
        }
      }
    }
  }
`)

module Query = %relay(`
  query TestPreloadedQueryWithProvidedVariablesQuery($status: OnlineStatus) @preloadable {
    loggedInUser {
      ...TestPreloadedQuery_user
    }
    users(status: $status) {
      edges {
        node {
          id
          firstName
          onlineStatus
        }
      }
    }
  }
`)

module Fragment = %relay(`
  fragment TestPreloadedQuery_user on User @argumentDefinitions(
    someInput: { 
      type: "SomeInput!"
      provider: "TestProvidedVariables.SomeInput"
    }
    inputB: { 
      type: "InputB!"
      provider: "TestProvidedVariables.InputB"
    }
    bool: { 
      type: "Boolean!"
      provider: "TestProvidedVariables.Bool"
    }
    str: { 
      type: "String!"
      provider: "TestProvidedVariables.Str"
    }
    float: { 
      type: "Float!"
      provider: "TestProvidedVariables.Float"
    }
    int: { 
      type: "Int"
      provider: "TestProvidedVariables.Int"
    }
    id: { 
      type: "ID"
      provider: "TestProvidedVariables.ID"
    }
    dateTime: { 
      type: "Datetime"
      provider: "TestProvidedVariables.Datetime"
    }
    dateTimes: { 
      type: "[Datetime!]"
      provider: "TestProvidedVariables.Datetimes"
    }
  ) {
    firstName
    onlineStatus(
      someInput: $someInput 
      inputB: $inputB 
      bool: $bool 
      str: $str 
      float: $float 
      int: $int 
      id: $id
      dateTime: $dateTime
      dateTimes: $dateTimes
    )
  }
`)
