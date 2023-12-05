/* @generated */
@@warning("-30")

@live @unboxed
type enum_OnlineStatus = 
  | Online
  | Idle
  | @as("offline") Offline
  | FutureAddedValue(string)


@live @unboxed
type enum_OnlineStatus_input = 
  | Online
  | Idle
  | @as("offline") Offline


@live @unboxed
type enum_RequiredFieldAction = 
  | NONE
  | LOG
  | THROW
  | FutureAddedValue(string)


@live @unboxed
type enum_RequiredFieldAction_input = 
  | NONE
  | LOG
  | THROW


@live
type rec input_InputA = {
  time: SomeModule.Datetime.t,
  recursiveA?: input_InputA,
  usingB?: input_InputB,
  timestamp?: Timestamp.t,
  timestamps?: array<option<Timestamp.t>>,
  unmapped?: RescriptRelay.any,
}

@live
and input_InputA_nullable = {
  time: SomeModule.Datetime.t,
  recursiveA?: Js.Null.t<input_InputA_nullable>,
  usingB?: Js.Null.t<input_InputB_nullable>,
  timestamp?: Js.Null.t<Timestamp.t>,
  timestamps?: Js.Null.t<array<Js.Null.t<Timestamp.t>>>,
  unmapped?: Js.Null.t<RescriptRelay.any>,
}

@live
and input_InputB = {
  time?: SomeModule.Datetime.t,
  usingA?: input_InputA,
  @as("constraint") constraint_?: bool,
}

@live
and input_InputB_nullable = {
  time?: Js.Null.t<SomeModule.Datetime.t>,
  usingA?: Js.Null.t<input_InputA_nullable>,
  @as("constraint") constraint_?: Js.Null.t<bool>,
}

@live
and input_SomeInput = {
  str?: string,
  bool?: bool,
  float?: float,
  int?: int,
  datetime?: SomeModule.Datetime.t,
  recursive?: input_SomeInput,
  @as("private") private_?: bool,
}

@live
and input_SomeInput_nullable = {
  str?: Js.Null.t<string>,
  bool?: Js.Null.t<bool>,
  float?: Js.Null.t<float>,
  int?: Js.Null.t<int>,
  datetime?: Js.Null.t<SomeModule.Datetime.t>,
  recursive?: Js.Null.t<input_SomeInput_nullable>,
  @as("private") private_?: Js.Null.t<bool>,
}

@live
and input_RecursiveSetOnlineStatusInput = {
  someValue: RescriptRelay.any,
  setOnlineStatus?: input_SetOnlineStatusInput,
}

@live
and input_RecursiveSetOnlineStatusInput_nullable = {
  someValue: RescriptRelay.any,
  setOnlineStatus?: Js.Null.t<input_SetOnlineStatusInput_nullable>,
}

@live
and input_SetOnlineStatusInput = {
  onlineStatus: enum_OnlineStatus_input,
  recursed?: input_RecursiveSetOnlineStatusInput,
}

@live
and input_SetOnlineStatusInput_nullable = {
  onlineStatus: enum_OnlineStatus_input,
  recursed?: Js.Null.t<input_RecursiveSetOnlineStatusInput_nullable>,
}

@live
and input_PesticideListSearchInput = {
  companyName?: array<string>,
  pesticideIds?: array<int>,
  skip: int,
  take: int,
}

@live
and input_PesticideListSearchInput_nullable = {
  companyName?: Js.Null.t<array<string>>,
  pesticideIds?: Js.Null.t<array<int>>,
  skip: int,
  take: int,
}
