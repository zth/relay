module.exports = {
  src: "./src",
  schema: "./schema.graphql",
  language: "rescript",
  artifactDirectory: "./src/__generated__",
  customScalars: {
    Datetime: "SomeModule.Datetime",
  },
};
