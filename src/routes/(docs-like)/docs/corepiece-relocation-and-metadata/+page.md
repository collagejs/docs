---
  title: CorePiece Relocation and Metadata
  description: |
    Explains the relocate lifecycle, its main purpose, how it works and how it relates to CorePiece metadata.
---

<script lang="ts">
  import type { PageProps } from './$types';
  import { ArrowUp, FlipHorizontal, Info, Lightbulb } from '@lucide/svelte';
</script>

Up until now, we have actively avoided to speak too much about relocation and the `relocate` lifecycle.  It is now time to fully discuss this topic.

Relocation is the act of transferring the DOM trees a core piece generates from one target object (an HTML element or a shadow root) to another, "new" target object while avoiding dismounting the core piece and mounting it again (a. k. a., a mounting cycle).  The process sounds really simple, but in reality is by far the most complex just to ensure a good developer and user experience.

This optional lifecycle comes from the desire to provide the best developer experience when working with *CollageJS*.  We, developers, are very fond of HMR (Hot Module Reloading) because it saves times and allows for faster development, whereas we're designing something or refining the last little details.

HMR, in case people wonder, is not one recipe that is applied the same everywhere.  As a matter of fact, Vite doesn't really provide the implementation details on how Svelte, VueJS or React perform HMR.  This is done by the respective Vite plug-ins.  We could start a masterclass here about HMR and the differences between the different implementations across frameworks... but we're not masters in HMR either.  So let's abandon all hope about learning HMR here.

What we'll say is this:  Generally speaking, when source code changes and Vite notifies about that change to the browser, the HMR implementation may take one of 2 paths:

- The variable patching path
- The module reload path

The latter is the "safer" approach in the sense that the entire module is unloaded and then reloaded, resetting all variables and such.  This makes components lose state data.

The former, on the other hand, is the surgical one.  This one patches the module by updating variable values without unloading (and therefore, losing) state data, for the most part.

In reality, HMR implementations are a mix of these, and `relocate` exists to help the developer obtain the best possible DX by accounting for the possibility of variable patching, which may trigger a change in the `shadow` option of `Piece` components in official framework adapters, which would force the component to perform a mounting cycle on the loaded piece, making it lose data.  All this because maybe the source code changed the `shadow` option from `false` to `true`, just to present an example.

By relocating instead of performing a mounting cycle, we can preserve state and avoid error messages.  Why?  Well, some pieces might not be remountable.  What if the `shadow` option changes but the piece is not remountable and we didn't get a new core piece object?  Then the entire page needs reloading.

So why it is so complex? Well, being an enhancement that most likely won't be enjoyed directly by end users of applications, it would be unfair to ask piece developers to invest too much time in it, so *CollageJS* has absorbed most of the work, and the lifecycle definition has been made as developer-friendly and small as possible.

Wow!  All **THAT <ArrowUp />** just to justify the existence of `relocate`.

## Design Requirements for `relocate`

These were the original design requirements for this lifecycle:

- Must be optional.  If not provided, a mounting cycle is performed.
- Must be composable, just like the other 2 lifecycles.
- Must impose minimal effort to developers.
- Must "just work" without bothering developers.
- Must work just as well when bundled and deployed.
- Must work with any and all core pieces:  The well made ones with official adapters, and the not-so-well made ones from ad-hoc code.

To assist with this task, the 2 metadata properties the core library defines are of particular importance, and have a direct relation to the "not-so-well made pieces" mentioned above.

## How To Relocate

Relocation is done by executing `MountedPiece.relocate`.  It accepts 3 parameters:

- `target`:  The current target where the core piece DOM tree(s) currently exist.
- `newTarget`:  The new target where the core piece DOM tree(s) must migrate.
- `customRelocate`:  Optional custom logic that moves the DOM tree(s) from where they are to where they should now be.

If the latter is not provided and turns out to be needed because at least one lifecycle function returned `'supported'`, an error is thrown.  To avoid this problem, we usually use the `trivialRelocate` function as the value for `customRelocate`.

`MountedPiece.relocate` will execute all the `relocate` lifecycle functions and make a ruling.  Based on this ruling, `customRelocate` is executed.  Depending on how things go, it eventually returns `true` if the core piece DOM tree(s) were successfully moved, or `false` otherwise.  If `false` is returned, usually we perform a mounting cycle on the new target as workaround.

> **<Info /> Requirements for Relocation**
>
> `MountedPiece.relocate` will *not* attempt relocation if `meta.relocatable` is `false` or if the core piece doesn't have a truthy value in `CorePiece.relocate`.
>
> This means that relocation is still attempted even for pieces that may have forgotten to set `meta.relocatable`, so long there's something to execute in `CorePiece.relocate`.

### The Ruling Algorithm

The current algorithm is a transacted algorithm with rollback abilities.  This design adds robustness to the entire operation.  If one of the `relocate` functions fail, we can go back to a stable state by rolling back.  This allows the `Piece` components in official adapters to fall back to a mounting cycle, all without bothering with error messages or forcing page reloads that make developers lose state.

Every function in the `relocate` lifecycle is expected to return one of these values:

- `'supported'`
- `'done'`
- `'unsupported'`
- `['supported', rollbackFn]`
- `['done', rollbackFn]`

These values have special meaning and trigger different things as the execution of lifecycle functions takes place.  To understand fully, let's define each return value.

| Return Value | Meaning | When to Use |
| - | - | - |
| `'supported'` | The piece is ok if the caller (usually a `Piece` component) relocates the DOM tree.  It doesn't affect the core piece's internal state. | Whenever the core piece's code is independent of its parent element. |
| `'done'` | The function has taken care of everything related to relocating DOM trees, and the caller has no more work left to do. | Whenever the core piece is tightly tied to its host root element, and relocating implies executing code to re-initialize state taking into account the new parent. |
| `'unsupported'` | This piece cannot affort to have its DOM trees relocated. | Whenever relocation of DOM trees in unacceptable. |

> **<FlipHorizontal /> Difference Between `'supported'` and `'done'`**
>
> `'supported'` is the "relaxed" stance:  "I, the core piece, am unaffected by relocation; I continue to work regardless".  The `'done'` value is the "diligent and controlling" stance:  "I, the core piece, has taken the initiative to do the whole thing.  The caller can just sit back and relax".
>
> The former either takes no action, or whichever action is taken doesn't really move DOM trees.  It is up to the caller to complete moving the DOM trees.  The latter is saying that the core piece took it on itself to do everything and that the caller should not interfere or touch things.

Great, so now let's just say that the last 2 possible return values are just like the first 2, but they provide a function that can be called to undo any work done to prepare for relocation.  These functions are only called if relocation is aborted or an error is thrown.

#### Glueing Together All Return Values

With the return value definitions, things started to look normal, until we remember that this is just *one* `relocate` function, and the `relocate` lifecycle can be comprised by an array of functions, meaning we have to reconcile or somehow aggregate the return values of all functions.

This is how aggregation looks like:

- We say we are in a "safe state" if all executed `relocate` functions so far have returned `'supported'` or `['done', rollbackFn]` and there have been zero errors and zero `'unsupported'` values.
- If a function returns `'unsupported'`:
    + If we are in safe state, we simply roll back and `MountedPiece.relocate` returns `false`.
    + If we are in an unsafe state, an error is thrown.
- If all functions return `'done'` (rollback function or not), then `MountedPiece.relocate` does nothing else and returns `true`.
- If at least one function returns `'supported'`, the final aggregation is ruled as `'supported'` and `MountedPiece.relocate` runs the final relocation algorithm to complete relocation.

## When To Use Relocation

As stated in the introduction, the relocation lifecycle is meant primarily as support for HMR scenarios, but truth be told, it is runtime support for live switching of `Piece` components' `shadow` option.

Having said that, *CollageJS* doesn't impose anything regarding usage of the lifecycle.  `Piece` components use it as an aid against the quirks of HMR.  It is up to the consumer of the piece to determine if this lifecycle can serve a specific need beyond its design.  The downside is:  Custom mounting will be necessary so as to obtain access to the `MountedPiece` object, which is only returned as the return value of the core library's `mountPiece` function (or a parent-aware version of said function).  This call is buried in the entrails of `Piece` components and not easily accessible from outside.

## Metadata

By now, there's little else to say about the `CorePiece.meta` object and its properties.  We have seen this metadata in action already.  Let's just formalize definitions here.

The `CorePiece.meta` property is an object that carries (or *can* carry) 2 standardized properties (see below) and any other data the core piece author may want to share with piece consumers.

It's typed using the second type parameter of the `CorePiece` type:

```typescript
import type { CorePiece } from '@collagejs/core';

export type MyCorePieceProps = {
  id: string;
  active?: boolean;
  value?: any;
};

export type MyCorePieceMetaExtension = {
  name: string;
  version: string;
  license: string | URL;
};

export type MyCorePiece = CorePiece<
  MyCorePieceProps,
  MyCorePieceMetaExtension
>;
```

### Standardized Metadata Properties

There are just 2:

- `remountable`
- `relocatable`

The first one is actively used in 2 places:  When official adapters create pieces via `buildPiece`, its value reflects building choice and the piece receives active protection against remounting if the specified value was `false`.  The second place where it is used is inside `Piece` components in official adapters:  Adapters emit a warning if a non-remountable piece just had to be remounted because relocation failed or is not available.

The second one is actively used inside `MountedPiece.relocate` as explained above and it is recommended to be used when composing the `relocate` lifecycle so as to never contradict it and make sure that composition doesn't change the original intention of the core piece.
