module Query = %relay(`
  query AppQuery @preloadable {
    node(id: "test") {
      ...Component_node
    }
  }
`)
