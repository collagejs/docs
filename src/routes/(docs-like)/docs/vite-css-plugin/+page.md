---
  title: Vite-CSS Plug-In
  description: |
    Learn the objectives @collagejs/vite-css fulfills and how for micro-frontend piece projects.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import { Info, Lightbulb } from '@lucide/svelte';
</script>

This plug-in is used in piece projects and has 2 objectives:

- To configure entry points and make sure they export code (like libraries)
- To provide a CSS-mounting algorithm capable of mounting the bundled CSS files Vite produces

The first one is rather simple.  It configures Vite (Rolldown, really) with the desired input files and makes sure exports are maintained.

The second objective is far more involved.  It involves the use of a virtual module that exports a class.  This class will know, by the end of bundling, which CSS bundles relate to which input file.  This information is used by *CollageJS* `mount` and `relocate` lifecycle functions to keep the mounting of CSS files in synchrony with pieces produced by the factory functions in the input file or files.

## How CSS Mounting Works

The first step is to make sure we can uniquely identify CSS bundles, even across projects.  Let's remember that a *CollageJS* project is one created out of more than one Vite project.  This is the work for the `projectId` plug-in option.  This identifier is meant to be unique across all *CollageJS* projects and it is used in the CSS bundle file names.  This way, we make sure not to interfere with the CSS contributed by other projects.

The next step is building a map of CSS bundles per input file.  This is done by the plug-in and serialized directly inside the virtual module's code.  Once this is done, the rest of the algorithm follows.

We won't explain the rest of the algorithm here, but we can explain a few key points.

First, we always observe the HEAD element for incoming CSS links to cover for automatically mounted CSS, which happens when Vite splits code due to dynamic importation of modules.  This observation is treated differently depending on whether we have the *CollageJS* core piece mounted in light or shadow DOM.

When mounting in light DOM, we make sure we *share* the CSS link elements across all input files that may use it (determined during bundling).  Internally, the virtual module's code keeps usage counters that go up and down as core pieces are mounted and unmounted.  When the count for a CSS file reaches zero, the CSS link is disabled.  When a count is restarted, the CSS link is re-enabled.  If the CSS link didn't exist, it is injected.

When mounting in shadow DOM, things are much simpler:  We just add CSS links to the shadow root.  We don't track with usage counters, as we're assuming no other piece will reside in the root.

### Vite's Serve Mode

While in serve mode, Vite and HMR ensures CSS is injected as style tags in the HEAD element.  We don't have to do anything to have the CSS injected.  However, this only styles things in light DOM.

To date, mounting pieces in shadow DOM using Vite's development server is not supported.  We haven't settled on a solution to this particular situation.  If you're mounting *CollageJS* core pieces in shadow DOM while developing, the core piece must be a compiled (bundled) piece served via Vite's preview server.

---

For more information about the options this plug-in accepts, refer to its [API reference](/api/packages/vite-css).
