/**
 * @RelayResolver UserMeta
 * @weak
 */
type userMeta = {
  name: string,
  age: int,
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
 * @RelayResolver User.friendCount: Int
 * @live
 */
let friendCount = user => {
  1
}
