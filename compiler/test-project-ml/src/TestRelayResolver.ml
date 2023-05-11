(**
 * @RelayResolver
 *
 * @onType User
 * @fieldName greeting
 * @rootFragment TestRelayResolver
 *
 * A greeting for the user which includes their name.
 *)

type t = string

module Fragment = [%relay{|
  fragment TestRelayResolver on User {
    firstName
    lastName
  }
|}]

let default = Fragment.makeRelayResolver (function
    | { firstName; lastName} ->
      Some {|${firstName} ${lastName}|}
    | _ -> None
  )
