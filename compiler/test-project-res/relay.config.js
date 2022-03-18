module.exports = {
  src: "./src",
  schema: "./schema.graphql",
  language: "rescript",
  artifactDirectory: "./src/__generated__",
  customScalars: {
    Datetime: "SomeModule.Datetime",
  },
  featureFlags: {
    enable_relay_resolver_transform: true
  }
};
