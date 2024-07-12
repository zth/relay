module Query = %relay(`
  query TestCodesplitQuery($includeFriendAvatar: Boolean!) {
    member(id: "123") {
      ... on User {
        ...UserAvatar_user @codesplit @alias
        description {
          ...RichContent_content @codesplit @alias
        }
        bestFriend {
          ...FriendComponent_user @codesplit @alias @include(if: $includeFriendAvatar)
          ...FriendComponent2_user @codesplit @alias
          ...FriendComponentSkip_user @codesplit @alias @skip(if: $includeFriendAvatar)
        }
      }
      ... on Group {
        ...GroupAvatar_group @codesplit @alias
      }
      ...UserNode_node @codesplit @alias
    }
  }
`)
