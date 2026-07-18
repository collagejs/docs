<script lang="ts">
    import type { HTMLBlockquoteAttributes } from "svelte/elements";

    let {
        children,
        ...restProps
    }: HTMLBlockquoteAttributes = $props();
</script>

<blockquote {...restProps}>
    {@render children?.()}
</blockquote>

<style>
    blockquote {
        padding: 1rem;
        margin: 1rem;
        background: rgba(var(--cjs-white-rgb), 0.15);
        color: var(--color-text-secondary);
    }
</style>