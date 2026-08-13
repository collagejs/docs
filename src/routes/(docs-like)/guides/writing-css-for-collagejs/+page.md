---
  title: Writing CSS for CollageJS
  description: |
    Learn the best practices and tips to write CSS for CollageJS root and piece projects in order to minimize CSS leakage from one project's CSS to another.
---
<script lang="ts">
    import type { PageProps } from './$types';
    import { Flag, Info, Lightbulb, TriangleAlert } from '@lucide/svelte';
</script>

When dealing with micro-frontends on the web, one of the main pain points is CSS.  This happens because:

- It is not code
- It is difficult to control

However, we have to acknowledge the fact that CSS does improve through the course of time, and we will definitely do our best to take advantage of newer CSS features as they appear over time.

*CollageJS* has already hunted down and skinned the mounting and unmounting monster, so our one problem that lingers on is *CSS leakage*.

## CSS Leakage

> <Flag /> This only happens when mounting in light DOM

Generally speaking and when mounting pieces in light DOM *only*, the CSS that the core piece projects produced for their core piece objects is intermixed with the CSS the root project uses for its own user interface.

Because of its very nature, CSS style rules that a particular piece project has defined might accidentally apply to DOM elements outside the DOM tree(s) of said piece.  This most commonly happens when the CSS rules use common selectors, such as:

- Tag-only selectors (i. e. `p` or `aside ul`)
- Common class names (i. e. `.dark` or `.button`)

With this kind of CSS selectors we have a high probability that DOM trees from other piece (or the root) projects end up being targeted.

The rest of this guide is all about mitigating as much as possible the risk of CSS leakage.

## Tip 1:  Mount in Shadow DOM

Just like that.  You are one Boolean value away from not having CSS leakage from your piece projects into other piece projects or the root project.

## Tip 2: Scoped CSS

> **<Info /> Ambiguity**
>
> The term "scoped CSS" is now ambiguous because recently, the CSS standard has coined a new at-rule named `"@scoped"`, which is the subject of another tip in this guide.  This tip is about CSS that is made scoped under non-CSS standard definitions.

There are several ways to create scoped CSS and we don't intend to list them all here, although feel free to contribute to this documentation if you know of a nice method we're not teaching here.

We're going to mention 2 methods:

- Per-framework scoping
- Vite's CSS Modules

### Per-Framework Scoping

The first one varies from framework to framework exactly because it is framework-dependant.  Some frameworks offer automatic CSS scoping.  Of the ones that *CollageJS* currently supports we can mention *Svelte* and *VueJS*.

In Svelte, the CSS written in a component's `<style>` tag is scoped by adding a "random" class name to everything the style defines.  There is no configuration step needed.  This just happens.

In VueJS, we can use the  `<style scoped>` tag to inform the compiler that we want scoped CSS.

In all honesty, this is **fantastic**.  This tip alone can really go the distance.  This should bring down the probability of CSS leakage like 99% (don't ask us for the math to reach this number!), but we'll throw in an extra measure.

Your framework is most likely creating this "random" class name used as the scoping trick from a hash value.  That hash value is mostly discarded, and the class name ends up just using the first 4 to 6 characters.  So here comes the tip:  Change the number of characters each *CollageJS* project uses so no individual project can ever and by accident, produce the same scoping class name.

### Vite's CSS Modules

Any CSS file that is imported using the file extension `.module.css` is a CSS module ([Vite documentation](https://vite.dev/guide/features#css-modules)).  When CSS modules are used, Vite adds a fragment of a hash value to the CSS class names.  This is a form of scoping that is framework-agnostic.  CSS modules should work in any Vite project.

> **<Lightbulb /> vite-css-modules**
>
> An NPM package named `vite-css-modules` exist and its objective is to correct several issues with Vite and CSS modules.  If you decide to go the CSS modules route, make sure to at least know what this NPM package does in case the bugs end up affecting your projects.

### Tip 3:  @Scoped CSS

This is not to be confused with the previous section, named almost identically.  This is a new feature in CSS named *Scoped Styles*, but people might refer to it as scoped CSS.

According to the [caniuse](https://caniuse.com/css-cascade-scope) website, the feature has recently become available in all the browsers the majority of people use.  As of this writing, the web page showed **88% support worldwide**.

This new feature instructs browsers to only consider the scoped CSS rules for DOM trees between the *scope root(s)* and the *scope limit(s)*.  The CSS rules will not be available in DOM trees that don't have a scope root as parent, or that have a scope limit as parent.

This basic rule is just beautiful for micro-frontends.  Let's see why.

Here's a simple example of markup created from a *CollageJS* root project:

```html
<main>
  <div [data-cjs-piece-host="dom"]>
    <!-- A navigation CollageJS piece -->
     <nav>...</nav>
  </div>
  <div class="container">
    ...
    <aside class="left-sidebar">
      <div [data-cjs-piece-host="dom"]>
        <!-- Sidebar nav CollageJS piece -->
        <nav>...</nav>
      </div>
    </aside>
  </div>
</main>
```

As seen, the *CollageJS* pieces appear here and there, sprinkled all over the root project's markup.  Any CSS rules from stylesheets we might use like [Bulma](https://bulma.io) or [Bootstrap](https://getbootstrap.com) will "leak" their global CSS selectors and class names to the entire document.

But what if said *global* stylesheets were inside this scope?

```css
@scope (:root) to ([data-cjs-piece-host]) {
  ...
}
```

Eureka! Now common class names like `"button"` or `"btn"` have zero probability of spilling over the content inside the defined scope limit, and this scope limit in *CollageJS* means the container provided by a `<Piece>` component, meaning content from an outside web project:  A piece project.

> **<Info />  Official Framework Adapter Feature**
>
> The `cjs-data-piece-host` attribute is something that official framework adapters add to their piece container elements.  If you're using a non-official adapter, the attribute might not be there.

So there you go!  Every time we use global stylesheets, we should make them scoped using the above scope definition.  We do this in root projects using `:root` as scope root, and we do it in piece projects using `:root` if we will only mount the piece in shadow DOM, or using an alternative root CSS selector, like a `data-` attribute our piece component sets.

We do this in piece projects too because piece projects also have the ability to mount other pieces from other projects.  Sometimes we forget this.

#### Scoping Bulma, Bootstrap or Similar

Unfortunately, it is not as easy as:

```css
@scope (:root) to ([data-cjs-piece-host]) {
  @import url('https://my.favorite.cdn/path/to/compiled/css');
}
```

This doesn't work.  But it works if we were importing SASS.  So the solution is to use SASS:

```scss
@scope (:root) to ([data-cjs-piece-host]) {
  @import url('https://my.favorite.cdn/path/to/scss');
}
```

---

Hopefully, with these CSS tips we'll be able to create leak-free *CollageJS* projects.