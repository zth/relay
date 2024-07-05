module Query = %relay(`
  query Test3dQuery {
    member(id: "123") @match {
      ...GroupAvatar_group @module(name: "GroupAvatar")
      ...UserAvatar_user @module(name: "UserAvatar")
    }
  }
`)
