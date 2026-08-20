---
  title: Vite Overview
---

<script lang="ts">
    import type { PageProps } from './$types';
</script>

*CollageJS* is a modern micro-frontends library that focuses its toolset around [Vite](https://vitejs.dev).  *Vite* is a great bundler that has recently become greater with the introduction of [Rolldown](https://rolldown.rs), the successor of the popular `rollup` builder created by Svelte creator Rich Harris.  *Rolldown* is a Rust-powered bundler for TypeScript and JavaScript web projects.

*CollageJS* provides 3 Vite plug-ins that are very easy to use to enhance developer experience when working with micro-frontends.  They are geared towards fulfilling 3 distinct objectives:

- Make it easy to work with import maps in Vite projects
- Make it easy to inject CSS bundles when appropriate when core pieces are mounted
- Make development experience as transparent as possible

## Vite and Import Maps

A plug-in to define import maps in a Vite project is *not* necessary.  We can define an import map inside the HEAD element of our HTML entry page in our Vite project.  However, things are not "the same" between modes (development versus production builds).

The problem relies in Vite's development mode.  In this mode, Vite injects its client script as the first child of the HEAD element.  This renders import maps useless because import maps must be defined before any JavaScript module is loaded, and Vite's client script imports at least one module, rendering the import map unusable.

Our [Vite-IM](/docs/vite-im-plugin) plug-in solves this and goes further:  Following the great `single-spa` micro-frontends library, we want the ability to override import map entries.  With this in mind and taking from the now-archived `vite-plugin-single-spa` plug-in, *Vite-IM* also injects an overriding script and a user interface to define overrides.  This allows developers to work on single *CollageJS* piece projects using a built environment, just like we learned from `single-spa`.

## Vite and CSS

Vite is a great tool for web development, no doubt about this anywhere.  This is why so many developers use it daily.  *CollageJS* wants to build on top of this great tool.  The issue with CSS, however, is not a small one:  In micro-frontends, how can we make it easy for developers to synchronize the inclusion and exclusion of CSS bundles with the mounting and unmounting of core pieces?  The answer is taken again from the now-archived `vite-plugin-single-spa` plug-in and packaged for *CollageJS* as the [Vite-CSS](/docs/vite-css-plugin) plug-in.  This plug-in takes the learnings from the archived plug-in and expands on it, providing a very simple way to achieve this goal.

This plug-in can do the job for anything Vite can bundle.  As stated in the homepage:  If Vite can bundle it, *CollageJS* can mount it.  Single CSS bundles or split CSS bundles, shadow root mounts or light DOM mounts.

## Closing Gaps

The *CollageJS* way of building applications involves the use of import maps for consumption of other projects' code.  While browsers do understand import maps, Vite is not in line with the idea.  During development, even if a particular module specifier is known by the browser, Vite will try to resolve it.

To close this gap between the browser and Vite, the [Vite-AIM](/docs/vite-aim-plugin) serves as mediator between the project's import map and Vite (Rolldown, really), automatically externalizing anything known by the import map.

The *Vite-AIM* plug-in, with help from [@collagejs/imo](/api/packages/imo), can do its job for any project involved, not just the root project.

---

When we put all 3 plug-ins together, we get a smooth developer experience, where import map definitions auto-externalize libraries in all projects, where all CSS is properly mounted and dismounted, all while allowing import map entries to be overridden using `@collagejs/imo`.