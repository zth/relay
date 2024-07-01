module Fragment1 = %relay(`
  fragment TestAliasedFragments_one on User {
    firstName
  }
`)

module Fragment2 = %relay(`
  fragment TestAliasedFragments_two on User {
    firstName
  }
`)

module FragmentContainer = %relay(`
  fragment TestAliasedFragments_container on User {
    firstName
    ...TestAliasedFragments_one @alias
    ...TestAliasedFragments_two @alias
  }
`)
