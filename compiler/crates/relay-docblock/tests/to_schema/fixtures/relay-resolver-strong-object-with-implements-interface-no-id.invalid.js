/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

// expected-to-throw

/**
 * @RelayResolver ClientUser implements IFoo
 */

// %extensions%

graphql`

interface IFoo {
  not_id: ID!
}
`
