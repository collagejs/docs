<script lang="ts">
    import { onMount } from 'svelte';
    import { slide } from 'svelte/transition';

    const highlights = [
        'Lightweight, modern micro-frontends library',
        'Great DX on modern Vite-based projects',
        'TypeScript-first library',
        'Compose with React, Svelte, Vue, Solid, and more',
        'Automatic externalization of import map entries',
        'Mount in light DOM, open or closed shadow roots',
        'Automatic CSS injection:  If Vite can bundle it, CollageJS can inject it',
    ];
    let currentMottoIndex = $state(0);

    onMount(() => {
        const mottoInterval = setInterval(() => {
            currentMottoIndex = (currentMottoIndex + 1) % highlights.length;
        }, 5_000);

        return () => clearInterval(mottoInterval);
    });
</script>

<div class="motto-container">
    {#key currentMottoIndex}
        <div class="transition-grid cjs-text-2xl">
            <blockquote transition:slide>
                <p>{highlights[currentMottoIndex]}</p>
            </blockquote>
        </div>
    {/key}
</div>

<style>
    blockquote {
        margin: 0;
        padding: 0;
        font-weight: 200;
        font-style: italic;
        min-height: 2.8em;

        & p {
            margin: 0;
        }
    }
    .motto-container {
        width: 100%;
        position: relative;
    }
    .transition-grid {
        display: grid;
        grid: 1/1/2/2;
    }
</style>
