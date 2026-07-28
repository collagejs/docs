---
  title: Piece Projects in Detail
  description: |
    Detailed explanation of what can and should be done in CollageJS core piece projects, their purpose and objective.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import { Info, Lightbulb, MessageCircleQuestionMark } from '@lucide/svelte';
</script>

A *CollageJS* application is comprised of one root project (explained in the previous topic) and at least one *core piece project*, which is the topic of this document.  Just like with root projects, any web project can be made into a core piece project because *CollageJS* is nothing but a small set of requirements that can be fulfilled and used by just using [@collagejs/core](/api/packages/core).  However, it is more convenient to use the additional goodies we provide.

A *CollageJS core piece project* is a Vite-powered project that uses the [Vite-CSS](/api/packages/vite-css) plug-in and that exports at least one core piece factory function from at least one entry file (module).

## Creating a Core Piece Project

As with root projects, we create a new Vite-powered project using `npm create vite@latest` (or any specialty alternative like `npm create vue@latest`).  Once the initial setup is complete and the project is able to run, we add the `@collagejs/vite-css` plug-in:

```bash
npm install -D @collagejs/vite-css
```

We can now add it to our `vite.config.ts` file:

```typescript
import { cjsCssPlugin } from '@collagejs/vite-css';

export default defineConfig({
  plugins: [..., cjsCssPlugin({ aim: false, serverPort: 6101 })],
  ...
});
```

Just like the `@collagejs/vite-im` plug-in for root projects, `@collagejs/vite-css` also installs and configures the [Vite-AIM](/api/packages/vite-aim) plug-in that auto-externalizes the bare module specifiers found in the import map the root application provides.

However, notice that we specified in the code above the `aim` option.  We have set it to `false`, and that turns off the AIM plug-in.  Why did we do this?  Good question.  To answer, let's quickly review how AIM works.

AIM works by **blocking incoming HTTP GET requests** if it hasn't received an import map from `@collagejs/imo`, the import map-overriding tool.  This reception is normally very fast, but what if we have just started setting up our *CollageJS* applications?  What if we haven't defined an import map in our root project, meaning that `@collagejs/imo` doesn't have anything to send?  What then?  We'll tell you what:  All HTTP GET requests to your development Vite server will be pointlessly blocked.  Pointlessly because the expected import map will never arrive, at least during this early stage of the development.

Yes, the blockade is not indefinite.  After a short period of time, the HTTP GET request is unblocked and your project's user interface eventually shows up in your browser.  But you had to wait.  You had to endure the timeouts.  You had to wait about 10-15 seconds just to see your project loaded for the first time.

To avoid this annoyance during early development, we specify `aim: false` in the plug-in's options.  We turn AIM off until the time it is actually useful, and we'll tell you a little something:  Some projects never end up needing it.

Your *CollageJS* core piece project only needs the AIM plug-in if it depends on a module specifier found in the import map.  If your project doesn't load other core pieces (core piece projects can consume other core piece projects) and doesn't share, for example, an externalized runtime like the React libraries, then you never need to use the AIM plug-in and you can keep it turned off.

> **<MessageCircleQuestionMark />  Doesn't this happen in root projects?**
>
> It doesn't!  The Vite-IM plug-in used in root projects is the authoritative source of import maps.  Therefore, it knows exactly when import maps are available and when they aren't and uses this information to manage automatically this `aim` setting for you.

Great, so we are almost ready to start.  We just need to install our framework adapter.  If *CollageJS* provides an adapter for the project's technology of choice, install it now:

```bash
npm install @collagejs/<framework name> # svelte, react, vue, etc.
```

## Creating Core Piece Components

This part has almost nothing to do with *CollageJS*.  This is the part where we create a Svelte|React|SolidJS|VueJS|Lit|Ripple-TS|Angular component.  It can be as large as an entire application, or it can be as small as a badge component.  Size doesn't matter.  We just create what we want as a reusable user interface unit.

What we can suggest is one way of doing this.

We suggest that you blank out the main application component and the main CSS file to go back to a blank (or empty) application.  Just get to the point where the core piece project renders an HTML with nothing in its BODY element..., well, nothing but a DIV element with the `#app` ID attribute value, which is what is most common in Vite applications created with `npm create vite@latest`.

Now we can start.  We usually **don't use the App component** to be the core piece component.  We suggest using this `App` component as your testing grounds for the core piece or pieces you will be exporting from the project. This is what we explained in the previous section, where we were forced to speak a little about piece projects within the context of root projects, so we could talk about mounting pieces.

We start adding new components:  One per core piece to be exported.  Select appropriate names for their files and just start developing them.  Once you have something mountable, add it to the `App` component.  Now we can see our progress live.  Continue developing until the component is fully done.

### Exporting the Core Piece Factory Function(s)

Great, so we have our component completed and ready to ship via *CollageJS*.  We are going to create a new TypeScript file that exports our desired factory function, because we don't export instantiated objects.  No, sir!  We export factory functions for the reasons we have explained previously in other topics.

> **<Info /> Many Ways to Skin the Cat**
> 
> We'll be covering the case where we export one factory function from one entry module for one core piece.  You are, however, free to export more core pieces, using more entry modules and exporting more than one function from a single module.  How exactly we do this comes with experience and the project requirements.
>
> As a quick example:  Creating more than one entry file increases the chance of Vite splitting code and CSS into smaller chunks.  Maybe this is good for the project, maybe it isn't.  We cannot give you a recipe to decide when to and when not to.  May the experience guide you in this journey.

In order to take advantage of the default options for the Vite-CSS plug-in, let's create the entry module `src/piece.ts` and export our factory function.

For the sake of the example, we'll assume the core piece's name is `Calculator.tsx` and that the project is a React project:

```typescript
import Calculator from './Calculator.jsx';
import { buildPiece } from `@collagejs/react`;
import { CssFactory } from `@collagejs/vite-css`;

const css = new CssFactory(import.meta.url);

export function calculatorFactory() {
  const piece = buildPiece(Calculator);
  const { mount, relocate } = css.instantiate();

  return {
    ...piece,
    mount: [mount, piece.mount],
    relocate: [piece.meta.relocatable && relocate, piece.relocate],
  };
}
```

And this should bring our piece to life and available for consumption.  The root project (or another core piece project) may start consuming it.  How?  Let's see.

## Configuring Core Pieces in the Import Map

Every time we have a new core piece added to our *CollageJS* project, we need to assign it a *bare module specifier* that we add to the root project's import map.  Let's give our calculator core piece the bare identifier `@tutorial/calculator`.

Open your import map file(s) and add this to the import map's `imports` section.  Usually, we use `src/importMap.dev.json` and `src/importMap.json`.  The development entry should look something like this:

```json
{
  "imports": {
    "@tutorial/calculator": "http://localhost:6101/src/piece.ts"
  }
}
```

As explained in the previous topic, we can't tell you exactly what to put in your non-development import map.  It is dependant on how the code will be deployed.

The above URL is the one we need if we're going to start our core piece project's **development sever**.  Change it to `"http://localhost:6101/piece.js"` if you wish to build and start the **preview server** instead.

> **<Lightbulb /> Tip**
>
> Don't worry too much about which URL to set (development or preview).  Remember that your root project injects `@collagejs/imo`, meaning you're just a few clicks away from overriding the import map at will without having to constantly touch your import map file.

This is great news.  Now we know that our *CollageJS* set of projects have an import map available.  If we desire, we can turn on any Vite-AIM plug-ins we turned off before, if needed.

## Consuming the Calculator Core Piece

The calculator core piece we did in React can now be consumed from the root project or any other core piece project.  The process is simple, and the most boring part of the entire process (because we don't have it automated) is making TypeScript happy about importing things from a module we never installed (`@tutorial/calculator`).

We have seen this procedure before, but let's review it again here.

1. Declare an ambient module for `@tutorial/calculator`:
    ```typescript
    // app.d.ts or any other .d.ts available to your tsconfig.json file
    declare module '@tutorial/calculator' {
      import type { CorePiece } from '@collagejs/core';

      export type CalculatorProps = {
        /* props here */
      };

      export function calculatorFactory(): CorePiece<CalculatorProps>;
    }
    ```
2. Somewhere that makes sense in the consuming project, import the factory function and the `Piece` component from the adapter you're using:
    ```typescript
    import { calculatorFactory } from '@tutorial/calculator';
    import { Piece, piece } from '@collagejs/<framework for this project>';

    const calculatorPiece = calculatorFactory();
    ```

    > **<Lightbulb /> Promises Work Too**
    >
    > Feel free to write asynchronous factory functions.  The fact doesn't change this code.  Core pieces can be the actual piece or a promise that returns the piece.
3. Mount the piece according to your consuming project's syntax.  Most of the time it will be similar to this:
    ```html
    <Piece {...piece(calculatorPiece)} />
    ```

Without knowing the specifics of the core piece, we cannot show anything more specific.  Let's just remember that we should be able to also pass along any properties to the core piece as if they were properties of the host, `Piece`.

Let's also remember that we can specify our preference in target:  We can mount in light DOM, or in an open or closed shadow root.  It all boils down to the what the framework adapter you're using supports.

---

Congratulations!  If you made it this far, it means that you've learned:

- The basics of *CollageJS*
- That even non-Vite web projects can create and consume core pieces
- That adapters are the preferred route to create and consume (mount) core pieces
- That to the best of our ability, all framework adapters expose the same API
- To define *CollageJS* core piece modules in import maps and ambient modules
- That core pieces are never exported instantiated and instead factory functions are exported

If you're still knowledge-hungry, continue reading to learn more advanced topics that enable better DX and more complex scenarios.