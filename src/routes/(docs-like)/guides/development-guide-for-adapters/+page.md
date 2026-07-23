---
  title: Development Guide for Adapters
  description: |
    Describes the requirements and best practices to follow when creating a new CollageJS framework adapter.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import { Flag, Info, Lightbulb, MessageCircleQuestionMark, TriangleAlert } from '@lucide/svelte';
</script>

The term *framework adapter* is used to refer to a library that provides developers the ability to do at least one of the following:

- Create CollageJS `CorePiece` objects out of a user interface component
- Mount CollageJS `CorePiece` components, usually imported from outside the current project

Official framework adapters attempt to expose a unified API so the learning curve is not increased by increasing the number of framework adapters.  The ideal scenario is for all adapters to expose, as much as possible, an identical API.  This way, developers need only to learn how to use one adapter, and this will carry over to every other adapter.

We know for a fact that this is not 100% possible.  We like having the ability to configure Svelte's `mount` function call, or React's `createRoot` function call.  This is one place where we cannot provide the exact same interface.

Despite our desire to standardize API, we also desire maximum flexibility.  We value individual front-end framework abilities over the standard.  Our stance is to never discard a great framework feature for the sake of standardization, and thus, we encourage adapter developers to make the most out of the front-end framework the adapter is for.

## Public API

> **<Info /> Adapter Library**
>
> The code examples above might import types and code from `@collagejs/adapter`.  This is a helper library for adapter development.
TODO: Add link to the documentation in the api/ route.

Adapters should ideally fulfill the aforementioned 2 tasks.  The public API to create a *CollageJS* piece should be a function called `buildPiece`, while the public API to mount *CollageJS* pieces should be a framework-specific component named `Piece`.

### buildPiece

The buildPiece function should have the following signature:

```typescript
import type { CorePiece, Relocate } from '@collagejs/core';

declare function buildPiece<
  TProps extends Record<string, any> = Record<string, any>,
  TCap extends Record<string, any> = {}
>(component: FrameworkTypeForComponent<TProps>, options?: OptionsType<TCap>): CorePiece<TProps, TCap>;
```

The `OptionsType` type should at least allow the specification of custom capabilities that correspond to the `TCap` type parameter.  It is also OK if this type is dependant on the `TProps` type parameter as well.

The other feature that an adapter should support in its option is `relocation?: 'supported' | 'unsupported' | Relocate`, which should trigger the creation of the `CorePiece` object with the requested relocation support.

Summarizing, `OptionsType` should at least be:

```typescript
import type { CorePieceCapabilities } from '@collagejs/core';

export type Options<TCap extends Record<string, any> = {}> = {
  relocation?: 'supported' | 'unsupported' | Relocate;
  capabilities?: CorePieceCapabilities & TCap;
}
```

Beyond this, adapter developers should make the most out of the framework the adapter is for.  For example, the Svelte adapter allows specification of both mounting and unmounting options supported by Svelte v5's `mount` and `unmount` functions.

> **<TriangleAlert /> Disallow Target Specification**
>
> Every framework at some point has to determine a particular HTML element where to mount.  Be 100% this cannot be specified during `CorePiece` creation.  For example, the Svelte adapter emits a console warning if the `mount`'s `target` option is set by the caller.

#### Implementation Details

The goal is to return an object of type `CorePiece<TProps, TCap>` with the specified capabilities and relocation support.  Anything beyond this is optional, and developers should make full use of the front-end framework's features at their disposal.

An implementation for `buildPiece` could look similar to this:

```typescript
import { preventRemount } from '@collagejs/core';

export function buildPiece<
  TProps extends Record<string, any> = Record<string, any>,
  TCap extends Record<string, any> = {}
>(component: AmazingComponent<TProps>, options?: Options<TCap>) {
  const instanceCtx = new SomeInstanceContextClass<TProps, TCap>();
  // A default value of 'supported' is encouraged, but framework nature and abilities
  // should be taken into account to decide this default value.
  const relocation = options?.relocation ?? 'supported';

  return {
    mount: options?.capabilities?.remountable === false ?
      [preventRemount(), mount.bind(instanceCtx)] :
      mount.bind(instanceCtx),
    update: update.bind(instanceCtx),
    relocate: typeof relocation === 'string' ? () => Promise.resolve(relocation) : relocation,
    get capabilities() {
      return options?.capabilities;
    } satisfies CorePiece<TProps, TCap>;
  };

  function mount(this: SomeInstanceContextClass<TProps, TCap>, ...) { ... }
  function update(this: SomeInstanceContextClass<TProps, TCap>, ...) { ... }
}
```

This is one possible way to implement that shows a few important things:

- If the caller explicitly states that the piece cannot be remounted, add `preventRemount()` to the list of mounting functions.
- If it is customary for the framework components to not care about their parent element, a default value of `'supported'` for the `relocaiton` option is encouraged.
- We forward the capabilities object specified in the options.
- All functions returned in the `CorePiece` object must not care about their context (the value of `this`) or must be pre-bound to a context, like the example shows.

### Piece Component

This is a difficult section because a particular framework could do things so differently to others that any code snippets presented here end up being worthless for said framework.  However, we can still explain the concepts and best practices, and whether or not `@collagejs/adapter` provides help for something specific.

Most front-end frameworks work with the concept of `Component` defined as a complete unit of code that produces zero or more DOM trees that end up mounted somewhere in an HTML document.  With this definition, we want to create a `Piece` component (a unit of code that satisfies the definition of our front-end framework's `Component` term) that can accept a `CorePiece` object --usually through its "properties" mechanism-- and mounts it where we want it mounted.

For the `Piece` component, we want to achieve a component that:

- Doesn't affect the properties namespace
- Provides the ability to mount in light DOM, open or closed shadow roots
- Provides a method for specifying container element properties/attributes and event callbacks
- Can inherit/transmit new parent-aware `mountPiece` function created by mounting the core piece down the DOM tree
- Mounts the core piece given to it using the parent-aware `mountPiece` function
- Marks the container element with the `data-cjs-piece-host` and `data-cjs-framework` attributes

#### Tackling Properties Namespace, Shadow Mounting & Container Properties

Most front-end frameworks and libraries allow data to their components in the form of a POJO.  If this is the case for the framework at hand, we can achieve the trick by using a symbol:

```typescript
const pieceProps = symbol();
```

We can then accummulate any number of properties in the component's properties without consuming a property name.  However, it would be a bit cumbersome for consumers of the adapter if they had to do the symbol syntax on their own.

Because of this, official adapters export the `piece` (lowercase because the uppercase form is for the component itself) helper function that deals with the symbol-in-POJO syntax so consumers of the adapter library don't have to:

```typescript
export function piece<
  TProps extends Record<string, any> = Record<string, any>,
  TCap extends Record<string, any> = {}
>(piece: CorePiece<TProps, TCap>, options?: PieceOptions) {
  return {
    [pieceProps]: {
      piece,
      ...options
    },
  };
}
```

Where the `options` parameter is usually used to carry the shadow-mounting preference and the container element properties and event callbacks.  The standardized typing for the options in official adapters is:

```typescript
export type PieceOptions {
  shadow?: boolean | ShadowRootInit;
  containerProps?: IdeallyAFrameworkProvidedTypeToTypeContainerProperties;
  // Add any other options that might be frameworks-specific
}
```

The typing for the `shadow` property is standard because `@collagejs/adapter` offers the `getPieceTarget` that defines a `shadow` parameter with this exact type, so this makes it simple (and standard) to use.

> **<MessageCircleQuestionMark /> What if this trick is inapplicable?**
>
> We haven't encountered such case.  If you have, please resolve it and let us know how you did it!
> 
> Truthfully, if it cannot be done, it cannot be done.  We would love for this to be doable in all cases as this is the standard API in official adapters, but we prefer a working adapter than no adapter at all.  Let's just always think about the simplest possible API for the consumers.

#### Tackling `mountPiece` Requirements

All popular front-end solutions offer the concept of *component context*, which consists in storing and obtaining a labeled (named) piece of information that is "closest" to the component requesting it.  Different information may be found from different positions in the DOM tree.

This concept is perfect for tackling the `mountPiece` requirements and is the mechanism used in official adapters.

To implement, we have to put the `buildPiece` function to work in tandem with the `Piece` component.

On the `buildPiece` side, the *CollageJS* runtime guarantees that the parent-aware `mountPiece` function is hidden inside the properties POJO passed on to all core piece `mount` lifecycle functions, **if there's already a `CorePiece` parent**.  It hides it using a named symbol.  The symbol can be obtained by importing it from `@collagejs/core`:

```typescript
import { mountPieceKey } from '@collagejs/core';
```

The symbol is used as the property name in the properties POJO coming from the runtime in `mount` lifecycle functions:

```
export function buildPiece<...>(...) {
  return {
    mount: mount.bind(...),
    ...
  };

  function mount(this: ..., props?: MountProps<TProps>) {
    // So this is of type MountPiece or undefined
    const mountPieceFn = props?.[mountPieceKey];
  }
}
```

At this point, we should pass that value of `mountPieceFn` as context value for the component we are mounting.  This is framework-specific, so we cannot really provide an example, as every front-end technology will have their own way of creating context.

Once this is completed, we have taken care of the inheritance requirement.

Next in line is to fulfill the usage requirement.

In the `Piece` component we retrieve the `mountPiece` function stored in context.  If the context is empty, then default to use `mountPiece` from `@collagejs/core`.

#### Fulfilling the Attributes Requirement

As mentioned before, we have a helper library available for adapter development:  @collagejs/adapter
TODO: Add link to API documentation

One of the exported functions from `@collagejs/adapter` is `hostAttributes` and returns a POJO with the two attributes ready to be spreaded onto the container element (assuming spreading is possible for the front-end framework we're developing this for):

```typescript
import { hostAttributes } from '@collagejs/adapter';

const containerAtts = hostAttributes({ shadow, 'framework name' });
```

The type for `shadow` is the one we mentioned already as standard:  `boolean | ShadowRootInit`.  Provide it along with the framework's name (i. e. React, Svelte, Lit, Angular, Ripple-TS, etc.) and the function returns the attributes ready to go.

#### Piece Best Practices

Perhaps the most critical one is avoiding race conditions when executing lifecycle functions.  Let's remember that all lifecycle functions are asynchronous operations.

In order to avoid race conditions, always execute lifecycle functions using the `CorePieceLcQueue` class provided by `@collagejs/adapter`:

```typescript
import { CorePieceLcQueue } from '@collagejs/adapter';

const lc = new CorePieceLcQueue(corePiece, mountPieceFn, {
  relocateFn: relocationFn, // Only if the algorithm cannot be the one provided by trivialRelocate
  enableLcLogging: true,
});
```

> **<Lightbulb /> What is `trivialRelocate`?**
>
> It is a function in `@collagejs/adapter` (that can be imported if needed), with the simplest algorithm to transfer root DOM elements from one DOM element to another.  If a front-end framework doesn't need to do anything special to relocate the DOM trees a component produces, relocation can be delegated to `trivialRelocate`.

Now `lc` is a class that enqueues asynchronous actions one after the other, and has an almost identical interface to that of `MountedPiece`, which is what `mountPiece` returns when used directly.

This is how it is used:

```typescript
import { CorePieceLcQueue, getPieceTarget } from '@collagejs/adapter';

const lc = new CorePieceLcQueue(corePiece, mountPieceFn, {
  relocateFn: relocationFn, // Only if the algorithm cannot be the one provided by trivialRelocate
  enableLcLogging: true,
});

// MOUNTING
// --------
const containerElement = getContainerElementSomehow();
// shadow is the shadow option specified for the piece component of type boolean | ShadowRootInit.
const target = getPieceTarget(containerElement, shadow);

lc.mount(target, props);

// UPDATING
// --------
lc.update(newProps);

// UNMOUNTING
// ----------
lc.unmount();

// relocating UI
// -------------
lc.relocate(currentTarget, newTarget);
```

Each one of these calls enqueue the work instead of synchronously doing it.  They all return a promise that can be awaited for frameworks that allow top-level await, or for awaiting inside functions.

The queue object also has a generic `enqueue` method to enqueue arbitrary logic.  For example, it might be very possible that the `currentTarget` variable above is a component-level state variable that needs to be updated after the relocation process finishes.  The new assignment needs to be queued instead of be done immediately:

```typescript
lc.relocate(currentTarget, newTarget);
lc.enqueue(() => void (currentTarget = newTarget));
```

> **<TriangleAlert /> Never Nest Enqueues!**
>
> Well, never say NEVER.  Maybe there's are very rare edge case that might call for nested enqueues, who knows!  But as a general rule, never do `lc.<method>(...)` inside an enqueued function because most likely is not what we want.  Instead, do enqueueing outside at the component level.

Now, to finally complete the queueing lesson:  The front-end framework might allow developers to change the core piece object at will without unmounting our `Piece` component.  Because `CorePieceLcQueue` objects are tied to a corePiece object (and the parent `mountPiece` function shared in context), a new queue object must be created if either of these change (reactively in modern frameworks).  If this happens, we don't just drop the current queue as it might have pending work enqueued.  What we do is *transfer the internal queue*:

```typescript
const newLc = new CorePieceLcQueue(newPiece, newMountPieceFn, ...);
const [oldCorePiece, oldMountPiece, oldMountedPiece] = lc.transferTo(newLc);
// Use the "ejected" internal state to clean up.  Most commonly, unmount.
newLc.enqueue(oldMountedPiece.unmount);
newLc.mount(currentTarget, props);
lc = newLc;
```

#### When to Relocate

Relocate exists primarily as an enhancement to developer experience.  During the course of development, source code changes, which causes modules to reload, which might trigger updates to reactive properties on frameworks that feature them.  Furthermore, code around properties could change that could cause a change of target element that might be patched by HMR as variable updates instead of module reloads.

Errors that may occur in HMR scenarios can be mitigated or eliminated by relocating when the target changes instead of unmounting and remounting in the new target.  As a general rule, the `Piece` component should attempt relocation before a mounting cycle for the cases where the target element changes.

To provide some guidance as code, this is how the Svelte `Piece` component handles a reactive change in the `shadow` option:

```typescript
$effect(() => {
  shadow;
  if (firstRun || !target) {
    return;
  }
  const newTarget = getPieceTarget(containerEl!, shadow);
  if (newTarget === target) {
    return;
  }
  lc.relocate(target, newTarget, restProps);
  lc.enqueue(() => (target = newTarget));
});
```

Note that `CorePieceLcQueue.relocate` automatically performs a mounting cycle if the underlying  `CorePiece` object doesn't support relocation or relocation fails.

Relocation is an advanced topic.
TODO:  Add the topic link here
