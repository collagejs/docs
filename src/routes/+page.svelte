<script lang="ts">
    import Hero from './Hero.svelte';
    import Features from './Features/Features.svelte';
    import DocsLinks from './DocsLinks/DocsLinks.svelte';
    import PaletteToggler from '$lib/PaletteToggler/PaletteToggler.svelte';
    import { palette } from '$lib/contexts.svelte.js';

    const pal = palette();
</script>

<div class="position-absolute end-0 m-3">
	<PaletteToggler bind:name={pal.value} />
</div>
<main class="container d-flex flex-column">
    <section class="d-flex flex-justify-content-center align-items-center">
        <Hero />
    </section>
    <section class="container">
        <Features />
    </section>
    <section class="mt-5">
        <DocsLinks />
    </section>
</main>
<footer class="m-3 mt-auto">
    Copyright &copy; 2026 CollageJS. All rights reserved.
</footer>
