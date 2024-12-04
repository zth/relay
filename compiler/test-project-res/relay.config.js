module.exports = {
  src: "./src",
  schema: "./schema.graphql",
  artifactDirectory: "./src/__generated__",
  customScalarTypes: {
    Datetime: "SomeModule.Datetime",
    Timestamp: "Timestamp.t"
  },
  schemaExtensions: ["./schemaExtensions"],
  inputUnions: ["LocationWithoutDirective"]
};
