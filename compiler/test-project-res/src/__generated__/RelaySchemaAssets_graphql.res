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
  recursiveA: option<input_InputA>,
  usingB: option<input_InputB>,
  timestamp: option<Timestamp.t>,
  timestamps: option<array<option<Timestamp.t>>>,
  unmapped: option<RescriptRelay.any>,
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
  time: option<SomeModule.Datetime.t>,
  usingA: option<input_InputA>,
  @as("constraint") constraint_: option<bool>,
}

@live
and input_InputB_nullable = {
  time?: Js.Null.t<SomeModule.Datetime.t>,
  usingA?: Js.Null.t<input_InputA_nullable>,
  @as("constraint") constraint_?: Js.Null.t<bool>,
}

@live
and input_SomeInput = {
  str: option<string>,
  bool: option<bool>,
  float: option<float>,
  int: option<int>,
  datetime: option<SomeModule.Datetime.t>,
  recursive: option<input_SomeInput>,
  @as("private") private_: option<bool>,
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
  setOnlineStatus: option<input_SetOnlineStatusInput>,
}

@live
and input_RecursiveSetOnlineStatusInput_nullable = {
  someValue: RescriptRelay.any,
  setOnlineStatus?: Js.Null.t<input_SetOnlineStatusInput_nullable>,
}

@live
and input_SetOnlineStatusInput = {
  onlineStatus: enum_OnlineStatus,
  recursed: option<input_RecursiveSetOnlineStatusInput>,
}

@live
and input_SetOnlineStatusInput_nullable = {
  onlineStatus: enum_OnlineStatus,
  recursed?: Js.Null.t<input_RecursiveSetOnlineStatusInput_nullable>,
}

@live
and input_PesticideListSearchInput = {
  companyName: option<array<string>>,
  pesticideIds: option<array<int>>,
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
