module Query = [%relay{|
    query TestUnionFragmentQuery {
      member(id: "123") {
        ...TestUnionFragment_member
        ...TestUnionFragment_plural_member
      }
      }
|}]

module Fragment = [%relay{|
    fragment TestUnionFragment_member on Member {
      ... on User {
        firstName
        onlineStatus
        ...TestUnionFragmentUser_user
}
      ... on Group {
        name
      }
      }
|}]

module UserFragment = [%relay{|
    fragment TestUnionFragmentUser_user on User {
      firstName
      onlineStatus
}
|}]

module PluralFragment = [%relay{|
    fragment TestUnionFragment_plural_member on Member @relay(plural: true) {
      ... on User {
        firstName
        onlineStatus
        ...TestUnionFragmentUser_user
}
      ... on Group {
        name
      }
      }
|}]
