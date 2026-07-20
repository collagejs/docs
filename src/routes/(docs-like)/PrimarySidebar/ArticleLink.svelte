<script lang="ts">
    import type { HTMLLiAttributes } from 'svelte/elements';
    import type { ArticleDefinition } from '../../../types.js';
    import { page } from '$app/state';
    import { ArrowBigLeftDash } from '@lucide/svelte';

    type Props = HTMLLiAttributes & {
        articleDefinition: ArticleDefinition;
    };

    let { class: cssClass, articleDefinition, ...restProps }: Props = $props();

    const isActive = $derived(page.url.pathname.endsWith(articleDefinition.href));
</script>

<li class={['my-2 d-flex gap-2 align-items-center', isActive && 'active', cssClass]} {...restProps}>
    <a href={articleDefinition.href}>{articleDefinition.title}</a>
    {#if isActive}
        <span class="flex-grow-1 flex-shrink-1">
            <ArrowBigLeftDash fill="currentColor" />
        </span>
    {/if}
</li>
