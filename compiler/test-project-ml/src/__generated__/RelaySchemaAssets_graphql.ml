(* @generated *)
[@@@ocaml.warning "-30"]


type enum_OnlineStatus = private [>
  | `Online
  | `Idle
  | `Offline
]


type enum_OnlineStatus_input = [
  | `Online
  | `Idle
  | `Offline
]


type enum_RequiredFieldAction = private [>
  | `NONE
  | `LOG
  | `THROW
]


type enum_RequiredFieldAction_input = [
  | `NONE
  | `LOG
  | `THROW
]


type  input_InputA = {
  time: SomeModule.Datetime.t,
  recursiveA: option<input_InputA>,
  usingB: option<input_InputB>,
  timestamp: option<Timestamp.t>,
  timestamps: option<array<option<Timestamp.t>>>,
  unmapped: option<RescriptRelay.any>,
}

and input_InputA_nullable = {
  time: SomeModule.Datetime.t,
  recursiveA?: Js.Null.t<input_InputA_nullable>,
  usingB?: Js.Null.t<input_InputB_nullable>,
  timestamp?: Js.Null.t<Timestamp.t>,
  timestamps?: Js.Null.t<array<Js.Null.t<Timestamp.t>>>,
  unmapped?: Js.Null.t<RescriptRelay.any>,
}

and input_InputB = {
  time: option<SomeModule.Datetime.t>,
  usingA: option<input_InputA>,
  [@bs.as "constraint"] constraint_: option<bool>,
}

and input_InputB_nullable = {
  time?: Js.Null.t<SomeModule.Datetime.t>,
  usingA?: Js.Null.t<input_InputA_nullable>,
  [@bs.as "constraint"] constraint_?: Js.Null.t<bool>,
}

and input_SomeInput = {
  str: option<string>,
  bool: option<bool>,
  float: option<float>,
  int: option<int>,
  datetime: option<SomeModule.Datetime.t>,
  recursive: option<input_SomeInput>,
  [@bs.as "private"] private_: option<bool>,
}

and input_SomeInput_nullable = {
  str?: Js.Null.t<string>,
  bool?: Js.Null.t<bool>,
  float?: Js.Null.t<float>,
  int?: Js.Null.t<int>,
  datetime?: Js.Null.t<SomeModule.Datetime.t>,
  recursive?: Js.Null.t<input_SomeInput_nullable>,
  [@bs.as "private"] private_?: Js.Null.t<bool>,
}

and input_RecursiveSetOnlineStatusInput = {
  someValue: RescriptRelay.any,
  setOnlineStatus: option<input_SetOnlineStatusInput>,
}

and input_RecursiveSetOnlineStatusInput_nullable = {
  someValue: RescriptRelay.any,
  setOnlineStatus?: Js.Null.t<input_SetOnlineStatusInput_nullable>,
}

and input_SetOnlineStatusInput = {
  onlineStatus: [#Online | #Idle | #Offline],
  recursed: option<input_RecursiveSetOnlineStatusInput>,
}

and input_SetOnlineStatusInput_nullable = {
  onlineStatus: [#Online | #Idle | #Offline],
  recursed?: Js.Null.t<input_RecursiveSetOnlineStatusInput_nullable>,
}

and input_PesticideListSearchInput = {
  companyName: option<array<string>>,
  pesticideIds: option<array<int>>,
  skip: int,
  take: int,
}

and input_PesticideListSearchInput_nullable = {
  companyName?: Js.Null.t<array<string>>,
  pesticideIds?: Js.Null.t<array<int>>,
  skip: int,
  take: int,
}
external make_InputA: (
  ~time: SomeModule.Datetime.t,
  ~recursiveA: input_InputA=?,
  ~usingB: input_InputB=?,
  ~timestamp: Timestamp.t=?,
  ~timestamps: array<option<Timestamp.t>>=?,
  ~unmapped: RescriptRelay.any=?,
  unit,
) -> input_InputA = "" [@@bs.obj]

external make_InputB: (
  ~time: SomeModule.Datetime.t=?,
  ~usingA: input_InputA=?,
  ~_constraint: bool=?,
  unit,
) -> input_InputB = "" [@@bs.obj]

external make_SomeInput: (
  ~str: string=?,
  ~bool: bool=?,
  ~float: float=?,
  ~int: int=?,
  ~datetime: SomeModule.Datetime.t=?,
  ~recursive: input_SomeInput=?,
  ~_private: bool=?,
  unit,
) -> input_SomeInput = "" [@@bs.obj]

external make_RecursiveSetOnlineStatusInput: (
  ~someValue: RescriptRelay.any,
  ~setOnlineStatus: input_SetOnlineStatusInput=?,
  unit,
) -> input_RecursiveSetOnlineStatusInput = "" [@@bs.obj]

external make_SetOnlineStatusInput: (
  ~onlineStatus: [#Online | #Idle | #Offline],
  ~recursed: input_RecursiveSetOnlineStatusInput=?,
  unit,
) -> input_SetOnlineStatusInput = "" [@@bs.obj]

external make_PesticideListSearchInput: (
  ~companyName: array<string>=?,
  ~pesticideIds: array<int>=?,
  ~skip: int,
  ~take: int,
  unit,
) -> input_PesticideListSearchInput = "" [@@bs.obj]
