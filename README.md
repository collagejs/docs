# <img src="https://raw.githubusercontent.com/collagejs/core/HEAD/src/logos/collagejs-48.svg" alt="CollageJS Logo" width="48" height="48" align="left">&nbsp;CollageJS Docs

SvelteKit docs site configured for Cloudflare Workers (server-side), using `@sveltejs/adapter-cloudflare`.

## Local development

```sh
npm install
npm run dev
```

### check-links.ps1

This Powershell script checks the validity of links in documents and Svelte components.  The source of truth for valid URL's is Sveltekit's own routing system (the folders under `src/routes`) and all `primary-sidebar.json` files under `src/**`.

The build process runs it, and can be run on demand:

```sh
npm run check:links
```

### generate-sitemap.ts

Generates `/sitemap.xml` for the website.

> [!NOTE]
> **Improvement Pending**
>
> Sitemap handling must be improved.  Last modification date needs to be more precise and should be checked-in to preserve last modification dates of documents not touched in posterior iterations.
