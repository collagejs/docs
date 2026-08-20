---
  title: Vite-IM Plug-In
  description: |
    Learn the objectives @collagejs/vite-im fulfills and how for the micro-frontend root project.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import { Lightbulb } from '@lucide/svelte';
</script>

This plug-in is used in *CollageJS* root projects.  It has 2 objectives:

- To inject an overridable import map
- To inject the import map overriding tool, [@collagejs/imo](/api/packages/imo)

As explained elsewhere, let's remember that Vite projects cannot define import maps on their own because of Vite's own client script when running in serve mode (there are no issues when building the project).  In serve mode, import maps don't work because Vite's client script runs before the import map has the chance to be defined.

Because of this limitation, the *Vite-IM* plug-in takes it as its primary objective to make sure that any import map is defined *before* anything else.  In order to accomplish this, its HTML transformation hook runs as late as possible.  Once it runs, Vite's client script has already been injected and the import map has the opportunity to work while in development (serve) mode.

> **<Lightbulb /> Plug-In Position**
>
> If you're having trouble making the import map work, it might be due to scripts running before it injected by other plug-ins you might be using.  Try to list *Vite-IM* as the last plug-in.

The second objective also involves touching the project's HTML.  Besides adding an overridable import map, it adds the script to override import map entries and the user interface that allows developers to define said overrides.

Let's list the script tags this plug-in adds to the project's HTML page:

| Item | Parent HTML Element | Script type |
| - | - | - |
| Import map script | `<head>` | `overridable-importmap` |
| Import map overriding script | `<head>` | `text/javascript` |
| Import map overriding options | `<head>` | `text/json` |
| Import map overriding micro-frontend | `<body>` | `module` |
| Import map overriding micro-frontend options | `<head>` | `text/json` |

The second script runs immediately, producing a new script of type `"importmap"` with the specified overrides applied.  The fourth script bootstraps the user interface in the `@collagejs/imo` NPM package, which happens to be a *CollageJS* core piece.

The JSON scripts are options.  The first one is for the overriding script, while the second one controls the appearance and behavior of the user interface.

For more information about the options this plug-in accepts, refer to its [API reference](/api/packages/vite-im).
