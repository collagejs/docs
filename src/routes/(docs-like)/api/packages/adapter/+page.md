---
  title: '@collagejs/adapter'
  description: |
    Complete list of exported objects from the @collagejs/adapter NPM package along with detailed explanations on their functionality.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import { Info, Megaphone } from '@lucide/svelte';
</script>

This package contains helper code for the creation of framework adapter libraries.  All official framework adapters consume this code.

> **<Megaphone /> Attention, Framework Adapter Developers!**
>
> It is highly recommended that this library is added as a peer dependency and **not** bundled, should you create a bundled adapter.  This way the adapter can benefit from bug fixing without requiring re-building.

## Classes

### AsyncQueue

This is a general-purpose asynchronous queue.  It enqueues asynchronous work one after the other.  Its main objective is prevent race conditions.

#### Methods

##### _guardDisposed

Checks the disposed status of the object and throws an error if the object has been disposed.

- It is only useful to classes that inherit from this class.

```typescript
_guardDisposed();
```

##### constructor

Initializes a new instance of the class.

```typescript
constructor(abortChainOnError: boolean = false);
```

| Parameter | Description |
| - | - |
| `abortChainOnError` | Configures the queue's internal chain of promises to either absorb any errors thrown by asynchronous tasks automatically so other tasks still execute, or it allows errors to bubble up the entire chain of promises, aborting the entire chain. |

##### enqueue

This is the main class' method.  It enqueues the provided asynchronous work at the end of the chain of pending promises.

- Enqueuing is a synchronous operation.
- Enqueuing does not execute the asynchronous operation at all.
- Unless it is *exactly* what you want, *never* enqueue inside enqueued asynchronous work.

```typescript
enqueue<T extends (...args: any[]) => any>(fn: T): Promise<Awaited<ReturnType<T>>>;
```

| Parameter | Description |
| - | - |
| `fn` | Function that, when executed, performs the desired asynchronous work. |

###### Return Value

A promise that represents the completion and return value of the enqueued work.

##### resetError

When working with queue objects that were configured to abort the entire chain, the entire chain becomes useless, and adding new work automatically throws.  To return the queue object to working state, call this function.

```typescript
resetError(): Promise<void>;
```

###### Return Value

A promise that resolves once the error has been cleared and the internal chain of promises has been reset.

##### transferTo

Transfers the internal chain to another queue object.

- The chain receives error protection if transferred from a non-protected queue to a protected one.
- This action disposes of the current queue object and can no longer be used.

```typescript
transferTo(otherQueue: AsyncQueue)

```

| Parameter | Description |
| - | - |
| `otherQueue` | The queue that will receive this queue's internal promise chain. |

### CorePieceLcQueue

This is a specialization of the `AsyncQueue` class specifically designed to handle a core piece object's lifecycle.  It features all methods of `AsyncQueue` because of class inheritance, plus what's listed below.

#### Methods

##### constructor

Initializes a new instance of the class.

```typescript
constructor(
  corePiece: CorePiece<TProps, TMeta> | Promise<CorePiece<TProps, TMeta>>,
  mountPiece: MountPiece<TProps, TMeta>,
  options?: CorePieceLcQueueOptions
);
```

| Parameter | Description |
| - | - |
| `corePiece` | Core piece object to mount, or a promise that resolves to the core piece to mount. |
| `mountPiece` | Parent-aware `mountPiece` function that will be used to mount the core piece, or the library's root (and parent-unaware) `mountPiece` function. |
| `options` | Optional set of options for the queue. |

###### Options

| Option | Type | Default Value | Description |
| - | - | - | - |
| `relocateFn` | `(source: AcceptableTarget, target: AcceptableTarget) => Promise<boolean>` | `trivialRelocate` | Optional function that performs the relocation of root DOM trees from one parent to another. |
| `enableLcLogging` | `boolean` | `false` | Enables lifecycle logging for debugging purposes. |

##### mount

Enqueues the mount core piece operation.

```typescript
mount(target: AcceptableTarget, props: TProps): Promise<void>;
```

| Parameter | Description |
| - | - |
| `target` | The parent object for the core piece's DOM tree(s).  It can be a DOM element, or it can be a shadow root. |
| `props` | Initial set of property values for the core piece object that will be mounted. |

###### Return Value

A promise that resolves once the mount operation completes.

##### relocate

Relocates a core piece's root DOM tree(s) to a new parent object by first attempting relocation if supported.  If relocation is not supported, it performs a mounting cycle.

- Supporting relocation as a core piece developer tends to improve developer experience.
- Relocation support allows core pieces to maintain internal state.

```typescript
relocate(source: AcceptableTarget, target: AcceptableTarget, props: TProps): Promise<void>;
```

| Parameter | Description |
| - | - |
| `source` | The current core piece's parent object. |
| `target` | The new parent for the core piece's DOM tree(s). |
| `props` | Properties to apply in case relocation is not supported and a mounting cycle needs to be performed. |

##### transferTo

Transfers que internal promise chain to a new `CorePieceLcQueue` object, and ejects its internal state for cleanup purposes.

- Used in specialty cases, most notably in reactive signals-powered frameworks.

```typescript
transferTo(otherQueue: CorePieceLcQueue<TProps, TMeta>): [
  CorePiece<TProps, TMeta> | Promise<CorePiece<TProps, TMeta>>,
  MountPiece<TProps, TMeta>,
  MountedPiece<TProps, TMeta> | undefined
];
```

| Parameter | Description |
| - | - |
| `otherQueue` | The `CorePieceLcQueue` object that will adopt this object's promise chain. |

###### Return Value

A tuple containing the core piece and `mountPiece` function given to the queue object during construction, and the current `MountedPiece` object, which can be `undefined` if the core piece is not mounted by the time this method executes.

##### unmount

Unmounts the core piece.

```typescript
unmount(): Promise<void>;
```

###### Return Value

A promise that resolves once the core piece has finished unmounting.

##### update

Updates the mounted core piece object with the given set of properties.

```typescript
update(props: TProps): Promise<void>;
```

| Parameter | Description |
| - | - |
| `props` | The set of properties that usually carries at least one updated property value.

###### Return Value

A promise that resolves once the core piece has finished updating.

## Functions

### getPieceTarget

Using the given HTML element and shadow option value, returns the correct target object for core piece-mounting.

- This function creates shadow roots without checking for a pre-existing shadow root.

```typescript
function getPieceTarget(
  element: HTMLElement,
  shadow: boolean | ShadowRootInit
): AcceptableTarget;
```

| Parameter | Description |
| - | - |
| `element` | Parent HTML element.  It usually is the `<Piece>` component's root HTML element in official framework adapters.  It must be clean of shadow roots or the function might throw. |
| `shadow` | Shadow root option.  Official framework adapters usually receive this option through the helper `piece` function. |

#### Return Value

The correct target after taking into account the `shadow` option.

### hostAttributes

Function that returns the set of `data-` attributes that are normally applied to host elements (the elements used to mount core pieces).

- Official framework adapters always use this function.

```typescript
function hostAttributes(options: HostAttributesOptions): Record<string, string>;
```

| Parameter | Description |
| - | - |
| `options` | Required set of options that are used to calculate the value of the `data-` attributes. |

#### Options

| Option | Type | Default Value | Description |
| - | - | - | - |
| `shadow` | `boolean \| ShadowRootInit \| ShadowRootMode` | `undefined` | Current shadow option.  The value of the attribute that is derived from this value should reactively update as the backing shadow option changes on reactive frameworks. |
| `framework` | `string` | `undefined` | If provided, the framework attribute is added to the returned list of attributes. |

#### Return Value

A POJO whose keys are the `data-` attribute names and their values is the corresponding attribute value.

### trivialRelocate

Relocates all root DOM trees found in the source object to the target object by simply appending them with `appendChild`.

- The order of the DOM trees is kept.

```typescript
function trivialRelocate(source: AcceptableTarget, target: AcceptableTarget): boolean;
```

| Parameter | Description |
| - | - |
| `source` | The source object containing the DOM trees to be moved. |
| `target` | The target object that will be the new parent of the DOM trees. |

#### Return Value

A boolean value that indicates success of the operation.

> <Info /> Currently, it always returns true.

## Constants & Objects

### frameworkDataAttribute

The actual name of the `data-` attribute that discloses the framework name the framework adapter is for.

### hostDataAttribute

The actual name of the `data-` attribute that discloses the type of target object the host element has provided to the core piece.

| Value of `shadow` | Attribute Value |
| - | - |
| `false` | `'dom'` |
| `true` or `{ mode: 'open', ... }` | `'open'` |
| `{ mode: 'closed', ... }` | `'closed'` |
