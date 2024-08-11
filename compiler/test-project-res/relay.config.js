module.exports = {
  src: "./src",
  schema: "./schema.graphql",
  artifactDirectory: "./src/__generated__",
  customScalarTypes: {
    Datetime: "SomeModule.Datetime",
    Timestamp: "Timestamp.t"
  },
  featureFlags: {
    enable_relay_resolver_transform: true,
    enable_fragment_aliases: {
      kind: "enabled"
    }
  },
  schemaExtensions: ["./schemaExtensions"],
  inputUnions: ["LocationWithoutDirective"]
};
