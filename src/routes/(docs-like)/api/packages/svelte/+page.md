---
  title: '@collagejs/svelte'
  description: |
    API reference for the @collagejs/svelte NPM package.
---

<script lang="ts">
    import type { PageProps } from './$types';
</script>

This package is *CollageJS*' official framework adapter for [Svelte](https://svelte.dev).

## Components

### Piece

Component used to mount *CollageJS* core pieces in Svelte projects.

See [Official Adapters](/docs/official-adapters) for additional information on how to use it.

## Functions

### buildPiece

Function that creates *CollageJS* core piece objects out of Svelte components.

See [Official Adapters](/docs/official-adapters) for additional information on how to use it.

#### Options

| Option | Type | Default Value | Description |
| - | - | - | - |
| `remountable` | `boolean` | `true` | See [Official Adapters](/docs/official-adapters). |
| `relocation` | `'supported' \| 'unsupported' \| Relocate` | `'supported'` | See [Official Adapters](/docs/official-adapters). |
| `meta` | `TMeta` | `undefined` | See [Official Adapters](/docs/official-adapters). |
| `mount` | `SvelteMountOptions<TProps>` | `undefined` | Optional set of options for Svelte's `mount` function.  The `target` option is deliberately ignored. |
| `unmount` | `Parameters<typeof unmount>[1]` | `undefined` | Optional set of options for Svelte's `unmount` function. |

### piece

Function used to configure the `Piece` component.

```svelte
<script lang="ts">
  import { Piece, piece } from '@collagejs/svelte';
  import { myPieceFactory } from '@my-project/my-piece';

  const corePiece = myPieceFactory();
</script>

<Piece
  {...piece(corePiece, { shadow: true })}
  pieceProp1="a"
  pieceProp2={true}
/>
```

See [Official Adapters](/docs/official-adapters) for additional information on how to use it.

#### Options

| Option | Type | Default Value | Description |
| - | - | - | - |
| `containerProps` | `ComponentPropsWithoutRef<div>` | `undefined` | See [Official Adapters](/docs/official-adapters). |
| `shadow` | `boolean \| ShadowRootInit` | `false` | See [Official Adapters](/docs/official-adapters). |
| `lifecycleLogging` | `boolean` | `false` | Turns on lifecycle logging.  Usually done for debugging purposes. |
