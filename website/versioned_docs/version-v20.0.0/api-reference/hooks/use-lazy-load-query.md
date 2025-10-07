---
id: use-lazy-load-query
title: useLazyLoadQuery
slug: /api-reference/use-lazy-load-query/
description: API reference for useLazyLoadQuery, a React hook used to lazily fetch query data when a component renders
keywords:
  - lazy fetching
  - query
  - fetch
---

import DocsRating from '@site/src/core/DocsRating';

## `useLazyLoadQuery`

Hook used to fetch a GraphQL query during render. This hook can trigger multiple nested or waterfalling round trips if used without caution, and waits until render to start a data fetch (when it can usually start a lot sooner than render), thereby degrading performance. Instead, prefer [`usePreloadedQuery`](../use-preloaded-query).

```js
const React = require('React');

const {graphql, useLazyLoadQuery} = require('react-relay');

function App() {
  const data = useLazyLoadQuery(
    graphql`
      query AppQuery($id: ID!) {
        user(id: $id) {
          name
        }
      }
    `,
    {id: 4},
    {fetchPolicy: 'store-or-network'},
  );

 return <h1>{data.user?.name}</h1>;
}
```

### Arguments

* `gqlQuery`: GraphQL query specified using a `graphql` template literal.
* `variables`: Object containing the variable values to fetch the query. These variables need to match GraphQL variables declared inside the query.
* `options`: _*[Optional]*_ options object
  * `fetchPolicy`: _*[Optional]*_ Determines if cached data should be used, and when to send a network request based on the cached data that is currently available in the Relay store (for more details, see our [Fetch Policies](../../guided-tour/reusing-cached-data/fetch-policies) and [Garbage Collection](../../guided-tour/reusing-cached-data/presence-of-data) guides):
     * "store-or-network": _*(default)*_ *will* reuse locally cached data and will *only* send a network request if any data for the query is missing. If the query is fully cached, a network request will *not* be made.
     * "store-and-network": *will* reuse locally cached data and will *always* send a network request, regardless of whether any data was missing from the local cache or not.
     * "network-only": *will* *not* reuse locally cached data, and will *always* send a network request to fetch the query, ignoring any data that might be locally cached in Relay.
     * "store-only": *will* *only* reuse locally cached data, and will *never* send a network request to fetch the query. In this case, the responsibility of fetching the query falls to the caller, but this policy could also be used to read and operate on data that is entirely [local](../../guided-tour/updating-data/local-data-updates).
  * `fetchKey`: _*[Optional]*_ A `fetchKey` can be passed to force a re-evaluation of the current query and variables when the component re-renders, even if the variables didn't change, or even if the component isn't remounted (similarly to how passing a different `key` to a React component will cause it to remount). If the `fetchKey` is different from the one used in the previous render, the current query will be re-evaluated against the store, and it might be refetched depending on the current `fetchPolicy` and the state of the cache.
  * `networkCacheConfig`: _*[Optional]*_ Default value: `{force: true}`. Object containing cache config options for the *network layer*. Note that the network layer may contain an *additional* query response cache which will reuse network responses for identical queries. If you want to bypass this cache completely (which is the default behavior), pass `{force: true}` as the value for this option.
  * `UNSTABLE_renderPolicy`: _*[Optional]*_ Undocumented option.

### Return Value

- `data`: Object that contains data which has been read out from the Relay store; the object matches the shape of specified query.
  - The Flow type for data will also match this shape, and contain types derived from the GraphQL Schema. For example, the type of `data` above is: `{| user: ?{| name: ?string |} |}`.

import UseLazyLoadQueryExtra from './_use-lazy-load-query-extra.md';

<UseLazyLoadQueryExtra />
<DocsRating />
