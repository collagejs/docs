---
  title: '@collagejs/react'
  description: |
    API reference for the @collagejs/react NPM package.
---

<script lang="ts">
    import type { PageProps } from './$types';
</script>

This package is *CollageJS*' official framework adapter for [React](https://react.dev).

## Components

### CollageProvider

Contextual component that provides the parent-aware `mountPiece` function to React pieces that need to mount other *CollageJS* core pieces.

```tsx
import { CollageProvider } from '@collagejs/react';

function MyComponent() {
  return <>
    <CollageProvider>
      <!--
        Here, components can call the useCollageContext() function
        to obtain the parent-aware mountPiece() function.
      -->
    </CollageProvider>
  </>;
}
```

### Piece

Component used to mount *CollageJS* core pieces in React projects.

See [Official Adapters](/docs/official-adapters) for additional information on how to use it.

## Functions

### buildPiece

Function that creates *CollageJS* core piece objects out of React components.

See [Official Adapters](/docs/official-adapters) for additional information on how to use it.

#### Options

| Option | Type | Default Value | Description |
| - | - | - | - |
| `remountable` | `boolean` | `true` | See [Official Adapters](/docs/official-adapters). |
| `relocation` | `'supported' \| 'unsupported' \| Relocate` | `'supported'` | See [Official Adapters](/docs/official-adapters). |
| `meta` | `TMeta` | `undefined` | See [Official Adapters](/docs/official-adapters). |
| `props` | `TProps` | `undefined` | Initial set of properties given to the React component when it is mounted. |
| `rootOptions` | `RootOptions` | `undefined` | Optional React options for the creation of the root object via React's `createRoot` function. |

### piece

Function used to configure the `Piece` component.

```tsx
import { Piece, piece } from '@collagejs/react';
import { myPieceFactory } from '@my-project/my-piece';
import { useMemo } from 'react';

return function MyComponent() {
  const corePiece = useMemo(myPieceFactory, []);

  return <>
    <Piece
      {...piece(corePiece, { shadow: true })}
      pieceProp1="a"
      pieceProp2={true}
    />
  </>;
}
```

See [Official Adapters](/docs/official-adapters) for additional information on how to use it.

#### Options

| Option | Type | Default Value | Description |
| - | - | - | - |
| `containerProps` | `ComponentPropsWithoutRef<div>` | `undefined` | See [Official Adapters](/docs/official-adapters). |
| `shadow` | `boolean \| ShadowRootInit` | `false` | See [Official Adapters](/docs/official-adapters). |
| `logging` | `boolean` | `false` | Turns on lifecycle logging.  Usually done for debugging purposes. |

### useCollageContext

Returns the *CollageJS* context provided by [CollageProvider](#collageprovider).  It is used to obtain the parent-aware `mountPiece` function used to mount core pieces inside core pieces.

It is normally never used on its own, and its primary consumer is the provided `Piece` component.
