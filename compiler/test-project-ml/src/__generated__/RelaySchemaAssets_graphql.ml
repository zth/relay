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
  time: SomeModule.Datetime.t;
  recursiveA: input_InputA option;
  usingB: input_InputB option;
  timestamp: Timestamp.t option;
  timestamps: Timestamp.t option array option;
  unmapped: Melange_relay.any option;
}

and input_InputA_nullable = {
  time: SomeModule.Datetime.t;
  recursiveA: input_InputA_nullable Js.Null.t option [@bs.optional];
  usingB: input_InputB_nullable Js.Null.t option [@bs.optional];
  timestamp: Timestamp.t Js.Null.t option [@bs.optional];
  timestamps: Timestamp.t Js.Null.t array Js.Null.t option [@bs.optional];
  unmapped: Melange_relay.any Js.Null.t option [@bs.optional];
}

and input_InputB = {
  time: SomeModule.Datetime.t option;
  usingA: input_InputA option;
  constraint_: bool option [@bs.as "constraint"];
}

and input_InputB_nullable = {
  time: SomeModule.Datetime.t Js.Null.t option [@bs.optional];
  usingA: input_InputA_nullable Js.Null.t option [@bs.optional];
  constraint_: bool Js.Null.t [@bs.as "constraint"] option [@bs.optional];
}

and input_SomeInput = {
  str: string option;
  bool: bool option;
  float: float option;
  int: int option;
  datetime: SomeModule.Datetime.t option;
  recursive: input_SomeInput option;
  private_: bool option [@bs.as "private"];
}

and input_SomeInput_nullable = {
  str: string Js.Null.t option [@bs.optional];
  bool: bool Js.Null.t option [@bs.optional];
  float: float Js.Null.t option [@bs.optional];
  int: int Js.Null.t option [@bs.optional];
  datetime: SomeModule.Datetime.t Js.Null.t option [@bs.optional];
  recursive: input_SomeInput_nullable Js.Null.t option [@bs.optional];
  private_: bool Js.Null.t [@bs.as "private"] option [@bs.optional];
}

and input_RecursiveSetOnlineStatusInput = {
  someValue: Melange_relay.any;
  setOnlineStatus: input_SetOnlineStatusInput option;
}

and input_RecursiveSetOnlineStatusInput_nullable = {
  someValue: Melange_relay.any;
  setOnlineStatus: input_SetOnlineStatusInput_nullable Js.Null.t option [@bs.optional];
}

and input_SetOnlineStatusInput = {
  onlineStatus: [`Online | `Idle | `Offline];
  recursed: input_RecursiveSetOnlineStatusInput option;
}

and input_SetOnlineStatusInput_nullable = {
  onlineStatus: [`Online | `Idle | `Offline];
  recursed: input_RecursiveSetOnlineStatusInput_nullable Js.Null.t option [@bs.optional];
}

and input_PesticideListSearchInput = {
  companyName: string array option;
  pesticideIds: int array option;
  skip: int;
  take: int;
}

and input_PesticideListSearchInput_nullable = {
  companyName: string array Js.Null.t option [@bs.optional];
  pesticideIds: int array Js.Null.t option [@bs.optional];
  skip: int;
  take: int;
}
 [@@deriving abstract]
external make_InputA: 
  time: SomeModule.Datetime.t -> 
  ?recursiveA: input_InputA -> 
  ?usingB: input_InputB -> 
  ?timestamp: Timestamp.t -> 
  ?timestamps: Timestamp.t option array -> 
  ?unmapped: Melange_relay.any -> 
  unit
 -> input_InputA = "" [@@bs.obj]

external make_InputB: 
  ?time: SomeModule.Datetime.t -> 
  ?usingA: input_InputA -> 
  ?_constraint: bool -> 
  unit
 -> input_InputB = "" [@@bs.obj]

external make_SomeInput: 
  ?str: string -> 
  ?bool: bool -> 
  ?float: float -> 
  ?int: int -> 
  ?datetime: SomeModule.Datetime.t -> 
  ?recursive: input_SomeInput -> 
  ?_private: bool -> 
  unit
 -> input_SomeInput = "" [@@bs.obj]

external make_RecursiveSetOnlineStatusInput: 
  someValue: Melange_relay.any -> 
  ?setOnlineStatus: input_SetOnlineStatusInput -> 
  unit
 -> input_RecursiveSetOnlineStatusInput = "" [@@bs.obj]

external make_SetOnlineStatusInput: 
  onlineStatus: [`Online | `Idle | `Offline] -> 
  ?recursed: input_RecursiveSetOnlineStatusInput -> 
  unit
 -> input_SetOnlineStatusInput = "" [@@bs.obj]

external make_PesticideListSearchInput: 
  ?companyName: string array -> 
  ?pesticideIds: int array -> 
  skip: int -> 
  take: int -> 
  unit
 -> input_PesticideListSearchInput = "" [@@bs.obj]

