---
  title: Project Types
  description: |
    Learn about the two project types encountered when using CollageJS to produce micro-frontend-powered applications.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import { Flag, Info, Lightbulb, TriangleAlert } from '@lucide/svelte';
</script>

There are 2 project types:

- Root projects
- Piece projects

A *root project* is the central or main web project.  It is in charge of setting things up for piece (micro-frontend) consumption.  Usually --but not necessarily--, this is a project that sets up the application's layout and routing mechanisms.

Root projects can be created using any framework or library.  *CollageJS* doesn't impose any restrictions.  The only thing that *CollageJS* does and does it through its [Vite-IM plug-in](/docs/vite-im-plugin) is inject an import map and the tool to perform import map entry overriding.  If you're unfamiliar with import maps and how they help micro-frontend applications, read the [import maps overview](/docs/import-maps-overview) and subsequent topics.

The other type of project is the *piece project*.  Piece projects are web projects that export one or more **factory functions** that create `CorePiece` objects.  We say factory functions because, even though it is legal to export a pre-built `CorePiece` object, it is not desirable because it makes reuse more difficult.  We prefer factories so we can create pieces when needed.  Furthermore, exporting factory functions allow said factories to optionally accept configuration options, which is a great tool for more complex scenarios.

## Creating Root Projects

There are countless ways to create one of these.  Once more:  *CollageJS* doesn't restrict what can or cannot be used.  Having said this, *CollageJS* has 2 recommended paths for creating root projects:

- Using *CollageJS*' root template
- Creating a Vite project with `npm create vite`

To know more about the root template alternative, read the [root template](/docs/the-root-template) topic.  From this point forward, we'll see about using `npm create vite`.

The first step is to create a new Vite project with Vite's creation package, `vite-create`.  Use the template you like the best:

```bash
npm create vite@latest -- --template svelte-ts
```
> <Info /> This is not a Vite tutorial, so we'll assume the reader will be able to get to the point where the project is created, configured and running.

As your root project currently stands, you *can* start mounting pieces using the `mountPiece` function from `@collagejs/core`, assuming you proceed to install this package.  If you take this route, you'll be able to manage the mounted pieces as shown in the [introduction](docs/introduction).

However and also mentioned in the introduction, there are better ways to do things.  If your chosen template when creating your root project corresponds to a technology covered by an adapter (be it official or not), you can instead proceed to install said adapter.

In the example code, we chose TypeScript Svelte, and Svelte does have an official adapter named `@collagejs/svelte`.  Install it:

```bash
npm install @collagejs/svelte
```

Now we're ready to mount pieces using the Svelte adapter, and we don't have to deal directly with the `mountPiece` function.  Instead, we'll be using the `<Piece>` component provided by the adapter.

To actually show an example on how to do this, let's pause on the root project topic and let's create a piece project.  We will also cover the installation of the [Vite-IM plug-in](/docs/vite-im-plugin) after we have a working piece project.

## Creating Piece Projects

Deja vu:  The same things we said about root projects are applicable to piece projects:

- There are no restrictions on how it is created
- There are no restrictions to the technologies used to create it
- *CollageJS* recommends a Vite project

There is no template alternative for piece projects, so let's proceed with a new Vite project:

```
npm create vite@latest -- --template react-ts
```

This time we created a TypeScript + React project.  This means that the piece or pieces we'll export (via factory functions) will be powered by the React library.

Just like root projects:  We can go straight to creating factory functions if we don't mind doing the work of creating all lifecycle functions ourselves, but the introduction topic taught us this is already done in the React adapter:

```bash
npm install @collagejs/react
```

Now we can use the `buildPiece` function, which greatly simplifies the process.

### Recommended File Arrangement

Many people like developing micro-frontends as standalone projects, at least at first.  This means that they like the fact that they can run the project in serve mode (`npm run dev`) while the piece (micro-frontend) is created.

For this reason we recommend not to delete the core files that set up the Vite project.  These usually are:

- `index.html`
- `main.ts`
- `App.[ts|tsx|svelte|vue|solid]`

Instead, just clean them up to the point where you are comfortable.  Most of the time we just blank out the `App` component, the CSS files and then change the page's title.  If we proceed like this, we still have a functional Vite-powered web application, albeit a (possibly) empty one.

In order to start coding our piece, we add a new component file.  Since we created a React piece project above, let's add the `src/Root.tsx` file to create a new React component, which will be the component we will wrap into a `CorePiece` object:

```typescript
// src/Root.tsx

import './root.css'; // We can import some CSS to make the component pretty, if we like.

export type RootProps = {
  name?: string;
}

export function Root(props: RootProps) {
  return <>
    <div className="salutation">
      Welcome aboard, {props.name || 'stranger'}!
    </div>
  </>
}
```

We can preview this `Root` component by adding it to `App.tsx`, so we can preview it with Vite's serve mode.  Feel free to do so and make it look pretty.  Perhaps a nice background, or maybe a handshake icon somewhere, etc.

Once we're happy with the result, we recommend exporting a factory function that creates `CorePiece` objects that wrap the `Root` component.  Because we're going to add the [Vite-CSS plug-in](/docs/vite-css-plugin) to the project, we'll follow this plug-in's default options and create the `src/piece.ts` file.

We now want to install our Vite CSS plug-in and the React adapter package, if we didn't do this before:

```bash
npm install @collagejs/vite-css @collagejs/react
```

Now we can add the plug-in to the list of plug-ins in `vite.config.ts`:

```typescript
import { defineConfig } from 'vitest/config'; // or from 'vite'
import { cjsCssPlugin } from '@collagejs/vite-css';

export default defineConfig({
  plugins: [
    react(),
    cjsCssPlugin({
      serverPort: 6101,
      aim: false,
    })
  ],
});
```
> **<Flag /> AIM Plug-In Turned Off**
>
> If you would like to know what the `aim` plug-in option is for, head to the documentation for the [Vite-CSS plug-in](/docs/vite-css-plugin).

Then we add code to our piece entry file:

```typescript
// src/piece.ts
import Root from './Root.tsx';
import { buildPiece } from '@collagejs/react';
import { CssFactory } from '@collagejs/vite-css/ex';

const css = new CssFactory(import.meta.url);

export function myPieceFactory() {
  const lc = buildPiece(Root);
  const { mount } = css.instantiate();

  return {
    ...lc,
    mount: [mount, lc.mount],
  }
}
```
> **<Info /> We Simplified**
>
> The example above only composes the `mount` lifecycle function, but `css.instantiate()` also provides a `relocate` function that should be composed with the core piece's own `relocate` function.

Believe it or not, **we're done**.

The above code creates the core piece object, and then uses the [composition](/docs/corepiece-composition) technique to add the CSS-mounting layer provided by the `@collagejs/vite-css` plug-in, which understands how Vite bundles CSS, including Vite's split CSS chunks.  Our CSS plug-in can track every chunk of CSS your piece needs and will mount it an unmount it in synchrony with your core piece.

At this point, you may choose to run either Vite's development server of preview server.  If you opt for preview server (which is required to mount the piece in shadow DOM), remember to build your piece project first.

---

## Back to Root

Great, so now we can go back to our root project and make use of the `<Piece>` Svelte component (because our root is powered by Svelte) to mount our React piece.

Somewhere inside `App.svelte`, we're going to add the React piece.  To do this, we need 2 imports:

1. The piece factory function
2. The `<Piece>` Svelte component

If you are a seasoned micro-frontends developer, you'll probably realize at this point that we will import directly from the piece project's Vite server (either development or preview).  For Vite to allow us to do it, we have to use the dynamic `import()` statement... Or do we?

The answer is: We don't!  By leveraging the use of an import map and the automatic externalization that the [Vite-AIM plug-in](/docs/vite-aim-plugin) provides, we can use static import statements when importing piece factory functions.  Let's set it up.

Install the IM plug-in:

```bash
npm install @collagejs/vite-im
```

This installation also carries the `@collagejs/vite-aim` plug-in, and it will be available by default.

Let's add it to `vite.config.ts`:

```typescript
import { defineConfig } from 'vitest/config'; // or from 'vite'
import { cjsImPlugin } from '@collagejs/vite-im';

export default defineConfig({
  plugins: [
    svelte(),
    cjsImPlugin()
  ],
});
```

Now and following the plug-in's default options, we'll add the `src/importMap.json` file:

```
{
  "imports": {
    "@tutorial/react-piece": "http://localhost:6101/piece.js"
  }
}
```
> **<Lightbulb /> This is for Preview Server**
>
> Vite provides 2 HTTP servers:  Development and preview, and in the previous section we started one of these.  If we chose the preview server, the above works as-is; if we chose the development server, then change `http://localhost:6101/piece.js` to `http://localhost:6101/src/piece.ts`.

We have come up with the bare module identifier (a. k. a. bare module specifier) `@tutorial/react-piece` to refer to our React piece.  The web browser will read the import map and will divert itself to the URL we have written in the import map entry.

Because of the wonders of the *Vite-AIM* plug-in, we can directly import our `myPieceFactory` function from the React piece project using a static import statement and use it:

```typescript
// Inside App.svelte's script tag
import { Piece, piece } from '@collagejs/svelte';
import { myPieceFactory } from '@tutorial/react-piece';

const reactPiece = myPieceFactory();
```

Ok, so we are not entirely done.  At this point, TypeScript complains that this module is unknown.  That's ok.  We can teach TypeScript about the module with an [ambient module](https://www.typescriptlang.org/docs/handbook/modules/reference.html#ambient-modules):

Add the ambient module to a `.d.ts` file in your project.  Vite-powered projects usually have at least one of these ready to be used:

```typescript
declare module '@tutorial/react-piece' {
  import type { CorePiece } from '@collagejs/core';

  export type RootProps = {
    name?: string;
  }

  export function myPieceFactory(): CorePiece<RootProps>;
}
```

With the ambient module in place, our static import statement should be error-free.

Continuing in `App.svelte`, we proceed to add the `<Piece>` component somewhere we like:

```svelte
<Piece {...piece(reactPiece, { shadow: true })} name="José" />
```
> **<TriangleAlert /> CAUTION**
>
> Change `shadow` to `false` if you started the piece project's development server.

Save your changes.  If you didn't have your development server for the root project running, run it now and open the web page.  The react piece should be greeting José!

---

You're probably wondering about several things, like the `piece` helper function.  It is perfectly normal.  Keep reading to master *CollageJS*.