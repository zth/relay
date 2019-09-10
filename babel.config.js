module.exports = require('./scripts/getBabelOptions')({
  ast: false,
  plugins: [
    '@babel/plugin-transform-flow-strip-types',
    '@babel/plugin-transform-runtime',
    '@babel/plugin-proposal-nullish-coalescing-operator',
    '@babel/plugin-proposal-optional-catch-binding',
    '@babel/plugin-proposal-optional-chaining',
  ],
  postPlugins: [
    '@babel/plugin-transform-async-to-generator',
    '@babel/plugin-transform-modules-commonjs',
  ],
  sourceType: 'script',
});
