module Query = %relay(`
  query TestCatchAndFriendsQuery {
    loggedInUser {
      avatarUrl @catch
    }
  }
`)


module Query = %relay(`
  query TestCatchAndFriends2Query {
    member(id: "123") @catch {
      ... on User {
        id
      }
    }
  }
`)

module Query = %relay(`
  query TestCatchAndFriends3Query {
    members(groupId: "123") {
      edges {
        node @catch {
          ... on User {
            id
          }
        }
      }
    }
  }
`)
