---
  title: Migration From Single-SPA
  description: |
    Detailed guide on how to migrate micro-frontend projects powered by single-spa to projects powered by CollageJS.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import { Check, CircleSlash, Info, Lightbulb, MessageCircleQuestionMark, TriangleAlert } from '@lucide/svelte';
    import SingleSpaIcon from '$lib/SingleSpaIcon.svelte';
    import CollageJsIcon from '$lib/CollageJsIcon.svelte';
</script>

One of the more popular micro-frontends solution, *single-spa*, was the main source of inspiration for *CollageJS*.  This means that we will encounter many similarities around the foundations of both libraries.  Let's get started.

## Comparing *Single-SPA* and *CollageJS*

*CollageJS*' main inspiration is the concept of *single-spa parcels*.  *CollageJS* drops the routing capabilities and the concept of *"micro-frontend project"*.  It retains the concept of *root project* but not with identical requirements.  This very short description and the willingness to correct design flaws and bugs currently found in *single-spa* is what brings *CollageJS* to life.

At the core, we find the foundation block of the libraries:  For *single-spa*, it is the concept of *micro-frontend*, which is later adopted almost without change by the *parcel* concept; for *CollageJS*, the concept is named *core piece*.

### Similarities

This list should set *single-spa* developers' minds in tune:

- The foundational block is an abstraction of a user interface component that can be mounted, unmounted or updated.
- All component operations are asynchronous by definition.
- Composition is allowed for every lifecycle function:  Instead of exporting a function, an array of functions can be exported.
- Composed lifecyle functions are run and awaited in order; one failure in the chain fails the entire chain.
- Components (parcels in *single-spa* and pieces in *CollageJS*) can mount other parcels/pieces, and the core library tracks parent-child relationships.
- Unmounting a component will first unmount all child components.
- Framework adapter libraries exist that provide the same 2 main functions:  Produce parcels/pieces and provide a framework-specific component to mount parcels/pieces.
- Use of import maps to facilitate working with other projects' URL's and externalized dependencies.
- Import map entry overriding tool.

### Differences

Let's tabulate the differences.  Some of these are actual problems or bugs found in *single-spa* that *CollageJS* has explicitly accounted for during its development.

| <SingleSpaIcon /> Single-SPA | <CollageJsIcon /> CollageJS |
| - | - |
| Parcel/microfrontend requires specific module exports. | No restriction as to what is exported from a module. |
| Lifecycle functions: `bootstrap`, `mount`, `unmount`, `update` | Lifecycle functions: `mount`, `relocate`, `update` |
| Built-in client-side router | No router offering. |
| Global state data in core library. | No global state data in core library. |
| Minified error messages. | No minified error messages (at least to date). |
| Plug-in for webpack. | Only plug-ins for Vite. |
| Support for module types like *SystemJS*. | Only supports ES modules. |
| Partial TypeScript support. | Full TypeScript support. |
| Not designed to load multiple copies of the same parcel. | Fully supports mounting multiple copies of the same core piece. |
| All parcels must be imported with dynamic `import()`. | Core pieces can be imported with static import statements. |
| Parcels are defined at the module level. | The recommendation is to export core piece factories. |
| Can only mount parcels in light DOM. | Can mount core pieces in light DOM, open or closed shadow roots. |
| Cannot detect CSS bundles (provides partial support in webpack). | Can inject all bundled CSS files, including cases where CSS is split. |
| Core library global object; global object passed as property to parcels. | No global object. |
| Parcel components in adapters reserve property names like `config`. | Piece components don't reserve any property names. |
| Relatively complex set of rules to determine target element for mounting. | No algorithm to determine target; target is provided explicitly. |
| No control over the target component where parcels mount. | Almost full control over the target (or container element if the target is a shadow root). |
| Not possible to relocate a parcel unless unmounted and remounted. | Opt-in ability to have the core piece's generated DOM trees moved to a new target without a mounting cycle. |
| `cssLifecycleFactory` from `vite-plugin-single-spa` requires an explicit file name. | `CssFactory` from `@collagejs/vite-css` happily takes `import.meta.url` as argument. |

> **<MessageCircleQuestionMark /> Where did `unmount` and `bootstrap` go?**
> 
> In *CollageJS*, the mounting function returns the unmounting function.  As for `bootstrap`... well, we lost it.  There is no equivalent lifecycle function in *CollageJS*.

Furthermore, the list of official adapters for *CollageJS* is more reduced (at least for the time being) but covers more modern options.  For the first stable version 1.0 release (end of 2026/start of 2027), we want to have official adapters for:

- Preact
- **React**
- Ripple-TS
- SolidJS
- **Svelte**
- **VueJS**

Where the ones in bold already exist.

> **<MessageCircleQuestionMark /> What about Angular?**
>
> We agree that *Angular* is a popular front-end framework.  However, we don't dare list it because we don't currently have any expertise in this framework, and it is a framework with a rather steep learning curve.  We might decide to delegate the creation of the adapter to an artificial intelligence and make the fact public.
>
> Alternatively, we would love it if a member or members of the *Angular* community contributed the adapter in accordance to the [guidelines for adapters](/guides/development-guide-for-adapters).

---

Great, so now we can speed things up a little because we know what is and what isn't.

## Must-Have's

Your projects must satisfy a small set of absolute, non-negotiable requirements if the Vite plug-ins and the framework adapters are desired:

- If the project is not Vite-powered and you would like to use our plug-ins, migrate to Vite.
- If the project is for React v17 or earlier, migrate to at least React v18.
- If the project is for Svelte v4 or earlier, migrate to Svelte v5.
- If the project uses a Vue runtime less than v3.3, upgrade to at least v3.3.

> **<Info /> Requirements Are for Goodies**
> 
> If a project cannot meet the must-have's, it can still work with *CollageJS*.  The `@collagejs/core` and `@collagejs/imo` libraries don't have any of these requirements.  Goodies are the Vite plug-ins and framework adapters.  The worst that can happen is that `@collagejs/imo` won't be able to share the import map with the project that could not satisfy the Vite plug-in must-have's.

## Migrating the Root Project

If your root project uses *single-spa*'s client-side router, you must first decide what you'll do to replace it.  *CollageJS* doesn't provide client-side routing, but the good news is that many client-side routers exist.  Furthermore, we encourage people to use their favorite front-end library or framework to create the root project, and that probably comes with a client-side router you probably know very well.

If you would like to entertain the idea of other routers like framework-agnostic ones, you may also do so.  There must be many.  Here we'll list one framework-agnostic router, then one for React and finally one for Svelte:

- [universal-router](https://www.npmjs.com/package/universal-router)
- [react-router](https://www.npmjs.com/package/react-router)
- [webJose's Svelte Router](https://svelte-router.dev)

### The Root Template Route

You may also opt to clone the root template repository we have available:

```bash
npx degit https://github.com/collagejs/root-template.git
```

Or [clone it using GitHub's template feature](https://github.com/new?template_name=root-template&template_owner=collagejs).

What you get is a *Vite + Svelte v5 + TypeScript* project with *webJose's Svelte Router* installed and configured.  This client-side router has significant advantages for micro-frontends:

- Matches multiple routes at once
- Does path and hash routing, and does them simultaneously
- Can store multiple, independent paths in the fragment (hashtag)
- Can activate user interfaces in disconnected places for the same route
- Can take over the browser's history API to battle/counter actions from other client-side routers

The list is quite hard to beat, in all honesty.

> **<Lightbulb /> Want the router but not the template?**
>
> No problem.  Just create a new *Vite + Svelte* project using `npm create vite@latest` and install the router with `npm i @svelte-router/core`.

---

Great, so now we have a Vite-powered root project, either because:

1. We followed the instructions above
2. We already had a *single-spa* root project that was Vite-powered and using `vite-plugin-single-spa`

### Install the Vite Plug-In

Remove `vite-plugin-single-spa` (if present in the project) and install `@collagejs/vite-im`:

```bash
npm i -D @collagejs/vite-im
```

Make the changes in `vite.config.ts`:

```typescript
import { cjsImPlugin } from '@collagejs/vite-im';

export default defineConfig({
  plugins: [..., cjsImPlugin()],
  ...
});
```

We are done.  This plug-in provides the same capabilities of `vite-plugin-single-spa`, but differently:

| Feature | <SingleSpaIcon size="1em" />&nbsp;vite-plugin-single-spa | <CollageJsIcon size="1em" />&nbsp;@collagejs/vite-im|
| - | - | - |
| Import map injection | <Check size="1em"/> | <Check size="1em"/> |
| Import map overriding | <Check size="1em"/> through `import-map-overrides` | <Check size="1em"/> through `@collagejs/imo` |
| Automatic externalization of everything in the import map | <CircleSlash size="1em"/> | <Check size="1em"/> on build<br /> <Check size="1em"/> on serve |
| Import modes for externalized module specifiers | <CircleSlash size="1em"/> Static import statement<br /><Check size="1em"/> Dynamic `import()` | <Check size="1em"/> Static import statement<br /><Check size="1em"/> Dynamic `import()` |

> **<Info /> @collagejs/imo**
>
> This is a more advanced import map-overriding package that has dropped support for every module type except ESM.  [Learn about it here](/api/packages/imo).

## Migrating Micro-Frontend and Parcel Projects

There is no concept of a *micro-frontend project* in *CollageJS*, so they will migrate to a *CollageJS piece project*.  After all, pieces are not restricted in size.

> **<Info /> Retain *single-spa* Functionality**
>
> While we're not actively recommending this, you can theoretically use the same code base to produce a *single-spa*-compliant build and a *CollageJS*-compliant build.  This should be a viable path for people wanting to migrate progressively.  What you need is a second Vite configuration file and retain the creation of the *single-spa* parcel/micro-frontend modules.

### (Optional) Clean Up

- Uninstall `vite-plugin-single-spa`
- Delete *single-spa* module files (i. e. `src/spa.ts` and similar)

### Set Up

Start by installing the CSS plug-in:

```bash
npm i -d '@collagejs/vite-css';
```

Now use the plug-in in Vite's configuration (`vite.config.ts` or a separate, new Vite config file):

```typescript
import { cjsCssPlugin } from '@collagejs/vite-css';

export default defineConfig({
  plugins: [..., cjsCssPlugin({
    serverPort: 6101,
  })],
  ...
});
```

The default entry file for this plug-in is `src/piece.ts` (as opposed to `vite-plugin-single-spa`'s `src/spa.ts`).  You may proceed with this name or do the needful to configure another name or names in the plug-in.

For each entry file, export *core piece factory functions*.  **Don't export core piece objects directly.**  We do this so we can use clean instances every time, and to enable mounting the same core piece in multiple places (by creating multiple instances of the same core piece).  This is example code that assumes a React project that exports a Markdown editor piece:

```typescript
import { buildPiece } from '@collagejs/react';
import { CssFactory } from '@collagejs/vite-css/ex';
import MarkdownEditor from './src/MarkdownEditor.jsx';

const css = new CssFactory(import.meta.url);

export function markdownEditorFactory() {
  const { mount, relocate } = css.instantiate();
  const piece = buildPiece(MarkdownEditor);

  return {
    ...piece,
    mount: [mount, piece.mount],
    relocate: [piece.meta.relocatable && relocate, piece.relocate]
  };
}
```

We are done... with the basics.  Now the project produces *CollageJS* pieces.  If you also skipped clean-up, then the project is also still capable of producing *single-spa* micro-frontends or parcels.  All that is needed is two different `build` commands in `package.json` that use different Vite configuration files.

There's a bit more we can do to take advantage of the more advanced *CollageJS* plug-in.  This is found in the next section.  In the meantime, here's a summary of what you've gained.

| Feature | <SingleSpaIcon size="1em" />&nbsp;vite-plugin-single-spa | <CollageJsIcon size="1em" />&nbsp;@collagejs/vite-css |
| - | - | - |
| CSS injection | <Check size="1em"/> | <Check size="1em"/> |
| Support for multiple instances | Partial due to *single-spa* design limitations | <Check size="1em"/> |
| FOUC prevention | <Check size="1em"/> | <Check size="1em"/> |
| Ease of use | Baseline: The entry's file name must be passed hardcoded in the call to `cssLifecycleFactory` | Improved: we pass `import.meta.url` which follows file renames |
| Vite's `base` option requirement | Required for correct CSS serving | Not required if the only assets in the project are the CSS and JS chunks |
| Vite development server support | <Check size="1em"/> | <Check size="1em"/> |
| Vite preview server support | <Check size="1em"/> | <Check size="1em"/> |
| Auto-externalization of import map | <CircleSlash size="1em" /> | <Check size="1em"/> on serve<br /><Check size="1em"/> on build if a copy of the import map is provided |

## The Hidden Plug-In:  @collagejs/vite-aim

The *aim* part of the plug-in's name is an acronym for *auto-externalize import map*.  This is its main job and the way it does it is quite unique.  This plug-in is automatically added by `@collagejs/vite-im` and `@collagejs/vite-css`, hence a "hidden" plug-in.

This plug-in adds an endpoint to Vite's development server that accepts the application's import map.  Who sends this information?  The answer is `@collagejs/imo`, the package in charge of overriding import map entries.

`@collagejs/imo` does its job of overriding entries and then sends a copy of the resulting import map to all Vite development servers mentioned in the resulting import map, plus the application's origin.

Once the AIM plug-in has this import map, it uses it to resolve import statements on behalf of *Rolldown*.  The result:  We don't have to configure externalizations ourselves in root projects.  The story is different for core piece projects because we don't have an import map file (or files) there like we do have in the root project.  In other words:  We can skip externalization in root projects without extra work, but we have to do a little bit of work in core piece projects.

### Module Externalization in Core Piece Projects

It can be done the traditional way, setting up the list of module specifiers in Vite's `build.rolldownOptions.external` option, or we can go the import map way provided by `@collagejs/vite-aim`.  The latter would look similar to this:

```typescript
import { cjsCssPlugin } from '@collagejs/vite-css';

export default defineConfig({
  plugins: [..., cjsCssPlugin({
    serverPort: 6101,
  }, {
    importMap: {
      imports: {
        react: "https://my-cdn-of-choice...",
        "react-dom": "https://my-cdn-of-choice...",
      }
    }
  })],
  ...
});
```

## Wrap-Up

As seen, the code migrations are quite simple and familiar while still gaining significantly in developer experience and bug-riddance:

- Full TypeScript support
- Mount and use as many copies of a core piece as needed
- Don't fight or work around layout issues coming from the unmaintained layout engine from `single-spa` and instead route like a boss with your favorite router
- If an adapter exists for your framework, it covers both creating pieces and mounting pieces, not just one
- Isolate pieces easily by mounting them in shadow DOM
- No more name collisions on the property namespace for pieces and the `<Piece>` component used to mount it
- No issues with React's *Strict Mode* as `@collagejs/react` works perfectly under it
- All options for React's `createRoot` can be specified
- React, Svelte and Vue all provide the `update` lifecycle
- Idempotent `unmount` lifecycle

Enjoy *CollageJS*!
