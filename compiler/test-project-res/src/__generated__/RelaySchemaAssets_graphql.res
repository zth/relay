/* @generated */
@@ocaml.warning("-30")

type enum_OnlineStatus = private [>
  | #Online
  | #Idle
  | #Offline
]

type enum_OnlineStatus_input = [
  | #Online
  | #Idle
  | #Offline
]

type enum_RequiredFieldAction = private [>
  | #NONE
  | #LOG
  | #THROW
]

type enum_RequiredFieldAction_input = [
  | #NONE
  | #LOG
  | #THROW
]

type rec input_InputA = {
  time: Datetime.t,
  recursiveA: option<input_InputA>,
  usingB: option<input_InputB>,
}
and input_InputB = {
  time: option<Datetime.t>,
  usingA: option<input_InputA>,
  @as("constraint") constraint_: option<bool>,
}
and input_SomeInput = {
  str: option<string>,
  bool: option<bool>,
  float: option<float>,
  int: option<int>,
  recursive: option<input_SomeInput>,
}
and input_RecursiveSetOnlineStatusInput = {
  someValue: IntString.t,
  setOnlineStatus: option<input_SetOnlineStatusInput>,
}
and input_SetOnlineStatusInput = {
  onlineStatus: [#Online | #Idle | #Offline],
  recursed: option<input_RecursiveSetOnlineStatusInput>,
}
and input_PesticideListSearchInput = {
  companyName: option<array<string>>,
  pesticideIds: option<array<int>>,
  skip: int,
  take: int,
}
@obj external make_InputA: (
  ~time: Datetime.t,
  ~recursiveA: input_InputA=?,
  ~usingB: input_InputB=?,
  unit,
) => input_InputA = ""

@obj external make_InputB: (
  ~time: Datetime.t=?,
  ~usingA: input_InputA=?,
  ~_constraint: bool=?,
  unit,
) => input_InputB = ""

@obj external make_SomeInput: (
  ~str: string=?,
  ~bool: bool=?,
  ~float: float=?,
  ~int: int=?,
  ~recursive: input_SomeInput=?,
  unit,
) => input_SomeInput = ""

@obj external make_RecursiveSetOnlineStatusInput: (
  ~someValue: IntString.t,
  ~setOnlineStatus: input_SetOnlineStatusInput=?,
  unit,
) => input_RecursiveSetOnlineStatusInput = ""

@obj external make_SetOnlineStatusInput: (
  ~onlineStatus: [#Online | #Idle | #Offline],
  ~recursed: input_RecursiveSetOnlineStatusInput=?,
  unit,
) => input_SetOnlineStatusInput = ""

@obj external make_PesticideListSearchInput: (
  ~companyName: array<string>=?,
  ~pesticideIds: array<int>=?,
  ~skip: int,
  ~take: int,
  unit,
) => input_PesticideListSearchInput = ""

