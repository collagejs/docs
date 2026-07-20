<script lang="ts">
    import { FastForward, Rewind } from "@lucide/svelte";
import type { ArticleDefinition } from "../../../types.js";

    type Props = {
        prev: ArticleDefinition | undefined;
        next: ArticleDefinition | undefined;
        start: boolean;
    };

    let {
        prev,
        next,
        start
    }: Props = $props();
</script>

<nav class="widget widget-rounded gap-2 p-2">
    <a class={["cjs-btn cjs-btn-primary cjs-btn-outline", 'flex-grow-1', !prev && 'invisible']} href={prev?.href ?? "#"}>
        <div class="d-flex flex-column align-items-start w-100">
            <Rewind />
            <span class="cjs-text-muted">Previous</span>
            {#if prev}
                <span>{prev.title}</span>
            {/if}
        </div>
    </a>
    <a class={["cjs-btn cjs-btn-primary cjs-btn-outline", 'flex-grow-1', !next && 'invisible']} href={next?.href ?? "#"}>
        <div class="d-flex flex-column align-items-end w-100 text-end">
            <FastForward />
            <span class="cjs-text-muted">{start? 'Start' : 'Next'}</span>
            {#if next}
                <span>{next.title}</span>
            {/if}
        </div>
    </a>
</nav>

<style>
    nav {
        display: grid;
        grid-template-columns: 1fr 1fr;
    }
</style>