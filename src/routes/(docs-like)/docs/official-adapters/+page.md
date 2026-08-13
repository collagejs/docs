---
  title: Official Adapters
  description: |
    Learn how the official CollageJS framework adapters work in order to create core piece objects or mount core piece objects in web applications.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import { Info, Lightbulb } from '@lucide/svelte';
</script>

*CollageJS* framework adapters are libraries that provide the necessary tools to create *CollageJS* core pieces out of a user interface component written using a particular library or framework, such as Svelte or React.

Anyone can create framework adapters, but only official adapters are guaranteed to follow a set of standard features and guidelines to make sure the learning curve is as flat as possible.  The objective is:  Learning how to use one adapter is learning how to use all adapters.  Yes, we agree:  Community-supported adapters are also free to follow our [guide for framework adapters](/guides/development-guide-for-adapters).  We encourage this.

## Adapter Objectives

Every adapter has 2 main objectives:

- Provide a mechanism to create `CorePiece` objects out of the components the adapter's framework produces
- Provide a mechanism to consume (mount/use) `CorePiece` objects in the best possible way that the adapter's framework allows

## Adapter API: Creating Piece Objects

Adapters encapsulate framework-driven user interface components in `CorePiece` objects by providing the `buildPiece` function:

```typescript
export function buildPiece<
  TProps extends Record<string, any> = Record<string, any>
>(
  component: ComponentType,
  options?: BuildPieceOptions,
): CorePiece<TProps>;
```

> **<Lightbulb /> buildPiece Can Be Asynchronous**
>
> So far, all official framework adapters are capable of producing `CorePiece` objects synchronously, but it is acceptable if the `buildPiece` is an asynchronous function.

The parameters are quite self-explanatory:

- `component` -- the component class/function/object that represents a component in the context of the supported framework
- `options` -- optional set of options that, as a minimum offer the options below

These are options found in the options object of all `buildPiece` functions provided by official adapters:

```typescript
export type BuildPieceOptions<
  TMeta extends Record<string, any> = {}
> = {
  remountable?: boolean;
  relocation?: `supported` | `unsupported` | Relocate;
  meta?: TMeta;
}
```

| Option | Default Value | Description |
| - | - | - |
| `remountable` | (framework-specific, usually `true`) | Tells `buildPiece` to mark the piece as remountable when `true`.  If `undefined`, nothing is done.  If `false`, the `CorePiece` is made to explicitly disallow being mounted more than once.  Updates `meta.remountable` with the provided value. |
| `relocation` | (framework-specific, usually `'supported'`) | Tells `buildPiece` to add a `relocate` lifecycle function that reports the desired setting or uses the provided lifecycle function, and updates `meta.relocatable`. |
| `meta` | `undefined` | Accepts an object with custom data that is forwarded as part of the built core piece object.  If a `meta` object is provided, it is appended the `remountable` and `relocatable` properties; if none is provided, one is created with the mentioned properties. |

Other options will most likely exist that will be framework-specific.  Refer to the [API](/api) section for the details.

## Adapter API:  Mounting Piece Objects

The objective is to create a framework-specific helper that can be given a `CorePiece` object or a promise to a `CorePiece` object and the helper can then align the use of the piece's lifecycle functions (`unmount`, `relocate`, `update`) with the lifecycle of components provided by the framework.

Most official adapters provide the framework-specific `<Piece>` component that receives its configuration as properties created using the helper `piece` function in a way that doesn't use any property names, so the property namespace of the `<Piece>` component can be used entirely for the properties exposed by the `CorePiece` component.

The `<Piece>` component is typically used like this:

```html
<Piece
  {...piece(corePieceOrPromiseToCorePiece)}
  componentProperty1="..."
  ...
/>
```
> **<Info /> No Properties in Piece**
>
> Except for the *VueJS* adapter (so far), the properties of the `<Piece>` component are all forwarded to the `CorePiece` object.  In other words:  The `<Piece>` component doesn't have properties of its own; `<Piece>` is configured via the `piece` function.

The helper `piece` function looks something like this:

```typescript
export function piece<
  TProps extends Record<string, any> = Record<string, any>,
  TMeta extends Record<string, any> = {},
>(
  corePiece: CorePiece<TProps, TMeta>,
  options: PieceOptions
): Record<symbol, any>;
```

As a minimum, the options object contains:

```typescript
export type PieceOptions {
  shadow?: boolean | ShadowRootInit;
};
```

| Option | Default Value | Description |
| - | - | - |
| `shadow` | `false` | Controls the type of target the core piece's `mount` lifecycle function(s) receive when the piece is to be mounted. |

Any additional options may exist and will most likely be framework-specific.  Consult the [API](/api) section for information on a specific adapter.

---

**Congratulations!**

You have reached to the end of the "vital" documentation.  Now you have the necessary knowledge to:

- Create *CollageJS* root projects configured with the *Vite-IM* plug-in
- Add import maps to your root projects to define bare module specifiers for core piece modules
- Externalize shared libraries using the import map
- Create *CollageJS* piece projects configured with the *Vite-CSS* plug-in
- Export piece factory functions from entry files using framework-specific adapters
- Understand enough of how *CollageJS* works at its core to even attempt the creation of framework adapters

The rest of the documentation in this section ([Docs](/docs)) pertain to topics that you might need to cover later as you progress with your projects.

You may continue towards completion, or jump to the [Guides](/guides) or [API](/api) sections for references, specific topics and development tips and tricks.
