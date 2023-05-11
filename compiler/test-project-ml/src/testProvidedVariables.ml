module Datetime = struct
  let get () = None
end
module Datetimes = struct
  let get () = Some [||]
end
module Bool = struct
  let get () = false
end

module Float = struct
  let get () = 0.0
end

module Int = struct
  let get () = None
end

module ID = struct
  let get () = Some "42"
end

module Str = struct
  let get () = ""
end

module InputB = struct
  let get () = RelaySchemaAssets_graphql.make_InputB ()
end

module SomeInput = struct
  let get () = RelaySchemaAssets_graphql.make_SomeInput ()
end
