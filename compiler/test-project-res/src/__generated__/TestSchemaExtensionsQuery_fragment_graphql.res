/* @sourceLoc Test_schemaExtensions.res */
/* @generated */
%%raw("/* @generated */")
module Types = {
  @@warning("-30")

  @tag("__typename") type fragment_localUnion = 
    | @live LocalThing(
      {
        name: string,
      }
    )
    | @live @as("__unselected") UnselectedUnionMember(string)

  type fragment = {
    localOnlineStatus: option<RelaySchemaAssets_graphql.enum_LocalOnlineStatus_input>,
    localUnion: option<fragment_localUnion>,
  }
}

@live
let unwrap_fragment_localUnion: Types.fragment_localUnion => Types.fragment_localUnion = RescriptRelay_Internal.unwrapUnion(_, ["LocalThing"])
@live
let wrap_fragment_localUnion: Types.fragment_localUnion => Types.fragment_localUnion = RescriptRelay_Internal.wrapUnion
module Internal = {
  @live
  type fragmentRaw
  %%private(
  @live
  let fragmentConverter: JSON.t = %raw(json`{"roots":{"__root":[{"path":["localUnion"],"union":"0"}]},"version":2}`)
  @live
  let fragmentCallbacks = {
    "0": unwrap_fragment_localUnion,
  }
  @live
  let preparedFragmentConverter = RescriptRelay.prepareConversion(
    fragmentConverter,
    fragmentCallbacks,
    None
  )
  )
  @live
  let convertFragment = value => RescriptRelay.runConversion(preparedFragmentConverter, value)
}

type t
type fragmentRef
external getFragmentRef:
  RescriptRelay.fragmentRefs<[> | #TestSchemaExtensionsQuery_fragment]> => fragmentRef = "%identity"

module Utils = {
  @@warning("-33")
  open Types
  @live
  external localOnlineStatus_toString: RelaySchemaAssets_graphql.enum_LocalOnlineStatus => string = "%identity"
  @live
  external localOnlineStatus_input_toString: RelaySchemaAssets_graphql.enum_LocalOnlineStatus_input => string = "%identity"
  @live
  let localOnlineStatus_decode = (enum: RelaySchemaAssets_graphql.enum_LocalOnlineStatus): option<RelaySchemaAssets_graphql.enum_LocalOnlineStatus_input> => {
    switch enum {
      | FutureAddedValue(_) => None
      | valid => Some(Obj.magic(valid))
    }
  }
  @live
  let localOnlineStatus_fromString = (str: string): option<RelaySchemaAssets_graphql.enum_LocalOnlineStatus_input> => {
    localOnlineStatus_decode(Obj.magic(str))
  }
}

type relayOperationNode
type operationType = RescriptRelay.fragmentNode<relayOperationNode>


let node: operationType = %raw(json` {
  "argumentDefinitions": [],
  "kind": "Fragment",
  "metadata": null,
  "name": "TestSchemaExtensionsQuery_fragment",
  "selections": [
    {
      "kind": "ClientExtension",
      "selections": [
        {
          "alias": null,
          "args": null,
          "kind": "ScalarField",
          "name": "localOnlineStatus",
          "storageKey": null
        },
        {
          "alias": null,
          "args": null,
          "concreteType": null,
          "kind": "LinkedField",
          "name": "localUnion",
          "plural": false,
          "selections": [
            {
              "alias": null,
              "args": null,
              "kind": "ScalarField",
              "name": "__typename",
              "storageKey": null
            },
            {
              "kind": "InlineFragment",
              "selections": [
                {
                  "alias": null,
                  "args": null,
                  "kind": "ScalarField",
                  "name": "name",
                  "storageKey": null
                }
              ],
              "type": "LocalThing",
              "abstractKey": null
            }
          ],
          "storageKey": null
        }
      ]
    }
  ],
  "type": "Query",
  "abstractKey": null
} `)

