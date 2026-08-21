---
title: Introduction
description: |
    Learn how CollageJS works at its core, which is the foundation of the entire technology.
---

<script lang="ts">
  import { Flag } from '@lucide/svelte';
</script>

*CollageJS* is a small collection of libraries that allows front-end developers the opportunity of creating user interfaces in chunks or pieces, where each piece doesn't care about the underlying technology of the other pieces.  In other words:  *CollageJS* can be used to create web applications piece by piece, and each piece can be created using... well, anything.  It doesn't matter.

Now you know the main objective of *CollageJS*.  Let's delve next into the core concepts.

## Core Pieces

*Core pieces*, also known plainly as *pieces*, are the main course:  A *piece* is an abstraction of a user interface element that is capable of working as a unit by itself.

In JavaScript terms, it is an object that fulfills a contract.  Which contract?  The `CorePiece` interface.

This is its TypeScript definition:

```typescript
export interface CorePiece<TProps, TMeta> {
  mount: MountFn<TProps> | MountFn<TProps>[];
  relocate?: RelocateFn | RelocateFn[];
  update?: UpdateFn<TProps> | UpdateFn<TProps>[];
  meta?: TMeta & {
    remountable?: boolean;
    relocatable?: boolean;
  };
}
```
> **<Flag /> NOTE**
> 
> This is a simplification of the actual types.

Except for the `meta` property, these are called *lifecycle* functions loosely, even though technically speaking, they can be an array of lifecycle functions.

Of all the interface properties, only the `mount` lifecycle function is required.  This property can be a function, an array of functions, or an array of either functions or array of functions (not shown in the type because it is simplified).

### Mount

The following objects are valid `CorePiece` objects:

```typescript
const myPiece = {
  mount(target: AcceptableTarget, props: Record<string, any>) {
    // ...
  },
};

const myPieceComplex = {
  mount: [a, b, [c, d, [e, f, g]], h, null, false, undefined],
};
```

In the second example, each letter is a function that satisifies the `MountFn` type.

The `myPiece` object is the simplest form of `CorePiece`, and the example shows the actual function signature expected by *CollageJS*.  The `target` parameter can be an HTML element or a shadow root object, while the second one is an object with the properties the `CorePiece` object supports.

On the other hand, `myPieceComplex` is an example of how mounting functions can be arranged:  We can nest arrays within arrays without issue.  This is normally not what we recommend developers to do, however.  The reason *CollageJS* supports this arrangement is to facilitate the [composition](/docs/corepiece-composition) of `CorePiece` objects.

#### Unmounting

Core pieces should provide an unmounting function.  The mechanism is very simple:  A mounting function returns the unmounting function that undoes what mounting does.

To exemplify, let's elaborate on the `myPiece` piece from above:

```typescript
const myPiece = {
  mount(target: AcceptableTarget, props: Record<string, any>) {
    const root = document.createElement('div');
    // Etc. Fill the root element.
    target.appendChild(root);
    return Promise.resolve(() => {
      root.remove();
      return Promise.resolve();
    });
  },
};
```

This kind of pattern is very popular among font-end libraries and frameworks, so hopefully this is very easy to understand.

### Relocate

This is mostly an optimization technique and piece objects will work just fine without this lifecycle function.

In order to fully understand this lifecycle function, we need to understand in more depth how *CollageJS* pieces are mounted, and we haven't done this.  Therefore, let's just say this:  Piece objects that provide the `relocate` lifecycle function are capable of switching target elements without going through unmounting and remounting.

Let's just stop here for now.
TODO:  Add link to where the topic can be resumed.

### Update

This lifecycle function is in place for piece objects that are capable of reacting to component property changes.  Many front-end frameworks are capable of producing components that reactively update whenever their given property values change.  Just to name a few frameworks (and libraries):  *React*, *Svelte*, *VueJS*, *SolidJS*, *Lit*, *Preact*, etc.

The `update` lifecycle function is the medium that consumers of *CollageJS* pieces use to ask them to update in response to changes in their given properties.

The implementation of this lifecycle function is heavily dependent on the framework or library used to generate the piece object.  Just to show one example, here's how one would do it in *Svelte* v5:

```typescript
// myPiece.svelte.ts

const myProps = $state<MyProps>({});

const myPiece = {
  update(newProps: MyProps) {
    myProps = {
      ...myProps,
      ...newProps
    };
    return Promise.resolve();
  },
};
```

We could go on talking about differences.  For instance, *React* components re-render instead of using a signal mechanism like *Svelte* does.  However, this should be sufficient for us to understand this lifecycle function.

### Metadata

This is not a lifecycle function.  This is a POJO piece developers can use to pass along any values they consider appropriate for very, very specialized scenarios.  Most people won't need to use this at all.

What most people need to know, is that *CollageJS* has defined two metadata properties:

1. `remountable?: boolean`.  This is a property that official adapters can enforce and that also relates a little to the `relocate` lifecycle function.  We will therefore defer the topic once more.
2. `relocatable?: boolean`.  Once more and related to relocation, this property is usually set by official adapters to the appropriate value depending on the options given to its `buildPiece` function.

## Consuming Pieces

Now that we know how the main building block (the piece object) works, we can complete the puzzle:  Let's mount a piece.

Since we don't want to speak in terms of a framework or library yet, let's do some vanilla TypeScript:

```typescript
import { mountPiece } from '@collagejs/core';

// Assuming we have made sure there's an element 
// with id="piece" in our markup:
const pieceEl = document.querySelector('#piece')!;

// If we want to mount directly in the DOM
const target = pieceEl; 
// If we want to mount in an open shadow root
const target = pieceEl.attachShadow({ mode: 'open' });
// If we want to mount in an closed shadow root
const target = pieceEl.attachShadow({ mode: 'closed' });

const mountedPiece = await mountPiece(myPiece, target, {
  prop1: 'Hello',
  prop2: 'CollageJS!'
});
```

In order, the parameters to `mountPiece` are:

- `piece: CorePiece<TProps, TMeta>` -- The piece object to mount (or a promise to it; type simplified)
- `target: AcceptableTarget` -- The parent object that will host the piece's user interface
- `props: TProps` -- The initial property values for the piece object

The returned `mountedPiece` object is of type `MountedPiece` and provides an interface almost identical to that of `CorePiece`, where:

- `unmount` unmounts the piece
- `update` updates the piece with a new set of property values
- `relocate` relocates the piece without triggering a mounting cycle (if the piece supports it)
- `meta` exposes the piece's `meta` property

### A Better Way to Create and Consume Pieces

We learned that we can use `mountPiece` and its return value to mount a core piece and then manage its lifecycle.  This is both great and powerful, but it can become tedious and repetitive.  Yes, the no-framework font-end developers exist and are many, and we *know* they are shaking their heads right now.  If you are one of those, then you're probably all set and ready to start experimenting by yourself.

But if you're not one of those developers, you want a friendlier way to consume pieces.  We understand fully.  This is where *adapters* enter the equation.

An *adapter* is a library specialized in a particular front-end framework or library that assists in the process of achieving the 2 operations we covered here, namely:

- Creating a `CorePiece` object
- Consuming a `CorePiece` object

We won't discuss them in depth here, but surely we can present some sample code to illustrate the matter.

This is an example of how we can produce a `CorePiece` object out of a Svelte component:

```typescript
import { buildPiece } from '@collagejs/svelte';
import Root from './Root.svelte';

const piece = buildPiece(Root);
```

This is an example of how we can consume a `CorePiece` object (no matter its nature) in a Svelte project:

```svelte
<script lang="ts">
  import { Piece, piece } from '@collagejs/svelte';

  const myPiece = obtainTheCorePieceSomehow();
</script>

<Piece
  {...piece(myPiece, { shadow: true })}
  prop1="Hello"
  prop2="CollageJS!"
/>
```

Generally speaking, adapter libraries work this way regardless of their framework.  If a particular adapter cannot fulfill the standardized API for any reason, the adapter's documentation will cover the difference(s).

TODO: Add link to specialized adapters topic.
