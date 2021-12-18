# RescriptRelay Relay compiler fork

## Changes made

### Piggy back on the `Flow` typegen
* Replace it looking for `js`/`jsx` files with looking for `res`.
* Generate `<moduleName>_graphql.res` for artifacts instead of `<moduleName>.graphql.js`.
* Look for `%relay()` extension points instead of `graphql` to extract GraphQL operation information.
* Generate refetchable operation require's as `node_<moduleName>` instead of `require('./<moduleName>.graphql.js')`. This matches how we then leverage the ReScript compiler to ensure requires work with both es6 and commonjs (elaborate on this).
* Outputs "int" and "float" instead of "number" in scalar typegen.

### Structure
* Trying to reduce the amount of actual code touched in the compiler
* Any fn/method that is altered in a significant way should be copied, so the original can live on next to the new one, to ease maintaining the fork
* Put anything that's possible to put in its own module, again to make maintenance easier

## TODO:
* [x] Print connection utils
* [x] Transform ID on things passed into $connections on store directives to `RescriptRelay.dataId`
* [ ] Handle top level node field special treatment


## Changes
* `makeOptimisticResponse` is now only printed if there's a `@raw_response_type` annotation on a mutation. And it's only printed for one level, not all levels as previously.