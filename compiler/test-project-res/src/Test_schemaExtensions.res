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
