module Query = [%relay{|
    query TestLocalPayloadQuery @raw_response_type {
      loggedInUser {
        id
        ...TestLocalPayload_user
      }
      }
|}]

module ViaNodeInterface = [%relay{|
    query TestLocalPayloadViaNodeInterfaceQuery($id: ID!) @raw_response_type {
      node(id: $id) {
        ... on User {
          firstName
          avatarUrl
          onlineStatus
        }
      }
    }
|}]

(*
 * Don't mind this fragment, it's mostly here to check that
 * it's actually getting inlined into the types for the query
 * payload we're committing locally below.
 *)
module Fragment = [%relay{|
  fragment TestLocalPayload_user on User {
    firstName
    avatarUrl
}
|}]
