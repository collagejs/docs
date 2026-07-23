<script module>
    export { default as h1 } from './headers/H1.svelte';
    export { default as h2 } from './headers/H2.svelte';
    export { default as h3 } from './headers/H3.svelte';
    export { default as h4 } from './headers/H4.svelte';
    export { default as h5 } from './headers/H5.svelte';
    export { default as h6 } from './headers/H6.svelte';
    export { default as hr } from './Hr.svelte';
    export { default as li } from './Li.svelte';
    export { default as ol } from './Ol.svelte';
    export { default as blockquote } from './Blockquote.svelte';
    export { default as a } from './A.svelte';
    export {
        table,
        thead,
        tbody,
        tr,
        th,
        td
    } from 'mdsvex-table';
</script>

<script lang="ts">
    import type { Snippet } from 'svelte';
    import '../../scss/code.css';
    import '../../scss/md-content.css';
    import H1 from './headers/H1.svelte';
    import { scrollDoc, ScrollDocContext } from '$lib/scrollDocContext.svelte.js';
    import { TableContext, setTableContext } from 'mdsvex-table';

    type Props = {
        title: string;
        seoTitle?: string;
        description?: string;
        children?: Snippet;
    };

    let {
        title,
        seoTitle = title,
        description,
        children
    }: Props = $props();

    let scrollDocCtx: ScrollDocContext | undefined;
    try {
        scrollDocCtx = scrollDoc();
    }
    catch { }

    let topEl: HTMLElement | null = null;
    let scroll = $derived(scrollDocCtx?.value ?? true);

    $effect(() => {
        if (!scroll) {
            return;
        }
        topEl?.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });

    setTableContext(new TableContext());
</script>

<svelte:head>
    <title>{seoTitle} - CollageJS</title>
    {#if description}
        <meta name="description" content={description} />
    {/if}
</svelte:head>

<article bind:this={topEl} class="widget widget-rounded px-5 py-3 md-content mb-1">
    <H1>{title}</H1>
    {@render children?.()}
</article>
