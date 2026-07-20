---
  title: CollageJS Packages & Repositories
  description: |
    List of all available GitHub repositories and NPM packages at https://npmjs.com.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import GithubRepoLink from '$lib/GithubRepoLink.svelte';
    import NpmJsPackageLink from '$lib/NpmJsPackageLink.svelte';
</script>

For general knowledge and future reference, we present here all of the available NPM packages at [npmjs.com](https://npmjs.com/org/collagejs) as well as any other public repository that may be useful to you.

## Packages

| Package | Links | Description |
| - | - | - |
| `@collagejs/core` | <GithubRepoLink name="collagejs" />&nbsp;<NpmJsPackageLink name="@collagejs/core" /> | Core functionality.  Provides the general mounting and unmounting logic. |
| `@collagejs/vite-css` | <GithubRepoLink name="vite" />&nbsp;<NpmJsPackageLink name="@collagejs/vite-css" /> | Vite plug-in that offers a CSS-mounting algorithm that is fully compatible with Vite's CSS bundling, including split CSS.  It also features FOUC prevention, shadow root mounting and relocation. |
| `@collagejs/vite-im` | <GithubRepoLink name="vite" />&nbsp;<NpmJsPackageLink name="@collagejs/vite-im" /> | Vite plug-in that injects an import map and optionally the `@collagejs/imo` package to define bare module identifiers for easy micro-frontend loading and debugging. |
| `@collagejs/vite-aim` | <GithubRepoLink name="vite" />&nbsp;<NpmJsPackageLink name="@collagejs/vite-aim" /> | Vite-plugin that auto-externalizes the module identifiers found in the application's import map.  It receives the import map live (and with overrides) from the client.  This enables static imports (no more dynamic `import()` calls). |
| `@collagejs/imo` | <GithubRepoLink name="imo" />&nbsp;<NpmJsPackageLink name="@collagejs/imo" /> | Our version of `import-map-overrides` that does the usual overriding of import map entries, plus it transmits the final import map to Vite development servers found in it. |
| `@collagejs/adapter` | <GithubRepoLink name="adapter" />&nbsp;<NpmJsPackageLink name="@collagejs/adapter" /> | NPM package that encapsulates code that is often used to create *CollageJS* framework adapters. |
| `@collagejs/svelte` | <GithubRepoLink name="svelte" />&nbsp;<NpmJsPackageLink name="@collagejs/svelte" /> | Svelte component library that can be used to create `CorePiece`-compliant objects and to mount `CorePiece` objects (of any technology) by providing the `<Piece>` component. |
| `@collagejs/react` | <GithubRepoLink name="react" />&nbsp;<NpmJsPackageLink name="@collagejs/react" /> | React component library that can be used to create `CorePiece`-compliant objects and to mount `CorePiece` objects (of any technology) by providing the `<Piece>` component. |
| `@collagejs/solidjs` | <GithubRepoLink name="solidjs" />&nbsp;<NpmJsPackageLink name="@collagejs/solidjs" /> | SolidJS component library that can be used to create `CorePiece`-compliant objects and to mount `CorePiece` objects (of any technology) by providing the `<Piece>` component. |
| `@collagejs/vue` | <GithubRepoLink name="vue" />&nbsp;<NpmJsPackageLink name="@collagejs/vue" /> | **Next in line**  VueJS component library that can be used to create `CorePiece`-compliant objects and to mount `CorePiece` objects (of any technology) by providing the `<Piece>` component. |
| `@collagejs/angular` | | **External help needed.**  We don't have expertise in Angular, nor do we want to acquire it.  If you're an Angular developer, please consider contributing. |

## Other Repositories

| Repository | Description |
| - | - |
| [Root Template](https://github.com/collagejs/root-template) | Root template repository that can be used to create new repositories for *CollageJS* root projects, with client-side routing already configured. |
| [Gallery](https://github.com/collagejs/gallery) | Repository of *CollageJS* pieces made in various front-end technologies for your reference and inspiration. |
