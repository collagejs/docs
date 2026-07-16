<script lang="ts" generics="T extends { toolTip: string }">
    import type { Snippet } from 'svelte';
    import type { HTMLButtonAttributes } from 'svelte/elements';
    import { fly } from 'svelte/transition';

    type Props = Omit<HTMLButtonAttributes, 'children'> & {
        items: T[];
        currentIndex?: number;
        children: Snippet<[item: T]>;
        onToggle?: (item: T, index: number) => void;
    };

    let {
        items,
        currentIndex = $bindable(0),
        class: cssClass,
        children,
        onToggle,
        ...restProps
    }: Props = $props();

    function toggle() {
        currentIndex = (currentIndex + 1) % items.length;
        onToggle?.(items[currentIndex], currentIndex);
    }
</script>

<button type="button" class={['transitioned-content', cssClass]} {...restProps} onclick={toggle} title={items[currentIndex].toolTip}>
    {#key currentIndex}
        <span in:fly={{ y: 20, duration: 500 }} out:fly={{ y: -20, duration: 500 }}>
            {@render children?.(items[currentIndex])}
        </span>
    {/key}
</button>

<style>
    .transitioned-content {
        display: grid;
        & > * {
            grid-area: 1 / 1 / 2 / 2;
        }
    }
</style>
