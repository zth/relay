module Query = %relay(`
  query TestCodesplitQuery {
    member(id: "123") {
      ...GroupAvatar_group @autoCodesplit
      ...UserAvatar_user @autoCodesplit
    }
  }
`)
