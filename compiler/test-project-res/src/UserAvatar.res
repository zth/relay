module Fragment = %relay(`
  fragment UserAvatar_user on User {
    avatarUrl
    ...UserName_user @autoCodesplit @alias
  }
`)
