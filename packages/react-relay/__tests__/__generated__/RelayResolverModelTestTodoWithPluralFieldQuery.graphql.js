/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @oncall relay
 *
 * @generated SignedSource<<7988babd91358bfdac8e6b7cc9790ec9>>
 * @flow
 * @lightSyntaxTransform
 * @nogrep
 */

/* eslint-disable */

'use strict';

/*::
import type { ClientRequest, ClientQuery } from 'relay-runtime';
import type { RelayResolverModelTestWithPluralFragment$fragmentType } from "./RelayResolverModelTestWithPluralFragment.graphql";
import {todo_model as queryTodoModelResolverType} from "../../../relay-runtime/store/__tests__/resolvers/QueryTodoModel.js";
// Type assertion validating that `queryTodoModelResolverType` resolver is correctly implemented.
// A type error here indicates that the type signature of the resolver module is incorrect.
(queryTodoModelResolverType: (
  args: {|
    todoID: string,
  |}, 
) => mixed);
export type RelayResolverModelTestTodoWithPluralFieldQuery$variables = {|
  id: string,
|};
export type RelayResolverModelTestTodoWithPluralFieldQuery$data = {|
  +todo_model: ?{|
    +$fragmentSpreads: RelayResolverModelTestWithPluralFragment$fragmentType,
  |},
|};
export type RelayResolverModelTestTodoWithPluralFieldQuery = {|
  response: RelayResolverModelTestTodoWithPluralFieldQuery$data,
  variables: RelayResolverModelTestTodoWithPluralFieldQuery$variables,
|};
*/

var node/*: ClientRequest*/ = (function(){
var v0 = [
  {
    "defaultValue": null,
    "kind": "LocalArgument",
    "name": "id"
  }
],
v1 = [
  {
    "kind": "Variable",
    "name": "todoID",
    "variableName": "id"
  }
],
v2 = {
  "alias": null,
  "args": null,
  "kind": "ScalarField",
  "name": "id",
  "storageKey": null
},
v3 = {
  "kind": "InlineFragment",
  "selections": [
    {
      "alias": null,
      "args": null,
      "kind": "ScalarField",
      "name": "__relay_model_instance",
      "storageKey": null
    }
  ],
  "type": "TodoDescription",
  "abstractKey": null
};
return {
  "fragment": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Fragment",
    "metadata": {
      "hasClientEdges": true
    },
    "name": "RelayResolverModelTestTodoWithPluralFieldQuery",
    "selections": [
      {
        "kind": "ClientEdgeToClientObject",
        "concreteType": "TodoModel",
        "backingField": {
          "alias": null,
          "args": (v1/*: any*/),
          "fragment": null,
          "kind": "RelayResolver",
          "name": "todo_model",
          "resolverModule": require('./../../../relay-runtime/store/__tests__/resolvers/QueryTodoModel').todo_model,
          "path": "todo_model"
        },
        "linkedField": {
          "alias": null,
          "args": (v1/*: any*/),
          "concreteType": "TodoModel",
          "kind": "LinkedField",
          "name": "todo_model",
          "plural": false,
          "selections": [
            {
              "args": null,
              "kind": "FragmentSpread",
              "name": "RelayResolverModelTestWithPluralFragment"
            }
          ],
          "storageKey": null
        }
      }
    ],
    "type": "Query",
    "abstractKey": null
  },
  "kind": "Request",
  "operation": {
    "argumentDefinitions": (v0/*: any*/),
    "kind": "Operation",
    "name": "RelayResolverModelTestTodoWithPluralFieldQuery",
    "selections": [
      {
        "kind": "ClientEdgeToClientObject",
        "backingField": {
          "name": "todo_model",
          "args": (v1/*: any*/),
          "fragment": null,
          "kind": "RelayResolver",
          "storageKey": null
        },
        "linkedField": {
          "alias": null,
          "args": (v1/*: any*/),
          "concreteType": "TodoModel",
          "kind": "LinkedField",
          "name": "todo_model",
          "plural": false,
          "selections": [
            {
              "kind": "ClientEdgeToClientObject",
              "backingField": {
                "name": "many_fancy_descriptions",
                "args": null,
                "fragment": {
                  "kind": "InlineFragment",
                  "selections": [
                    {
                      "name": "__relay_model_instance",
                      "args": null,
                      "fragment": {
                        "kind": "InlineFragment",
                        "selections": [
                          (v2/*: any*/)
                        ],
                        "type": "TodoModel",
                        "abstractKey": null
                      },
                      "kind": "RelayResolver",
                      "storageKey": null
                    }
                  ],
                  "type": "TodoModel",
                  "abstractKey": null
                },
                "kind": "RelayResolver",
                "storageKey": null
              },
              "linkedField": {
                "alias": null,
                "args": null,
                "concreteType": "TodoDescription",
                "kind": "LinkedField",
                "name": "many_fancy_descriptions",
                "plural": true,
                "selections": [
                  {
                    "name": "text",
                    "args": null,
                    "fragment": (v3/*: any*/),
                    "kind": "RelayResolver",
                    "storageKey": null
                  },
                  {
                    "name": "color",
                    "args": null,
                    "fragment": (v3/*: any*/),
                    "kind": "RelayResolver",
                    "storageKey": null
                  }
                ],
                "storageKey": null
              }
            },
            (v2/*: any*/)
          ],
          "storageKey": null
        }
      }
    ]
  },
  "params": {
    "cacheID": "48d608fc6572635c8eff5767b51427eb",
    "id": null,
    "metadata": {},
    "name": "RelayResolverModelTestTodoWithPluralFieldQuery",
    "operationKind": "query",
    "text": null
  }
};
})();

if (__DEV__) {
  (node/*: any*/).hash = "8b328e6829eeb1a883ede354bb6dc7de";
}

module.exports = ((node/*: any*/)/*: ClientQuery<
  RelayResolverModelTestTodoWithPluralFieldQuery$variables,
  RelayResolverModelTestTodoWithPluralFieldQuery$data,
>*/);
