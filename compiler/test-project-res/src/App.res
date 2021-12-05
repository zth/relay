module Query = %relay(`
  query AppQuery {
    node(id: "test") {
      ...Component_node
    }
  }
`)
