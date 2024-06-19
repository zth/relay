/* @generated */
@@warning("-30")

type nameResolver = (RelayLocalUserModel.t, ) => option<string>

type bestFriendResolverArgs = {
  from: option<Timestamp.t>,
}
type bestFriendResolver = (RelayLocalUserModel.t, bestFriendResolverArgs) => option<RescriptRelay.dataIdObject>

type favoriteColorsResolver = (RelayLocalUserModel.t, ) => option<array<string>>

type metaResolver = (RelayLocalUserModel.t, ) => option<RelayUserMetaModel.t>

