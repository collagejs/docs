---
  title: TypeScript Support in CollageJS
  description: |
    Understand the TypeScript-related features that CollageJS offers to developers creating micro-frontend projects.
---
<script lang="ts">
    import type { PageProps } from './$types';
</script>

*CollageJS* has been written in TypeScript since day 1.  Everything is typed, and every public API should also include JsDoc comments that show up nicely in tooltips in developer IDE's like *Visual Studio Code*.

In order to take full advantage of all of its features, we need to learn how a few things are done.

## Enabling Static Import Statements

As you may know, we can statically import from *CollageJS* piece projects, but for TypeScript to be happy about it, we need to create ambient modules for the bare module specifiers we assign to the modules exported by said piece projects.

As this documentation recommends, we export factory piece functions.  To import them and make TypeScript happy, we can do something like this:

```typescript
declare module '@myCollageJs/piece' {
  import type { CorePiece } from '@collagejs/core';

  export type PieceProps = {
    name: string;
    allowSignOut?: boolean;
  };

  export function pieceFactory(): CorePiece<PieceProps>;
}
```

The above is called [ambient module](https://www.typescriptlang.org/docs/handbook/modules/reference.html#ambient-modules) and this enables Intellisense everywhere we use the factory function or its return value (the core piece object).

For example, this enables Intellisense on properties when mounting the core piece object using the `<Piece>` component of official frameworks (where the framework allows it):

```svelte
<Piece {...piece(myPieceObject)} name="Joanne" allowSignOut />
```

## Extending Metadata

Core pieces (of type `CorePiece`) are *CollageJS*' central concept.  The interface defines what a core piece object must comply with in order to work in *CollageJS* as a mountable piece.  This interface defines the `meta` property as an object of type `CorePieceMeta`.  This property is meant to provide extra data and functionality as needed.  If your projects could benefit by transmitting/exposing data or specialty functions to core piece consumers, feel free to extend the interface:

```typescript
import '@collagejs/core';

declare module '@collagejs/core' {
  export interface CorePieceMeta {
    // Additions to the interface go here.  For example a data property:

    /**
     * Returns a URL that provide instructions on how to get support for this core piece.
     */
    supportUrl?: string | undefined;
    /**
     * Sets the core piece's log level in case debugging is necessary.
     */
    setLogLevel(level: 'off' | 'minimal' | 'full'): void;
  }
}
```

As seen, we can add both data and functions.

But extending the interface affects every core piece in the web project, and perhaps we need metadata that is specific to a single core piece.  In that case we don't define this extra data by extending the interface.  Instead, we just tell the framework adapter's `buildPiece` function to include the extra metadata we need.  The function's typing will infer the metadata type, no problem.

Oh, but you say you need a type so other things in code can be typed?  No problem:

```typescript
import { CorePieceMeta } from '@collagejs/core';

export type MyPieceMetaExtension = {
  thingOnlyOnePieceProvides: string;
};

export type MyPieceMeta = CorePieceMeta & MyPieceMetaExtension;
```

We do 2 types:  The extension type is just the extra things we want.  This type is used in *CollageJS* types like `CorePiece` that have a type parameter named `TMeta`.  *CollageJS* only needs to be given the *extra things*.  The core things it knows them already.

The other type (`MyPieceMeta`) is there for variables and types outside *CollageJS*.  It is a reminder that the core library does define metadata already and that we should always carry it and not collide with it.

## Extending `CorePiece`

While technically possible, we usually don't recommend because we can achieve the same thing without having to touch it, but we're not against extending it either.

To extend the `CorePiece` interface, we can do this:

```typescript
import '@collagejs/core';

declare module '@collagejs/core' {
  export interface CorePiece<
    TProps extends Record<string, any> = Record<string, any>,
    TMeta extends Record<string, any> = {}
  > {
    // Additions to the interface go here.
  }
}
```

Do this if you think extending `CorePiece.meta` is not what you seek.

Alternatively, you could just declare a new interface and then create a type guard function to narrow for that interface:

```typescript
export interface CorePieceEx {
  /**
   * Tells the core piece object to animate its user interface,
   * perhaps to call for the user's attention.
   */
  animate(): Promise<void>;
}

function isCorePieceEx(obj: unknown) obj is CorePieceEx {
  return (obj as any).animate !== undefined;
}

const myPiece = somePieceFactory();
if (isCorePieceEx(myPiece)) {
  await myPiece.animate();
}
```

This is how many languages work, including C++ and C#:  Interfaces represent extra or specialty functionality available from an object.  They usually are small and highly focused on a specific feature, as objects can implement multiple interfaces simultaneously.  This is part of the (in)famous **SOLID design principles**.
