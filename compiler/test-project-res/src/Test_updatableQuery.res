module UpdatableQuery = %relay(`
  query TestUpdatableQuery($id: ID!) @updatable {
    user(id: $id) {
      firstName
    }
  }
`)
