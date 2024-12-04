module.exports = {
  src: "./src",
  schema: "../test-project-res/schema.graphql",
  artifactDirectory: "./src/__generated__",
  customScalarTypes: {
    Datetime: "SomeModule.Datetime",
    Timestamp: "Timestamp.t"
  },
  persistConfig: {
    file: "./persisted_queries.json",
    algorithm: "MD5" // this can be one of MD5, SHA256, SHA1
  }
};
