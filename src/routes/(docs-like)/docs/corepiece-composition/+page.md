---
  title: CorePiece Composition
  description: |
    Explains how to compose CollageJS lifecycle functions to add layers of functionality.
---

<script lang="ts">
  import type { PageProps } from './$types';
  import { Lightbulb } from '@lucide/svelte';
</script>

A *CollageJS* core piece object is an object that provides, as a minimum the `mount` lifecycle.  Lifecycles are, in code, either a function or an array of functions.

Other lifecycles exist:  `update` and `relocate`.  One could say the `unmount` lifecycle exists, and it is returned by the functions in the `mount` lifecycle.

These lifecycles are presented as part of one object, but in reality, the functions are expected to work decoupled of their parent object.  In other words, it is expected that the functions can be called without the object that carries them.

This decoupling is fantastic because it allows for *lifecycle composition*.  This means that we can add functionality to already-built core pieces by simply adding functions to the lifecycles.

We can do simple things, like target logging/tracking:

```typescript
import { buildPiece } from '@collagejs/<framework-of-choice>';
import Component from './Component-File.js';
import type { MountFn } from '@collagejs/core';

const piece = buildPiece(Component);

const logger = (target) => {
  console.debug('Mounting target:', target);
} satisfies MountFn;

const modifiedPiece = {
  ...piece,
  mount: [logger, piece.mount],
};
```

We have added a logger function that tells us the target object for the core piece object.

We can also do much more significant tasks, like synchronizing CSS mounting, which is something we have seen throughout this document:

```typescript
import { CssFactory } from '@collagejs/vite-css/ex';

const css = new CssFactory(import.meta.url);

function pieceFactory() {
  const { mount, relocate } = css.instantiate();
  const piece = ...;

  return {
    ...piece,
    mount: [mount, piece.mount],
    relocate: [
      piece.meta.relocatable && relocate,
      piece.relocate
    ],
  };
}
```

All this is *lifecycle composition*.  We are adding functionality to pieces.

A simpler example is how official adapters enforce that a core piece cannot be remounted once unmounted:

```typescript
import { preventRemount } from '@collagejs/core';

function buildPiece(...) {
  ...

  return {
    mount: [
      options?.remountable === false && preventRemount(),
      mount
    ],
    ...
  };
}
```

Official adapters add a function that throws an error if it is ever called more than once by simply tracking if it has already been called once.

All 3 lifecycles (`mount`, `update`, `relocate`) are composable, although composing relocation is far more complex because of its nature.

As for the other 2, the algorithm in the core library is simple:

1. Obtain every element in the lifecycle array.  If falsy, skip it.
2. Call and await the lifecycle function.
3. If the function throws, the entire lifecycle is failed.

## Composing the `relocate` Lifecycle

Relocation is a transacted, rollback-able operation.  Every function in the `relocate` lifecycle has the opportunity to return:

- `'supported'`
- `'done'`
- `'unsupported'`

But for the first two, a rollback function can also be returned in a tuple:

- `['supported', rollbackFn]`
- `['done', rollbackFn]`

These values and rollback functions are accumulated and a "safe state" ruling is continuously updated after every call to a lifecycle function, ready to either rollback the operation or throw an error if the process has become irreversible.

It is highly recommended to always try to provide rollback functions to ensure a stable operation.  Let's remember that, whenever a relocation attempt fails, a mounting cycle should take its place.  The way we can maintain the internal "safe state" in green is to provide rollback functions.

> **<Lightbulb /> `'supported'` With Rollback Is Optional**
>
> This is covered in the [CorePiece Relocation and Metadata](/docs/corepiece-relocation-and-metadata) topic:  `'supported'`, by itself, doesn't turn the internal "safe state" flag to red.

The entire topic is covered exhaustively elsewhere, so let's just mention some best practices pertaining relocation:

- All official adapters calculate `meta.relocatable`.  Use it before composing, as seen in examples already.
- The more generic the composition layer, the more neutral it should be:  Try to always return either `'supported'` or `['supported', rollbackFn]` as opposed to `'done'`.
- If creating core pieces without an official adapter, always populate `meta.relocatable`.
- When composing for logging purposes or some other neutral operation, never contradict the value of `meta.relocatable`.  Perform the operation and return `'unsupported'` if `meta.relocatable` is `false`, or `'supported'` if `meta.relocatable` is `true`.
