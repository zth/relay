module Query = %relay(`
    query TestCustomScalarsQuery($beforeDate: Datetime, $datetimes: [Datetime!]) {
      loggedInUser {
        createdAt
        friends(beforeDate: $beforeDate) {
          createdAt
        }
        onlineStatus(dateTimes: ["2024-01-17T00:00:00.000Z"])
        onlineStatus2: onlineStatus(dateTimes: $datetimes)
        datetimes
      }

      member(id: "user-1") {
        __typename
        ... on User {
          createdAt
          onlineStatus(dateTimes: ["2024-01-17T00:00:00.000Z"])
          onlineStatus2: onlineStatus(dateTimes: $datetimes)
          datetimes
        }
      }
    }
`)

module Query = %relay(`
    query TestCustomScalars2Query($asArray: [Datetime!]!) {
      customScalarArray(asArray: $asArray)
    }
`)
