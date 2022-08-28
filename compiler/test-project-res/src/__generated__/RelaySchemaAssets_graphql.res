/* @generated */
type input_InputA = {
  time: Datetime.t,
  recursiveA: option<RelaySchemaAssets_graphql.input_InputA>,
  usingB: option<RelaySchemaAssets_graphql.input_InputB>,
}
and input_InputB = {
  time: option<Datetime.t>,
  usingA: option<RelaySchemaAssets_graphql.input_InputA>,
  @as("constraint") constraint_: option<bool>,
}
and input_SomeInput = {
  str: option<string>,
  bool: option<bool>,
  float: option<float>,
  int: option<int>,
  recursive: option<RelaySchemaAssets_graphql.input_SomeInput>,
}
and input_RecursiveSetOnlineStatusInput = {
  someValue: IntString.t,
  setOnlineStatus: option<RelaySchemaAssets_graphql.input_SetOnlineStatusInput>,
}
and input_SetOnlineStatusInput = {
  onlineStatus: [#Online | #Idle | #Offline],
  recursed: option<RelaySchemaAssets_graphql.input_RecursiveSetOnlineStatusInput>,
}
and input_PesticideListSearchInput = {
  companyName: option<array<string>>,
  pesticideIds: option<array<int>>,
  skip: int,
  take: int,
}
@obj external make_InputA: (
  ~time: Datetime.t,
  ~recursiveA: option<RelaySchemaAssets_graphql.input_InputA>,
  ~usingB: option<RelaySchemaAssets_graphql.input_InputB>,
) => input_InputA = ""
@obj external make_InputB: (
  ~time: option<Datetime.t>,
  ~usingA: option<RelaySchemaAssets_graphql.input_InputA>,
  ~_constraint: option<bool>,
) => input_InputB = ""
@obj external make_SomeInput: (
  ~str: option<string>,
  ~bool: option<bool>,
  ~float: option<float>,
  ~int: option<int>,
  ~recursive: option<RelaySchemaAssets_graphql.input_SomeInput>,
) => input_SomeInput = ""
@obj external make_RecursiveSetOnlineStatusInput: (
  ~someValue: IntString.t,
  ~setOnlineStatus: option<RelaySchemaAssets_graphql.input_SetOnlineStatusInput>,
) => input_RecursiveSetOnlineStatusInput = ""
@obj external make_SetOnlineStatusInput: (
  ~onlineStatus: [#Online | #Idle | #Offline],
  ~recursed: option<RelaySchemaAssets_graphql.input_RecursiveSetOnlineStatusInput>,
) => input_SetOnlineStatusInput = ""
@obj external make_PesticideListSearchInput: (
  ~companyName: option<array<string>>,
  ~pesticideIds: option<array<int>>,
  ~skip: int,
  ~take: int,
) => input_PesticideListSearchInput = ""
