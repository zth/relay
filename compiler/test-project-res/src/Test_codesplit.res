module Query = %relay(`
  query TestCodesplitQuery {
    member(id: "123") {
      ... on User {
        ...UserAvatar_user @autoCodesplit @alias
        description {
          ...RichContent_content @autoCodesplit @alias
        }
      }
      ... on Group {
        ...GroupAvatar_group @autoCodesplit @alias
      }
      ...UserNode_node @autoCodesplit @alias
    }
  }
`)
