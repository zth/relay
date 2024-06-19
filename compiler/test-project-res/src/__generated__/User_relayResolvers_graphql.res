/* @generated */
@@warning("-30")

type greetingResolver = () => option<string>

type metaResolverArgs = {
  status: enum_OnlineStatus_input,
}
type metaResolver = (metaResolverArgs) => option<RelayUserMetaModel.t>

type friendCountResolver = () => RescriptRelay.liveState<option<int>>

