/* @generated */
type input_InputA = {
  time: option<Datetime.t>,
  recursiveA: RelaySchemaAssets_graphql.input_InputA,
  usingB: RelaySchemaAssets_graphql.input_InputB,
}
and input_InputB = {
  time: Datetime.t,
  usingA: RelaySchemaAssets_graphql.input_InputA,
  @as("constraint") constraint_: bool,
}
and input_SomeInput = {
  str: string,
  bool: bool,
  float: float,
  int: int,
  recursive: RelaySchemaAssets_graphql.input_SomeInput,
}
and input_RecursiveSetOnlineStatusInput = {
  someValue: option<IntString.t>,
  setOnlineStatus: RelaySchemaAssets_graphql.input_SetOnlineStatusInput,
}
and input_SetOnlineStatusInput = {
  onlineStatus: option<[#Online | #Idle | #Offline]>,
  recursed: RelaySchemaAssets_graphql.input_RecursiveSetOnlineStatusInput,
}
and input_PesticideListSearchInput = {
  companyName: array<option<string>>,
  pesticideIds: array<option<int>>,
  skip: option<int>,
  take: option<int>,
}
@obj external make_InputA: (
  ~time: option<Datetime.t>,
  ~recursiveA: RelaySchemaAssets_graphql.input_InputA,
  ~usingB: RelaySchemaAssets_graphql.input_InputB,
) => input_InputA = ""
@obj external make_InputB: (
  ~time: Datetime.t,
  ~usingA: RelaySchemaAssets_graphql.input_InputA,
  ~_constraint: bool,
) => input_InputB = ""
@obj external make_SomeInput: (
  ~str: string,
  ~bool: bool,
  ~float: float,
  ~int: int,
  ~recursive: RelaySchemaAssets_graphql.input_SomeInput,
) => input_SomeInput = ""
@obj external make_RecursiveSetOnlineStatusInput: (
  ~someValue: option<IntString.t>,
  ~setOnlineStatus: RelaySchemaAssets_graphql.input_SetOnlineStatusInput,
) => input_RecursiveSetOnlineStatusInput = ""
@obj external make_SetOnlineStatusInput: (
  ~onlineStatus: option<[#Online | #Idle | #Offline]>,
  ~recursed: RelaySchemaAssets_graphql.input_RecursiveSetOnlineStatusInput,
) => input_SetOnlineStatusInput = ""
@obj external make_PesticideListSearchInput: (
  ~companyName: array<option<string>>,
  ~pesticideIds: array<option<int>>,
  ~skip: option<int>,
  ~take: option<int>,
) => input_PesticideListSearchInput = ""
