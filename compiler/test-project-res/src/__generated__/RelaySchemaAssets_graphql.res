/* @generated */
@@ocaml.warning("-30")

@live
type enum_OnlineStatus = private [>
  | #Online
  | #Idle
  | #Offline
]

@live
type enum_OnlineStatus_input = [
  | #Online
  | #Idle
  | #Offline
]

@live
type enum_RequiredFieldAction = private [>
  | #NONE
  | #LOG
  | #THROW
]

@live
type enum_RequiredFieldAction_input = [
  | #NONE
  | #LOG
  | #THROW
]

@live
type rec input_InputA = {
  time: SomeModule.Datetime.t,
  recursiveA: option<input_InputA>,
  usingB: option<input_InputB>,
  timestamp: option<Timestamp.t>,
  unmapped: option<RescriptRelay.any>,
}

@live
and input_InputB = {
  time: option<SomeModule.Datetime.t>,
  usingA: option<input_InputA>,
  @as("constraint") constraint_: option<bool>,
}

@live
and input_SomeInput = {
  str: option<string>,
  bool: option<bool>,
  float: option<float>,
  int: option<int>,
  datetime: option<SomeModule.Datetime.t>,
  recursive: option<input_SomeInput>,
}

@live
and input_RecursiveSetOnlineStatusInput = {
  someValue: RescriptRelay.any,
  setOnlineStatus: option<input_SetOnlineStatusInput>,
}

@live
and input_SetOnlineStatusInput = {
  onlineStatus: [#Online | #Idle | #Offline],
  recursed: option<input_RecursiveSetOnlineStatusInput>,
}

@live
and input_PesticideListSearchInput = {
  companyName: option<array<string>>,
  pesticideIds: option<array<int>>,
  skip: int,
  take: int,
}
@live @obj
external make_InputA: (
  ~time: SomeModule.Datetime.t,
  ~recursiveA: input_InputA=?,
  ~usingB: input_InputB=?,
  ~timestamp: Timestamp.t=?,
  ~unmapped: RescriptRelay.any=?,
  unit,
) => input_InputA = ""

@live @obj
external make_InputB: (
  ~time: SomeModule.Datetime.t=?,
  ~usingA: input_InputA=?,
  ~_constraint: bool=?,
  unit,
) => input_InputB = ""

@live @obj
external make_SomeInput: (
  ~str: string=?,
  ~bool: bool=?,
  ~float: float=?,
  ~int: int=?,
  ~datetime: SomeModule.Datetime.t=?,
  ~recursive: input_SomeInput=?,
  unit,
) => input_SomeInput = ""

@live @obj
external make_RecursiveSetOnlineStatusInput: (
  ~someValue: RescriptRelay.any,
  ~setOnlineStatus: input_SetOnlineStatusInput=?,
  unit,
) => input_RecursiveSetOnlineStatusInput = ""

@live @obj
external make_SetOnlineStatusInput: (
  ~onlineStatus: [#Online | #Idle | #Offline],
  ~recursed: input_RecursiveSetOnlineStatusInput=?,
  unit,
) => input_SetOnlineStatusInput = ""

@live @obj
external make_PesticideListSearchInput: (
  ~companyName: array<string>=?,
  ~pesticideIds: array<int>=?,
  ~skip: int,
  ~take: int,
  unit,
) => input_PesticideListSearchInput = ""

