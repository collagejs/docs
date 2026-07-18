<script lang="ts">
    import type { HTMLAttributes } from "svelte/elements";

    type Props = HTMLAttributes<HTMLHeadingElement> & {
        level: 1 | 2 | 3 | 4 | 5 | 6;
    };

    let {
        level,
        class: cssClass,
        children,
        ...restProps
    }: Props = $props();
</script>

<svelte:element this={`h${level}`} class={['cjs-header', cssClass]} {...restProps}>
    {@render children?.()}
</svelte:element>

<style>
    .cjs-header {
        color: var(--cjs-primary-400);
        text-shadow: 0 0 1px rgba(var(--cjs-black-rgb), 0.5);
    }
</style>