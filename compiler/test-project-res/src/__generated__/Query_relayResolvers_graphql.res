/* @generated */
@@warning("-30")

type timeResolverArgs = {
  now: option<bool>,
}
type timeResolver = (timeResolverArgs) => option<string>

type localUserResolver = () => option<RescriptRelay.dataIdObject>

