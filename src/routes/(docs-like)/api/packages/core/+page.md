---
  title: '@collagejs/core'
  description: |
    Complete list of exported objects from the @collagejs/core NPM package along with detailed explanations on their 
    functionality.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import { Info } from '@lucide/svelte';
</script>

This package contains *CollageJS*' core functionality:  The lifecycle functions for all `CorePiece` objects.

## Classes

### Stack

Class that represents a stacked collection.  It is used internally to store rollbacks and unmounts, but help yourself if you're in need of one of these.

- The class is iterable from top to bottom: `[...myStack]` creates an array where the first element is the most recently-added element in the stack.

#### Properties

| Property | Type | Description |
| - | - | - |
| `size` | `number` | Gets the current stack's size (length). |
| `length` | `number` | Synonym for `size`. |

#### Methods

##### bottomToTop

Creates an iterator that iterates the stack from bottom to top.

- It can be spread (`[...stack.bottomToTop()]`) or iterated with `for..of`.

###### Signature

```typescript
bottomToTop(): Iterator<T>;
```

###### Return Value

An iterator object that iterates the stack from bottom to top.

##### clear

Empties the stack.

###### Signature

```typescript
clear(): void;
```

##### delete

Removes the first element that matches the provided predicate function.

- The algorithm traverses the stack from top to bottom.

###### Signature

```typescript
delete(predicate: (item: T) => boolean): boolean;
```

###### Parameters

| Parameter | Description |
| - | - |
| `predicate` | Predicate function called on each item in the stack until it returns `true` or no more items exist. |

###### Return Value

`true` if an element was removed, or `false` otherwise.

##### fromArray (static)

Creates a new stack object pre-filled with the items in the provided array.

- The array is interpreted as bottom-to-top.
- Accepts empty arrays.

###### Signature

```typescript
static fromArray<U>(items: U[]): Stack<U>;
```

###### Parameters

| Parameter | Description |
| - | - |
| `items` | The items to stack in the new stack object. |

###### Return Value

A new `Stack` object containing the provided items.

##### isEmpty

Checks is the stack is empty.

###### Signature

```typescript
isEmpty(): boolean;
```

###### Return Value

`true` if the stack is empty, or `false` otherwise.

##### peek

Returns the item at the top of the stack without removing it.

###### Signature

```typescript
peek(): T | undefined;
```

###### Return Value

The item at the top of the stack, or `undefined` if the stack was empty.

##### pop

Removes the item at the top of the stack.

###### Signature

```typescript
pop(): T | undefined;
```

###### Return Value

The item that was at the top of the stack, or `undefined` it the stack was empty.

##### push

Pushes a new item at the top of the stack.

###### Signature

```typescript
push(item: T): number;
```

###### Parameters

| Parameter | Description |
| - | - |
| `item` | The item to be push into the stack. |

###### Return Value

The new stack's size.

##### toArray

Creates a shallow copy of the stack as an array, in stack order (bottom first).

###### Signature

```typescript
toArray(): T[];
```

Return Value

The desired new array.

##### top

Alias for [peek](#peek).

##### toString

Creates a string representation of the stack using the string representation of the contained items.

###### Return Value

The string representation of the stack object.

## Functions

### ensureGlobalCollageJs

Ensures the global object `CollageJs` exists in the JavaScript environment.  This is a namespacing prevision to allow for tooling for *CollageJS* in the browser.  Its only use so far comes from the [@collagejs/imo](/api/packages/imo) NPM package.

- Any code that wishes to install something inside this object must first call this function.

#### Signature

```typescript
function ensureGlobalCollageJs(): void;
```


### mountPiece

Mounts the provided `CorePiece` object inside the provided `target`.  The function doesn't make any assumptions about the current contents of the target object or whether the core piece can be safely remounted (for the cases where the same core pice object is mounted more than once).

- Once the returned promise resolves, the core piece is mounted and visible (if applicable) inside the provided target.
- The mounting process will have given the children-aware `mountPiece` function to the core piece's `mount` lifecycle function via the initial properties object, under the symbol `mountPieceKey`.

#### Signature

```typescript
function mountPiece<
  TProps extends Record<string, any> = Record<string, any>,
  TCap extends Record<string, any> = {}
>(
    piece: CorePiece<TProps, TCap>,
    target: AcceptableTarget,
    props?: TProps,
): Promise<MountedPiece<TProps, TCap>>;
```
#### Parameters

| Parameter | Description |
| - | - |
| `piece` | Core piece object to mount. |
| `target` | Target DOM element or shadow root where the core piece will mount. |
| `props` | Optional set of properties given to the core piece as initial property set. |

#### Return Value

An instance of the `MountedPiece` class that manages the mounted piece and has/gains knowledge of child core pieces mounted by the mounted core piece.

> **<Info /> Class Not Exported**
>
> The `MountedPiece` class itself is not exported, but the exported types do export the `MountedPiece` interface that is used to type this return value.

### noopPiece

Returns an object that minimally satisfies the `CorePiece` type.

- The returned object is **the same object on every call**.  In other words, the returned value is a singleton.
- Used to obtain a test or placeholder core piece that is appropriately typed.

#### Signature

```typescript
function noopPiece<
  TProps extends Record<string, any> = Record<string, any>,
  TCap extends Record<string, any> = {},
>(): CorePiece<TProps, TCap>;
```

### preventRemount

Generates a mount lifecycle function that can only be called once.  If it is called more than once, then an error is thrown.

- Use it freely on core piece object creation whenever remounting should be strictly disallowed.
- Official framework adapters automatically add it if `capabilities.remountable` is explicitly set to `false`.
- The most logical place for the generated function is at the beginning of the array of mount functions.

#### Signature

```typescript
function preventRemount<
  TProps extends Record<string, any> = Record<string, any>
>(): MountFn<TProps>;
```

#### Return Value

A function that satisfies the signature for mount lifecycle functions that prevents core piece remounting.

## Constants & Objects

### mountPieceKey

Constant value of type `symbol` used to deliver the children-aware `mountPiece` function to the core piece object using the piece's initial properties POJO.

Official framework adapters usually extract this `mountPiece` function from the properties POJO and make it available through the framework's contextual data system.
