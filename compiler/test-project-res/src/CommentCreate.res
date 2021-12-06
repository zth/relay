module Mutation = %relay(`
  mutation CommentCreateMutation($connections: [ID!]!) {
    commentCreate(input: {feedbackId: "some-id"}) {
        feedbackCommentEdge @appendEdge(connections: $connections) {
          node {
            id
          }
        }
    }
  }
`)