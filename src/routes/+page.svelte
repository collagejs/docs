<script lang="ts">
    import Hero from './Hero.svelte';
    import Features from './Features/Features.svelte';
    import DocsLinks from './DocsLinks/DocsLinks.svelte';
</script>

<main class="d-flex flex-column h-100">
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
<footer class="mt-auto mb-3">
    Copyright &copy; 2026 CollageJS. All rights reserved.
</footer>
