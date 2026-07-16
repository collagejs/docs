<script lang="ts">
    import type { Snippet } from "svelte";
    import type { HTMLAttributes } from "svelte/elements";

    type Props = HTMLAttributes<HTMLDivElement> & {
        children?: Snippet;
    };

    let {
        children,
        class: cssClass,
        ...restProps
    }: Props = $props();
</script>

<div class={["card", cssClass]} {...restProps}>
    {@render children?.()}
</div>

<style>
    .card {
        background-color: rgba(var(--cjs-black-rgb), 0.8);
        color: var(--cjs-white);
        border: 1px solid var(--cjs-card-border);
        border-radius: 0.5rem;
        padding: 1rem;
        margin: 1rem 0;
    }
</style>