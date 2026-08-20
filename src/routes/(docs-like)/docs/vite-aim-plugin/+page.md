---
  title: Vite-AIM Plug-In
  description: |
    Learn the objectives @collagejs/vite-aim fulfills and how for micro-frontend root and piece projects.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import { Info, Lightbulb } from '@lucide/svelte';
</script>

This plug-in is used implicitly in *CollageJS* root and piece projects.  It has one objective:

- To automatically externalize the application's import map in all projects

This plug-in is automatically installed with the [Vite-IM](/docs/vite-im-plugin) or the [Vite-CSS](/docs/vite-css-plugin) are installed.  In root projects, *Vite-IM* handles its inclusion smartly:  It is only used if there are import maps defined and if [@collagejs/imo](/api/packages/imo) is injected.  In piece projects, the plug-in is *on* by default.

This plug-in configures Vite's development server with an endpoint that accepts the web application's import map.  The `@collagejs/imo` NPM package transmits the import map to all discovered Vite development servers mentioned in the import map, plus the page's origin (assuming it is regarded as a Vite development server).  This plug-in then uses the received import map to externalize anything the import map can actually resolve.

It can also automatically externalize during the build process, but because building doesn't depend on Vite's development server to be running, inherent limitations exist in piece projects because the import map is defined in the root project only.

Generally speaking, this plug-in automatically externalizes when the import map is given to it via its `importMap` options (see its API reference for information).  In *CollageJS* root projects, we don't have to configure it because the *Vite-IM* plug-in automatically shares the defined import map(s) with this plug-in.  The story is different in piece projects because piece projects don't know the import map the root project has defined.  It relies entirely on the developer to provide it via options.

## When Not To Use

This plug-in's only job is to automatically externalize what the import map can resolve.  If a piece project doesn't depend on the root project's import map entries, then it can be disabled by setting `aim: false` in the options for the *Vite-CSS* plug-in.

> **<Info />  Vite-IM Can Also Disable Vite-AIM**
>
> This is generally never needed, as *Vite-IM* is the authoritative source of import maps and is smart enough to automatically turn *Vite-AIM* on and off.  However and for completeness, it also defines the `aim` property.

A piece project doesn't need the application's import map if:

- It doesn't consume other pieces
- It doesn't have externalized any dependencies (i. e. framework runtimes)

---

For more information about the options this plug-in accepts, refer to its [API reference](/api/packages/vite-aim).
