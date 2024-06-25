/**
 * @RelayResolver UserMeta
 * @weak
 */
type userMeta = {
  name: string,
  age: int,
  online: bool,
}

/**
 * @RelayResolver UserMeta.online: Boolean
 */
let online = (userMeta: RelayUserMetaModel.t) => {
  userMeta.online->Some
}

/**
 * @RelayResolver LocalUser
 */
let localUser = dataId => {
  UserService.getById(dataId)
}

/**
 * @RelayResolver Query.time(now: Boolean): String
 */
let time = () => "hello"

/**
 * @RelayResolver LocalUser.name: String
 */
let name = (user: RelayLocalUserModel.t) => {
  Some(user.name)
}

/**
 * @RelayResolver LocalUser.bestFriend(from: Timestamp): LocalUser
 */
let bestFriend = () => "hello"

/**
 * @RelayResolver UserMeta.greeting(show: Boolean!): String
 */
let greeting = () => "hello"

/**
 * @RelayResolver User.meta(status: OnlineStatus!): UserMeta
 */
let meta = () => "hello"

/**
 * @RelayResolver LocalUser.favoriteColors: [String!]
 */
let favoriteColors = user => {
  []
}

/**
 * @RelayResolver LocalUser.meta: UserMeta
 */
let meta = (user: RelayLocalUserModel.t): option<RelayUserMetaModel.t> => {
  Some({
    online: user.name === "Test User",
  })
}

/**
 * @RelayResolver User.friendCount: Int
 * @live
 */
let friendCount = user => {
  1
}

/**
 * @RelayResolver Query.localUser: LocalUser
 */
let localUser = (): option<RescriptRelay.dataIdObject> => {
  Some({
    id: "local-user-1"->RescriptRelay.makeDataId,
  })
}
