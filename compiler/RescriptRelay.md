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
* [x] Make interfacing with `RescriptRelayBin.exe` work
* [x] Handle `Query.load`
* [x] Add validation that disallows selecting invalid ReScript names
* [ ] Add transforms that automatically insert `__typename` on interfaces and unions in the type selection, without the user needing to know
* [x] Handle refetchable nodes
* [ ] Handle connections
* [x] Emit `@sourceLoc`
* [x] Print operation type
