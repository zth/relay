module Query = %relay(`
    query TestMutationQuery {
      loggedInUser {
        ...TestMutation_user
      }
    }
`)

module Mutation = %relay(`
    mutation TestMutationSetOnlineStatusMutation($onlineStatus: OnlineStatus!, $connections: [ID!]!) @raw_response_type {
      setOnlineStatus(onlineStatus: $onlineStatus) {
        user @appendNode(connections: $connections, edgeTypeName: "UserEdge") {
          id
          onlineStatus
          ...TestFragment_user
        } 
      }
    }
`)

module ComplexMutation = %relay(`
    mutation TestMutationSetOnlineStatusComplexMutation($input: SetOnlineStatusInput!) {
      setOnlineStatusComplex(input: $input) {
        user {
          id
          onlineStatus
        }
      }
    }
`)

module MutationWithRecursiveInputs = %relay(`
    mutation TestMutationWithRecursiveInputsMutation($input: InputA!) {
      recursiveInput(input: $input) {
        recursionIsCool
      }
    }
`)

module MutationWithOnlyFragment = %relay(`
    mutation TestMutationWithOnlyFragmentSetOnlineStatusMutation($onlineStatus: OnlineStatus!) @raw_response_type {
      setOnlineStatus(onlineStatus: $onlineStatus) {
        user {
          ...TestMutation_user
        }
      }
    }
`)

module Fragment = %relay(`
    fragment TestMutation_user on User {
      id
      firstName
      lastName
      onlineStatus
      memberOf {
        __typename
        ... on User {
          firstName
        }
        ... on Group {
          name
        }
      }
    }
`)

module MutationWithInlineFragment = %relay(`
    mutation TestMutationWithInlineFragmentSetOnlineStatusMutation($onlineStatus: OnlineStatus!) @raw_response_type {
      setOnlineStatus(onlineStatus: $onlineStatus) {
        user {
          ...TestMutationInline_user
        }
      }
    }
`)

module InlineFragment = %relay(`
    fragment TestMutationInline_user on User @inline {
      id
      firstName
      lastName
      onlineStatus
    }
`)

module MutationWithMultipleTargets = %relay(`
    mutation TestMutationWithMultipleTargetsMutation($id: Int!, $ids: [Int!]!, $friendId: ID!) @raw_response_type {
      testIntInput1(id: $id) {
        success
      }
      testIntInput2(ids: $ids) {
        success
      }
      addFriend(friendId: $friendId) {
        addedFriend{
          id
          friends {
            id
          }
        }
      }
    }
`)

module MutationWithRecursiveInputsNullable = %relay(`
    mutation TestMutationWithRecursiveInputsNullableMutation($input: InputA) @rescriptRelayNullableVariables {
      recursiveInput(input: $input) {
        recursionIsCool
      }
    }
`)
