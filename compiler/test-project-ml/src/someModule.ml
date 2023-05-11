module Datetime = struct
  type t
  external serialize: t -> string = "%identity"
  external parse:  string -> t = "%identity"
end
