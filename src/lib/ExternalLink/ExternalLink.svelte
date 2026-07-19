<script lang="ts">
    import type { HTMLAnchorAttributes } from 'svelte/elements';

    let {
        target,
        rel,
        children,
        ...restProps
    }: HTMLAnchorAttributes = $props();

    let finalRel = $derived.by(() => {
        const set = new Set<string>(rel?.split(' ') ?? []);
        set.add('noreferrer');
        return Array.from(set).join(' ');
    });
</script>

<a target={target ?? '_blank'} rel={finalRel} {...restProps}>
    {@render children?.()}
</a>
