/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @flow strict-local
 * @format
 * @oncall relay
 */

'use strict';

import type {FetchFunction} from '../../network/RelayNetworkTypes';
import type {Snapshot} from '../RelayStoreTypes';

const RelayNetwork = require('../../network/RelayNetwork');
const RelayObservable = require('../../network/RelayObservable');
const {graphql} = require('../../query/GraphQLTag');
const RelayFeatureFlags = require('../../util/RelayFeatureFlags');
const RelayModernEnvironment = require('../RelayModernEnvironment');
const {
  createOperationDescriptor,
} = require('../RelayModernOperationDescriptor');
const RelayModernStore = require('../RelayModernStore');
const RelayReader = require('../RelayReader');
const RelayRecordSource = require('../RelayRecordSource');
const invariant = require('invariant');

describe('RelayModernStore field-granular notifications', () => {
  let prevFlag: boolean;

  beforeEach(() => {
    prevFlag = RelayFeatureFlags.ENABLE_FIELD_GRANULAR_NOTIFICATIONS;
  });

  afterEach(() => {
    RelayFeatureFlags.ENABLE_FIELD_GRANULAR_NOTIFICATIONS = prevFlag;
  });

  it.each([true, false])(
    'when field-granular is %s, read() is called accordingly on notify for unrelated singular linked root field change',
    fieldGranularEnabled => {
      RelayFeatureFlags.ENABLE_FIELD_GRANULAR_NOTIFICATIONS =
        fieldGranularEnabled;

      const MeQuery = graphql`
        query RelayModernStoreFieldGranularNotificationsTestMeQuery(
          $size: [Int]
        ) {
          me {
            name
            profilePicture(size: $size) {
              uri
            }
            emailAddresses
          }
        }
      `;

      const NodeQuery = graphql`
        query RelayModernStoreFieldGranularNotificationsTestNodeQuery(
          $id: ID!
        ) {
          node(id: $id) {
            id
            __typename
            ... on User {
              name
            }
          }
        }
      `;

      const environment = new RelayModernEnvironment({
        network: RelayNetwork.create(jest.fn()),
        store: new RelayModernStore(new RelayRecordSource()),
      });

      // Populate the store with initial data via commitPayload.
      const meOperation = createOperationDescriptor(MeQuery, {
        size: 32,
      });
      environment.commitPayload(meOperation, {
        me: {
          __typename: 'User',
          id: '4',
          name: 'Zuck',
          profilePicture: {uri: 'https://photo1.jpg'},
          emailAddresses: ['a@b.com'],
        },
      });

      // Subscribe to the me query.
      const snapshot = environment.lookup(meOperation.fragment);
      const callback = jest.fn<[Snapshot], void>();
      environment.subscribe(snapshot, callback);

      const readSpy = jest.spyOn(RelayReader, 'read');

      // Publish a response for a different root field (node).
      const nodeOperation = createOperationDescriptor(NodeQuery, {
        id: '5',
      });
      environment.commitPayload(nodeOperation, {
        node: {__typename: 'User', id: '5', name: 'Other'},
      });

      if (fieldGranularEnabled) {
        // With field-granular on, the subscription's field-level
        // seenRecords don't overlap with the field-level
        // updatedRecordIDs, so read() is never called.
        expect(readSpy).not.toHaveBeenCalled();
      } else {
        // Without field-granular, 'client:root' is in both
        // seenRecords and updatedRecordIDs, so the store must
        // re-read the snapshot even though the data didn't change.
        expect(readSpy).toHaveBeenCalled();
      }

      // Even without the flag enabled, we should still avoid notifying
      // the subscriber if the data didn't change thanks to the deep
      // comparison in recycleNodesInto.
      expect(callback).not.toBeCalled();
      readSpy.mockRestore();
    },
  );

  it.each([true, false])(
    'when field-granular is %s, re-reads when a field stays null but an error is encountered',
    fieldGranularEnabled => {
      RelayFeatureFlags.ENABLE_FIELD_GRANULAR_NOTIFICATIONS =
        fieldGranularEnabled;

      const MeQuery = graphql`
        query RelayModernStoreFieldGranularNotificationsTestMeErrorQuery(
          $size: [Int]
        ) {
          me {
            name
            profilePicture(size: $size) {
              uri
            }
            emailAddresses
          }
        }
      `;

      // Create a mock network with an observable sink so we can
      // inject a response containing field-level errors.
      let sink;
      const fetch: FetchFunction = () =>
        RelayObservable.create(s => {
          sink = s;
        });

      const environment = new RelayModernEnvironment({
        network: RelayNetwork.create(fetch),
        store: new RelayModernStore(new RelayRecordSource()),
      });

      const meOperation = createOperationDescriptor(MeQuery, {
        size: 32,
      });

      // Populate the store with me: null and no error.
      environment.commitPayload(meOperation, {me: null});

      const snapshot = environment.lookup(meOperation.fragment);
      const callback = jest.fn<[Snapshot], void>();
      environment.subscribe(snapshot, callback);

      const readSpy = jest.spyOn(RelayReader, 'read');

      // Execute a response where me is still null but with an error.
      // This causes client:root.__errors.me to be populated while
      // the field value itself (client:root.me) remains null.
      environment.execute({operation: meOperation}).subscribe({});
      invariant(sink != null, 'Expected sink to be set');
      sink.next({
        data: {me: null},
        errors: [{message: 'Could not fetch me', path: ['me']}],
      });
      sink.complete();

      // Both with and without field-granular, the subscription should
      // be re-read because the error change on client:root.me is
      // detected. With field-granular, it's detected via the
      // __fn:client:root:me key and hasFieldChanged comparing errors.
      // Without field-granular, it's detected via the client:root
      // record-level key.
      expect(readSpy).toHaveBeenCalled();
      readSpy.mockRestore();
    },
  );

  it.each([true, false])(
    'when field-granular is %s, read() is called accordingly on notify for unrelated plural linked root field change',
    fieldGranularEnabled => {
      RelayFeatureFlags.ENABLE_FIELD_GRANULAR_NOTIFICATIONS =
        fieldGranularEnabled;

      const MeQuery2 = graphql`
        query RelayModernStoreFieldGranularNotificationsTestMePluralQuery(
          $size: [Int]
        ) {
          me {
            name
            profilePicture(size: $size) {
              uri
            }
            emailAddresses
          }
        }
      `;

      const NodesQuery2 = graphql`
        query RelayModernStoreFieldGranularNotificationsTestNodesPluralQuery(
          $ids: [ID!]!
        ) {
          nodes(ids: $ids) {
            id
            __typename
            ... on User {
              name
            }
          }
        }
      `;

      const environment = new RelayModernEnvironment({
        network: RelayNetwork.create(jest.fn()),
        store: new RelayModernStore(new RelayRecordSource()),
      });

      // Populate the store with initial data for me.
      const meOperation = createOperationDescriptor(MeQuery2, {size: 32});
      environment.commitPayload(meOperation, {
        me: {
          __typename: 'User',
          id: '4',
          name: 'Zuck',
          profilePicture: {uri: 'https://photo1.jpg'},
          emailAddresses: ['a@b.com'],
        },
      });

      // Subscribe to the me query.
      const snapshot = environment.lookup(meOperation.fragment);
      const callback = jest.fn<[Snapshot], void>();
      environment.subscribe(snapshot, callback);

      const readSpy = jest.spyOn(RelayReader, 'read');

      // Commit a payload for an unrelated plural linked field (nodes).
      // This changes client:root's `nodes(ids:["1","2"])` field.
      const nodesOperation = createOperationDescriptor(NodesQuery2, {
        ids: ['1', '2'],
      });
      environment.commitPayload(nodesOperation, {
        nodes: [
          {__typename: 'User', id: '1', name: 'Alice'},
          {__typename: 'User', id: '2', name: 'Bob'},
        ],
      });

      if (fieldGranularEnabled) {
        // With field-granular on, the me subscription's __fn: keys
        // don't overlap with the nodes field's __fn: key, so
        // read() is never called.
        expect(readSpy).not.toHaveBeenCalled();
      } else {
        // Without field-granular, 'client:root' is in both
        // seenRecords and updatedRecordIDs, so the store must
        // re-read even though the me data didn't change.
        expect(readSpy).toHaveBeenCalled();
      }

      // Either way, the subscriber should not be notified because
      // the me data didn't change.
      expect(callback).not.toHaveBeenCalled();
      readSpy.mockRestore();
    },
  );

  it.each([true, false])(
    'when field-granular is %s, re-reads when the plural linked field the subscription reads changes',
    fieldGranularEnabled => {
      RelayFeatureFlags.ENABLE_FIELD_GRANULAR_NOTIFICATIONS =
        fieldGranularEnabled;

      const NodesQuery = graphql`
        query RelayModernStoreFieldGranularNotificationsTestNodesQuery(
          $ids: [ID!]!
        ) {
          nodes(ids: $ids) {
            id
            __typename
            ... on User {
              name
            }
          }
        }
      `;

      const environment = new RelayModernEnvironment({
        network: RelayNetwork.create(jest.fn()),
        store: new RelayModernStore(new RelayRecordSource()),
      });

      const nodesOperation = createOperationDescriptor(NodesQuery, {
        ids: ['1', '2'],
      });

      // Populate the store with two nodes.
      environment.commitPayload(nodesOperation, {
        nodes: [
          {__typename: 'User', id: '1', name: 'Alice'},
          {__typename: 'User', id: '2', name: 'Bob'},
        ],
      });

      const snapshot = environment.lookup(nodesOperation.fragment);
      const callback = jest.fn<[Snapshot], void>();
      environment.subscribe(snapshot, callback);

      const readSpy = jest.spyOn(RelayReader, 'read');

      // Re-fetch the same query but the server now returns a
      // different set of records. The plural linked field on
      // client:root changes from [ref:1, ref:2] to [ref:1, ref:3].
      environment.commitPayload(nodesOperation, {
        nodes: [
          {__typename: 'User', id: '1', name: 'Alice'},
          {__typename: 'User', id: '3', name: 'Charlie'},
        ],
      });

      // Both with and without field-granular, the subscription should
      // be re-read. With field-granular, it's detected via the __fn:
      // key for the nodes field. Without field-granular, it's detected
      // via the client:root record-level key.
      expect(readSpy).toHaveBeenCalled();
      expect(callback).toHaveBeenCalled();
      readSpy.mockRestore();
    },
  );
});
