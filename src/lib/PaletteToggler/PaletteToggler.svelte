<script lang="ts">
    import Toggler from '$lib/Toggler/Toggler.svelte';
    import { ChessKing, CloudSun, Highlighter, Trees, Palette } from '@lucide/svelte';

    type Props = {
        name: string;
    };

    let {
        name = $bindable()
    }: Props = $props();

    const items = [
        {
            toolTip: 'Accent',
            name: 'accent',
            icon: Highlighter
        },
        {
            toolTip: 'Royal',
            name: 'royal',
            icon: ChessKing
        },
        {
            toolTip: 'Sky',
            name: 'sky',
            icon: CloudSun
        },
        {
            toolTip: 'Nature',
            name: 'nature',
            icon: Trees
        }
    ];
    let curIndex = $state(items.findIndex(i => i.name === name) ?? 0);

    function setPalette(newName: string) {
        name = newName;
    }

    $effect(() => {
        setPalette(items[curIndex].name);
    });
</script>

<div class="d-flex gap-1 align-items-center">
    <Palette size="1.5em" />
    <Toggler class="cjs-btn cjs-btn-neutral cjs-btn-sm" {items} bind:currentIndex={curIndex}>
        {#snippet children(item)}
            <item.icon size="1.5em" />
        {/snippet}
    </Toggler>
</div>
