/**
 * @RelayResolver User.greeting:String
 *
 * @rootFragment TestRelayResolver
 *
 * A greeting for the user which includes their name.
 */

type t = string

module Fragment = %relay(`
  fragment TestRelayResolver on User {
    firstName
    lastName
  }
`);

let default = Fragment.makeRelayResolver(user => {
  switch user {
    | {firstName: Some(firstName), lastName: Some(lastName)} => Some(`${firstName} ${lastName}`)
    | _ => None
  }
})