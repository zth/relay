---
id: network-layer
title: Network Layer
slug: /guides/network-layer/
description: Relay guide to the network layer
keywords:
- network
- caching
---

import DocsRating from '@site/src/core/DocsRating';

In order to know how to access your GraphQL server, Relay requires developers to provide an object implementing the `INetwork` interface when creating an instance of a [Relay Environment](../api-reference/relay-runtime/relay-environment.md). The environment uses this network layer to execute queries, mutations, and (if your server supports them) subscriptions. This allows developers to use whatever transport (HTTP, WebSockets, etc) and authentication is most appropriate for their application, decoupling the environment from the particulars of each application's network configuration.

Currently the easiest way to create a network layer is via a helper from the `relay-runtime` package:

```javascript
import {
  Environment,
  Network,
  RecordSource,
  Store,
} from 'relay-runtime';

// Define a function that fetches the results of an operation (query/mutation/etc)
// and returns its results as a Promise:
function fetchQuery(
  operation,
  variables,
  cacheConfig,
  uploadables,
) {
  return fetch('/graphql', {
    method: 'POST',
    headers: {
      // Add authentication and other headers here
      'content-type': 'application/json'
    },
    body: JSON.stringify({
      query: operation.text, // GraphQL text from input
      variables,
    }),
  }).then(response => {
    return response.json();
  });
}

// Create a network layer from the fetch function
const network = Network.create(fetchQuery);
const store = new Store(new RecordSource())

const environment = new Environment({
  network,
  store
  // ... other options
});

export default environment;
```

:::warning
This is just a basic example to help you get started. Features like `@stream`, `@defer` or Persisted Queries will require additional logic be added to your `fetchQuery` function.
:::

## Advanced Network Layer

The network layer provides a place for developers to customize the data fetching behaviors. For example, adding network level caching, telemetry or support for uploading form data for mutations.

<DocsRating />
