/* @generated */
@@warning("-30")

type greetingResolver = () => string

type metaResolverArgs = {
  status: enum_OnlineStatus_input,
}
type metaResolver = (metaResolverArgs) => RelayUserMetaModel.t

type friendCountResolver = () => RescriptRelay.liveState<int>

