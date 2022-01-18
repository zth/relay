module Query = %relay(`
  query TestQueryInputObjQuery($input: PesticideListSearchInput!) {
    searchPesticie(input: $input)
  }
`)
