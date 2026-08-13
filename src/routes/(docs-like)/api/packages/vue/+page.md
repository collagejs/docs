---
  title: '@collagejs/vue'
  description: |
    API reference for the @collagejs/vue NPM package.
---

<script lang="ts">
    import type { PageProps } from './$types';
</script>

This package is *CollageJS*' official framework adapter for [VueJS](https://vuejs.org).

## Components

### Piece

Component used to mount *CollageJS* core pieces in VueJS projects.

```svelte
<script setup lang="ts">
  import { Piece } from '@collagejs/vue';
  import { myPieceFactory } from '@my-project/my-piece';

  const corePiece = myPieceFactory();
</script>

<template>
  <Piece
    :piece="corePiece"
    :shadow="true"
    :piece-props="{ pieceProp1: 'a', pieceProp2: true }"
    data-custom="abc"
  />
</template>
```

Any non-properties specified are forwarded as attributes for the container DIV element.

#### Properties

| Property | Type | Default Value | Description |
| - | - | - | - |
| `piece` | `CorePiece<TProps> \| Promise<CorePiece<TProps>>` | | Required property that accepts a *CollageJS* core piece object or a promise to a core piece object. |
| `shadow` | `boolean \| ShadowRootInit` | `false` | See [Official Adapters](/docs/official-adapters). |
| `pieceProps` | `TProps` | `undefined` | Properties for the *CollageJS* core piece object. |

## Functions

### buildPiece

Function that creates *CollageJS* core piece objects out of VueJS components.

See [Official Adapters](/docs/official-adapters) for additional information on how to use it.

#### Options

| Option | Type | Default Value | Description |
| - | - | - | - |
| `remountable` | `boolean` | `true` | See [Official Adapters](/docs/official-adapters). |
| `relocation` | `'supported' \| 'unsupported' \| Relocate` | `'supported'` | See [Official Adapters](/docs/official-adapters). |
| `meta` | `TMeta` | `undefined` | See [Official Adapters](/docs/official-adapters). |
| `props` | `TProps` | `undefined` | Optional set of initial property values given to the VueJS component when mounted. |
| `configureApp` | `(app: App<Element>) => void` | `undefined` | Optional function that provides the created Vue application object, which can be used to install plug-ins and such. |
