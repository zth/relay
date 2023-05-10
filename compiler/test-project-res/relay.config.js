module.exports = {
  src : "./src",
  schema : "./schema.graphql",
  artifactDirectory : "./src/__generated__",
  customScalars : {Datetime : "SomeModule.Datetime", Timestamp : "Timestamp.t"},
  language : "rescript",
  featureFlags : {enable_relay_resolver_transform : true}
};
