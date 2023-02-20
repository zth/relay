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
  time: Js.Null.t<SomeModule.Datetime.t>,
  recursiveA?: Js.Null.t<input_InputA>,
  usingB?: Js.Null.t<input_InputB>,
  timestamp?: Js.Null.t<Timestamp.t>,
  timestamps?: Js.Null.t<array<Js.Null.t<Timestamp.t>>>,
  unmapped?: Js.Null.t<RescriptRelay.any>,
}

@live
and input_InputB = {
  time?: Js.Null.t<SomeModule.Datetime.t>,
  usingA?: Js.Null.t<input_InputA>,
  @as("constraint") constraint_?: Js.Null.t<bool>,
}

@live
and input_SomeInput = {
  str?: Js.Null.t<string>,
  bool?: Js.Null.t<bool>,
  float?: Js.Null.t<float>,
  int?: Js.Null.t<int>,
  datetime?: Js.Null.t<SomeModule.Datetime.t>,
  recursive?: Js.Null.t<input_SomeInput>,
  @as("private") private_?: Js.Null.t<bool>,
}

@live
and input_RecursiveSetOnlineStatusInput = {
  someValue: Js.Null.t<RescriptRelay.any>,
  setOnlineStatus?: Js.Null.t<input_SetOnlineStatusInput>,
}

@live
and input_SetOnlineStatusInput = {
  onlineStatus: Js.Null.t<[#Online | #Idle | #Offline]>,
  recursed?: Js.Null.t<input_RecursiveSetOnlineStatusInput>,
}

@live
and input_PesticideListSearchInput = {
  companyName?: Js.Null.t<array<Js.Null.t<string>>>,
  pesticideIds?: Js.Null.t<array<Js.Null.t<int>>>,
  skip: Js.Null.t<int>,
  take: Js.Null.t<int>,
}
@live @obj
external make_InputA: (
  ~time: SomeModule.Datetime.t,
  ~recursiveA: Js.Null.t<input_InputA>=?,
  ~usingB: Js.Null.t<input_InputB>=?,
  ~timestamp: Js.Null.t<Timestamp.t>=?,
  ~timestamps: Js.Null.t<array<Js.Null.t<Timestamp.t>>>=?,
  ~unmapped: Js.Null.t<RescriptRelay.any>=?,
  unit,
) => input_InputA = ""

@live @obj
external make_InputB: (
  ~time: Js.Null.t<SomeModule.Datetime.t>=?,
  ~usingA: Js.Null.t<input_InputA>=?,
  ~_constraint: Js.Null.t<bool>=?,
  unit,
) => input_InputB = ""

@live @obj
external make_SomeInput: (
  ~str: Js.Null.t<string>=?,
  ~bool: Js.Null.t<bool>=?,
  ~float: Js.Null.t<float>=?,
  ~int: Js.Null.t<int>=?,
  ~datetime: Js.Null.t<SomeModule.Datetime.t>=?,
  ~recursive: Js.Null.t<input_SomeInput>=?,
  ~_private: Js.Null.t<bool>=?,
  unit,
) => input_SomeInput = ""

@live @obj
external make_RecursiveSetOnlineStatusInput: (
  ~someValue: RescriptRelay.any,
  ~setOnlineStatus: Js.Null.t<input_SetOnlineStatusInput>=?,
  unit,
) => input_RecursiveSetOnlineStatusInput = ""

@live @obj
external make_SetOnlineStatusInput: (
  ~onlineStatus: [#Online | #Idle | #Offline],
  ~recursed: Js.Null.t<input_RecursiveSetOnlineStatusInput>=?,
  unit,
) => input_SetOnlineStatusInput = ""

@live @obj
external make_PesticideListSearchInput: (
  ~companyName: Js.Null.t<array<Js.Null.t<string>>>=?,
  ~pesticideIds: Js.Null.t<array<Js.Null.t<int>>>=?,
  ~skip: int,
  ~take: int,
  unit,
) => input_PesticideListSearchInput = ""

