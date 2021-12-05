module Fragment = %relay(`
  fragment Component_node on Node @refetchable(queryName: "ComponentRefetchQuery") {
    id
  }
`)
