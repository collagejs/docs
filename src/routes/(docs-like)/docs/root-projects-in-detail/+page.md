---
  title: Root Projects in Detail
  description: |
    Detailed explanation of what is considered a CollageJS root project, which benefits it carries and how to configure its features.
---

<script lang="ts">
    import type { PageProps } from './$types';
</script>

Let's clarify things once more:  Any web project can serve as root project for a *CollageJS*-powered application.  It doesn't even need to be Vite-powered, as one can use the framework adapters under any and every bundler, and in the remote case where this wasn't possible, one should be able to use `@collagejs/core` directly to mount and handle `CorePiece` objects.

However, *CollageJS* has made available Vite plug-ins that make life easier.  Therefore, we can define a *CollageJS* root project as a Vite-powered project configured with the [Vite-IM plugin](/docs/vite-im-plugin) where import maps are used to fulfill externalization of both *CollageJS* piece modules and other related dependencies.

With this formal definition, let's explain the available features and how to use them the best possible way.  Let's just make sure we all know how to install and configure the plug-in.

To install:

```bash
npm install @collagejs/vite-im
```

To configure:

```typescript
// An example from a Vite + Svelte project
import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import { cjsImPlugin } from '@collagejs/vite-im';

export default defineConfig({
    plugins: [svelte(), cjsImPlugin()],
});
```

## Import Maps

*Import maps* are not an invention of *CollageJS*.  They have been around for quite some time and you [should learn](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/script/type/importmap) as much about them as possible.

In short, an import map is a substitution table, where a *bare module specifier* comes in, and the import map spits out its assigned value, which usually is in the form of a URL that browsers understand and can fetch from.

*CollageJS*' `@collagejs/vite-im` Vite plug-in makes working with import maps a breeze.  This plug-in:

- Can merge multiple import maps into one
- Injects the merged import map into the web application's HEAD HTML element
- Injects `@collagejs/imo` that serves as a developer tool for overriding import map entries
- Sets up and configure *CollageJS*' auto-extrnalization plug-in `@collagejs/vite-aim`

There are several ways to specify import maps, but we'll only cover 2 here.  For detailed information, refer to the **Import Maps** section of the documentation.

### How to Use Import Maps

Without making a single change to any of the plug-in configuration options, we can create the `src/importMap.json` file and the plug-in will inject it as an overridable import map.  Furthermore, it will inject `@collagejs/imo` for import map entry overriding and will activate the `@collagejs/vite-aim` plug-in.

That's right:  All that just by adding the import map file.  Try it out, even if you still don't have the need of an import map in your application:

```json
{
  "imports": {
    "@tutorial/first-piece": "http://localhost:6101/piece.js"
  }
}
```

Start your project's development server.  Examine the HEAD element in Developer Tools.  You should see several entries there:

- A `<script>` tag of type `overridable-importmap`
- A `<script>` tag of type `importmap`
- A `<script>` tag of type `text/javascript` pointing to the latest version of `@collagejs/imo` in the JsDelivr CDN network

Furthermore, you should have near the end of the `<body>` tag a `<script>` tag of type `module` that also points to some other file in the `@collagejs/imo` package, also using the JsDelivr CDN network.

All these are the consequences of adding an import map to your application.

This `src/importMap.json` file will be used when running Vite's development server and when bundling the project.  This, however, is rarely suitable for our needs.  Why?  Well, look at the URL we specified in the import map.  It points to `localhost`.  That's just not deployable.  This means we need some other URL when we bundle.  This URL is only good for local development.

This is where the second way to specify import maps come up:  Rename `src/importMap.json` to `src/importMap.dev.json`.  Now this import map will only be used when running Vite's development server.  We then re-create the `src/importMap.json` file with different content:

```json
{
  "imports": {
    "@tutorial/first-piece": "/piece-prefix/piece.js"
  }
}
```

Hmm, now things have gotten interesting.  Why like this?  Why not a full URL?  What is this `"piece-prefix"` thing?

Truth be told, this documentation cannot really teach you what to put in the import map that is deployed.  Only you, the developer of the application can ever know for sure what needs to go there.

So what are we showing?  Our personal favorite:  How we would configure a *CollageJS* application that is deployed to *Kubernetes*.  In Kubernetes, we would configure the application's ingress (an Nginx server managed by K8s) so that any HTTP request that starts with our chosen prefix would be routed to the service that fulfills the delivery of the *ColageJS* piece we want.

This would mean that we will create or have already created a piece project, completed it, built it and uploaded to the K8s cluster.

So what we have shown in the example is just **one possible way of setting up the import map**.  In reality, we cannot tell you how it is configured.  It depends entirely on your deployment strategy.  Just as an example, let's assume you deploy your *CollageJS* piece in a sub-domain:

```json
{
  "imports": {
    "@tutorial/first-piece": "https://sub-domain.example.com/piece.js"
  }
}
```

Great.  That works.  No problem.  But depends on how you will deploy your application.  There is no single recipe.

To close on the import maps topic for now, we can tell you that we can override specific entries with the injected tool `@collagejs/imo`, but covering this topic is too much to be here, so you can find it [here](/docs/overriding-import-map-entries).

## Automatic Externalization

One would need to know a little bit about how Vite works in serve mode (`npm run dev`) to fully grasp this topic, but we'll do our best to explain enough to be understandable.

The concept of *externalization of modules* is not difficult:  It means that we can tell our bundler (Vite) to not bundle specific ES modules, and we do so by specifying Vite's configuration option `build.rolldownOptions.external`.  *CollageJS* doesn't meddle with this at all.  Feel free to use it if needed.

What *CollageJS* provides is the `@collagejs/vite-aim` plug-in.  *AIM* stands for *Auto-externalize Import Map".  How does it do it?  That's where Vite knowledge comes in handy, but I think we can settle the matter by stating that this plug-in simply tells Vite to externalize a module if the import map it knows can resolve it.  Since this is not a Vite plug-ins lesson, please pardon our lack of willingness to explain further, but if you're interested, read about Rolldown's `resolveId` hook.

### Practical Implications of AIM

What does the theory above translates to, for the developer?  Freedom.  Auto-externalization of import map entries:

- Allows developers to statically import from any externalized module as if it were installed as an NPM package
- Saves developers from repeating the import map bare identifiers in Vite's `build.rolldownOptions.external` option
- Saves developers from searching, installing and configuring yet another Vite plug-in just to externalize while running the Vite development server

In short:  `@collagejs/vite-im` and `@collagejs/vite-aim` covers almost every developer need, making up for an excellent DX.
