<script lang="ts">
    import { Check } from '@lucide/svelte';
    import type { HTMLLiAttributes } from 'svelte/elements';
    import { ListContext, listContext } from './list-context.svelte.js';

    let {
        children,
        ...restProps
    }: HTMLLiAttributes = $props();

    let ctx: ListContext | undefined;
    try {
        ctx = listContext();
    } catch { }
    const isOrdered = !!ctx?.value;
</script>

<li {...restProps}>
    {#if !isOrdered}
        <Check size="0.8em" color="var(--cjs-primary-400)" />&nbsp;
    {/if}
    {@render children?.()}
</li>
