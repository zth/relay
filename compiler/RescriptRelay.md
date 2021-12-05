# RescriptRelay Relay compiler fork

## Changes made

### Piggy back on the `Flow` typegen
* Replace it looking for `js`/`jsx` files with looking for `res`
* Generate `<moduleName>_graphql.res` for artifacts instead of `<moduleName>.graphql.js`
* Look for `%relay()` extension points instead of `graphql` to extract GraphQL operation information
* Generate refetchable operation require's as `node_<moduleName>` instead of `require('./<moduleName>.graphql.js')`. This matches how we then leverage the ReScript compiler to ensure requires work with both es6 and commonjs (elaborate on this).