module Query = %relay(`
    query TestCustomScalarsQuery($beforeDate: Datetime) {
      loggedInUser {
        createdAt
        friends(beforeDate: $beforeDate) {
          createdAt
        }
      }

      member(id: "user-1") {
        __typename
        ... on User {
          createdAt
        }
      }
    }
`)

module Query = %relay(`
    query TestCustomScalars2Query($asArray: [Datetime!]!) {
      customScalarArray(asArray: $asArray)
    }
`)
