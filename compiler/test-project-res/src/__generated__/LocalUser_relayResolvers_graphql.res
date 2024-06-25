/* @generated */
@@warning("-30")

type nameResolver = (RelayLocalUserModel.t, ) => string

type bestFriendResolverArgs = {
  from: option<Timestamp.t>,
}
type bestFriendResolver = (RelayLocalUserModel.t, bestFriendResolverArgs) => RescriptRelay.dataIdObject

type favoriteColorsResolver = (RelayLocalUserModel.t, ) => array<string>

type metaResolver = (RelayLocalUserModel.t, ) => RelayUserMetaModel.t

