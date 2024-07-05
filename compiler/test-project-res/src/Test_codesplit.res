module Query = %relay(`
  query TestCodesplitQuery {
    member(id: "123") {
      ... on User {
        ...UserAvatar_user @autoCodesplit @alias
      }
      ... on Group {
        ...GroupAvatar_group @autoCodesplit @alias
      }
    }
  }
`)
