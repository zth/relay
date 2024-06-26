module Query = %relay(`
  query TestSchemaExtensionsQuery {
    localOnlineStatus
    localUnion {
        ... on LocalThing {
            name
        }
    }
  }
`)

module Query = %relay(`
  fragment TestSchemaExtensionsQuery_fragment on Query {
    localOnlineStatus
    localUnion {
        ... on LocalThing {
            name
        }
    }
  }
`)
