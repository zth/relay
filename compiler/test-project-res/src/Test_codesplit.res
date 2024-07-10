module Query = %relay(`
  query TestCodesplitQuery($includeFriendAvatar: Boolean!) {
    member(id: "123") {
      ... on User {
        ...UserAvatar_user @autoCodesplit @alias
        description {
          ...RichContent_content @autoCodesplit @alias
        }
        bestFriend {
          ...FriendComponent_user @autoCodesplit @alias @include(if: $includeFriendAvatar)
          ...FriendComponent2_user @autoCodesplit @alias
          ...FriendComponentSkip_user @autoCodesplit @alias @skip(if: $includeFriendAvatar)
        }
      }
      ... on Group {
        ...GroupAvatar_group @autoCodesplit @alias
      }
      ...UserNode_node @autoCodesplit @alias
    }
  }
`)
