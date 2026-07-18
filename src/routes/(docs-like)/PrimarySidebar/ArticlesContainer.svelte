<script lang="ts">
    import type { HTMLAttributes } from "svelte/elements";

    type Props = HTMLAttributes<HTMLUListElement>;

    let {
        class: cssClass,
        children,
        ...restProps
    }: Props = $props();
</script>

<ul class={['ms-2', 'p-0', cssClass]} {...restProps}>
    {@render children?.()}
</ul>

<style>
    ul {
        list-style: none;
    }
</style>