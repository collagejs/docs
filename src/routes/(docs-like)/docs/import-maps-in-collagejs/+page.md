---
  title: Import Maps in CollageJS
  description: |
    TODO
---
<script lang="ts">
    import type { PageProps } from './$types';
    import { Info } from '@lucide/svelte';
</script>

One of the greatest things that *CollageJS* borrowed from *single-spa* is the use of import maps and the ability to override individual entries in said import maps.

> **<Info />  Know the Basics**
>
> The documents here don't teach about import maps, the browser feature.  It only explains how they are used in *CollageJS* projects.  It is assumed the reader is at least familiar with the concept and basics.  If needed, please [read about them here](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/script/type/importmap) or search for other sources of information.

## Main Goal

The main goal of import maps is to allow us to put a stable name to a module whose "home" is not yet determined, or that may have multiple "homes" ("home" being the location the code will be uploaded to).

The main use case is locating the modules that export the factory functions for the *CollageJS* pieces we are interested in consuming from our root project or from other piece projects.  Sometimes they reside in the developer's local PC, accessible via Vite's development or preview server; sometimes it is available in a CDN network (like `@collagejs/imo`'s user interface, which is a *CollageJS* piece); sometimes it is deployed in servers for QA testing, pre-production or production environments.

We use import maps to be able to write stable code for unstable housing situations.

## Defining Import Maps

This is not a difficult task because *CollageJS* takes care of almost everything for the developer via the *Vite IM* and *Vite-AIM* plug-ins.  Still, there's a bit of to-do's for the developer:

1. Define a naming strategy
2. Define the number (and names) of import map files to be added to the root project
3. Define the application's deployment strategy to be able to write a build-time import map

### Naming Strategy

This is largely unimportant technically speaking, but brings order to the table.  The only technical issue is to make sure that the names that will be assigned are *bare module specifiers*.

*Bare module specifiers* are module specifiers that cannot be interpreted as URL's or URL paths.  They cannot begin with a period or a slash or a protocol.  Need some examples?  Just look at one of your `node_modules` folder.  All those names there are bare module specifiers: `lodash`, `svelte`, `react`, `react-dom`, `@collagejs/core`, etc.

The *single-spa* documentation used to define bare module identifiers as scoped identifiers (because that's what the `@` symbol means in the NPM world), and we don't see anything wrong with that.  As a matter of fact and if you've been reading this documentation in order, you have already encountered several of these, like `@tutorial/calculator`, where `@tutorial` is the scope.

So for your project, maybe assign a scope name that is short and doesn't use weird characters.  Don't be that "original" guy that uses emojis in filenames, please!

Once you've defined a scope, naming *CollageJS* piece modules is a matter of adding a keyword to the scope separated with a slash.

> **<Info /> Identifiers Are Per-Module**
>
> Most of the time, piece projects only define one entry file because most of the time they only offer one piece.  This could give developers the wrong impression that there's a 1:1 relationship between bare module specifiers and piece projects.  This is incorrect.  If a piece project has 2 entry files, then each resulting entry file needs its own bare module specifier.
>
> Ok, we'll admit there's a trick to only need one, and you can figure it out if you understand import maps.  We leave it as homework if this topic interests you.

### Defining the Needed Import Map Files

The *Vite-IM* plug-in will pick up import map content from the default file names or the configured file names.  We can define multiple files, in which case the plug-in will merge them all into a single import map object before injecting it into our project's HTML page.

#### Default File Names

The default values are very simple, and only small projects can do with them.

By default,  `src/importMap.json` is used as import map source while in serve and build mode if that's the only file that exists (of the files it knows).  If `src/importMap.dev.json` exists, then it is used during serve mode, and `src/importMap.json` is used during build mode.

This is it.  It is a very simple ruleset.  Most small projects like sample projects can do with this simplistic approach, but most of the time this is insufficient for real-world applications.

---

A very common thing developers do when working with micro-frontends is externalize shared libraries to minimize the amount of code their customers need to download to use the web application.  The most common libraries that are externalized are library/framework runtimes.  NPM packages like `react`, `react-dom`, `svelte` and `svelte/internal/` are commonly externalized so all React/Svelte core pieces use a common runtime downloaded only once.

During both development and deployment, the externalized modules need to be provided from somewhere, and what we do is that we add them to the import map:

```json
{
  "imports": {
    "react": "https://some.cdn.network/...",
    ...
  }
}
```

Then, when piece modules are imported from their HTTP servers, they use the same module from the locations specified in the import map, achieving the desired goal.

This is great, but does this mean that we have to *repeat* the list of shared libraries in `src/importMap.dev.json` and `src/importMap.json`?  No.  That would be bad DX.  The `Vite-IM` plug-in will merge multiple import files.  We already covered this.  The solution is to create `src/importMap.shared.json` and put there all the entries needed in both development and built environments.

Of course, this scenario is not covered by the default options for the plug-in, so we must explicitly configure this setup in `vite.config.ts`:

```ts
export default defineConfig({
  plugins: [
    ...,
    cjsImPlugin({
      importMaps: {
        dev: [ 'src/importMap.shared.json', 'src/importMap.dev.json' ],
        build: [ 'src/importMap.shared.json', 'src/importMap.json' ],
      },
    }),
  ],
  ...
});
```

This kind of setup is what the majority of *CollageJS* applications will be using:  Shared runtimes in one file, then development-time piece servers separated from production-time piece servers.

### Defining the Deployment Strategy

This is the last thing to do:  We must define how the application, as a whole, will be deployed because this determines the actual URL's we will need in the build version of the import map.

We have a [guide about deployment strategies](/guides/common-deployment-strategies-for-collagejs) that explains a little bit more and explores a couple scenarios.  We invite you to read this guide if you need assistance with the topic.
