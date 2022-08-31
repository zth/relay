module Query = %relay(`
    query TestProvidedVariablesQuery {
      loggedInUser {
        ...TestProvidedVariables_user
      }
    }
`)

module Fragment = %relay(`
  fragment TestProvidedVariables_user on User @argumentDefinitions(
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
