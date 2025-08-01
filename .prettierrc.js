/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @format
 * @oncall relay
 */

module.exports = {
  arrowParens: 'avoid',
  bracketSameLine: true,
  bracketSpacing: false,
  requirePragma: true,
  singleQuote: true,
  trailingComma: 'all',
  parser: 'hermes',
  plugins: [
    // Using module.parent and createRequire hack to simulate prettier v2 plugin resolution behavior.
    // The hack allows us to resolve the plugin from the install location of prettier.
    (module.parent
      ? require('module').createRequire(module.parent.id)
      : require
    ).resolve('prettier-plugin-hermes-parser'),
  ],
};
