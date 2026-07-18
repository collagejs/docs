---
  title: The Root Template
  description: |
    Learn the various features and the general setup of CollageJS's root template project, which comes equipped with
    routing capabilities and a demonstration of a CollageJS piece.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import { Flag, Lightbulb, Notebook, Palette } from '@lucide/svelte';
</script>

We already know that we can use `npm create vite@latest` to produce a Vite-powered project using our preferred framework or library, be it React, Svelte, Vue, or anything else Vite can bundle.

This is great for sure.  The amount of freedom is something many people can agree upon.  But there's one thing that people seem to (almost) always want when doing micro-frontends:  Routing.

Especially if you come from the `single-spa` environment, you're used to getting a client-side router provided to you, and *CollageJS* does **not** provide a client-side router.  *CollageJS* is a bring-your-own-router kind of library, and we hope that this is great news to everyone.  Now people can use their preferred routing package for their projects.

Still, there will be people out there interested in a recommendation, and *CollageJS* happens to have a recommendation:  [webJose's Svelte Router](https://svelte-router.dev) is a router unlike any other and it brings a lot of power to micro-frontend scenarios because:

- It matches multiple routes simultaneously (like the `single-spa` router)
- It does path routing and hash routing simultaneously
- It can dissect the hashtag into multiple paths, allowing an application to have multiple, independent routes simultaneously

To the best of our knowledge, no other router in the world can do the above, and it so happens to be a very useful thing in micro-frontends.

Our [root template](https://github.com/collagejs/root-template) template is a *Vite + TS + Svelte* project with *webJose's Svelte Router* installed and configured.

> **<Flag /> Svelte Knowledge Required**
>
> To take full advantage of this root template project, one should know at least some Svelte v5.  The basics regarding reactivity are of particular importance, as all data provided by the router library is a Svelte reactive signal.

## Starting with the Root Template

There are two, very easy ways to start.  You can either degit the repository:

```bash
npx degit https://github.com/collagejs/root-template
```

Or you can [clone it into a new repository (by clicking this link)](https://github.com/new?template_name=root-template&template_owner=collagejs).

Once you have cloned it, install dependencies and run Vite's development server

```bash
npm install
npm run dev
```

## Project Description

When you first run it, the homepage appears, boasting *CollageJS* logo at the center.  On top, there is a navigation bar.  The brand section in the upper left corner contains a small palette (<Palette size="1.2em" />) icon that serves as a color picker.  It will rotate through the four palettes of the *CollageJS* brand.

You'll find the navigation links in the upper right corner.  There are 5 links there:

- **Home** -- takes you to the home page
- **Intro** -- takes you to the introduction page
- **PIN Pad** -- takes you to the *CollageJS* piece demonstration page and requires additional setup (explained in the page)
- **Feature** -- is not really a defined route in the router, so what shows up is fallback content
- **About** -- takes you to the About page

Every valid route will show, on top and just below the navigation bar the source file's name.  If you're interested about a particular something you saw in a page, open that file in your IDE and grab the knowledge you seek.

## The PIN Pad Demonstration

This is where we can see *CollageJS* in action, but requires extra steps.

The `pieces/svelte-pinpad` folder contains another *Vite + TS + Svelte* project, but configured to be a piece project, not a root project.  In order to be able to load the PIN Pad piece, build the project and start Vite's preview server.

> **<Notebook /> Notes**
>
> - The PIN Pad project is a Svelte project just to keep the root template repository in one framework, but *CollageJS* can load pieces of any framework or library.
> - We build and preview because shadow DOM mounting cannot be done using a Vite development server.

Once the preview server for the PIN Pad project is up and running, we can reload the PIN Pad page of the root template to see it in action.

## Host-Piece Interaction

Once the PIN pad becomes visible, the host application (the root template application) can interact with it much like it was a regular component (Svelte component, in this case, because the root template is made with Svelte).

There are 2 sets of controls present in the page.  The ones labeled *Piece Properties* are actual properties for the PIN pad component and the list of properties for a *CollageJS* piece vary from component to component.  The other set labeled *Container Settings* is a demonstration of the capabilities of the official Svelte adapter library.  The library lets you mount the piece it is given to it in light DOM, open or closed shadow roots, and can even jump between options in runtime.

The other "nicety" is that it forwards attributes to the container element.  The controls allows the setting of the container's padding and background color.

> **<Lightbulb /> Tip**
>
> There's a third feature in the page about the adapter that cannot be controlled with the provided controls:  The ability to set event listeners.  If you look closely, there's a tip just above the PIN pad component that disappears as soon as the PIN pad gains keyboard focus.  This is achieved with container event listeners for the `focusin` and `focusout` bubbling events.

## Enabling the IMO User Interface

Root templates that use the [Vite-IM plugin](/docs/vite-im-plugin) have, by default, a hidden *CollageJS* piece injected in the page from the NPM package `@collagejs/imo`.  This user interface is used to override import map entries, mostly for development purposes.

To enable it, open *Developer Tools* in your browser for the root template's window/tab, then add the `imo-ui` key to local storage with the value `true`, and then reload the page.  You'll see a semi-transparent overlay in the bottom-right corner of the application that becomes opaque when gaining keyboard focus or when the mouse hovers over it.

If you would like to know more about how to use `@collagejs/imo` read about [root projects in detail](/docs/root-projects-in-detail).