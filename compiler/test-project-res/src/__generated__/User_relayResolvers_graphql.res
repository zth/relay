/* @generated */
@@warning("-30")

type greetingResolver = (RescriptRelay.fragmentRefs<[> | #TestRelayResolver]>, ) => string

type metaResolverArgs = {
  status: enum_OnlineStatus_input,
}
type metaResolver = (metaResolverArgs) => RelayUserMetaModel.t

type friendCountResolver = () => RescriptRelay.liveState<int>

type fancyGreetingResolverArgs = {
  includeFull2: option<bool>,
  includeFull: option<bool>,
}
type fancyGreetingResolver = (RescriptRelay.fragmentRefs<[> | #TestRelayResolverMultiFancyGreeting]>, fancyGreetingResolverArgs) => string

