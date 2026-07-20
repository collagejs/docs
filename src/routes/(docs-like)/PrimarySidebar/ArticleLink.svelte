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

<li class={['my-2', isActive && 'active', cssClass]} {...restProps}>
    <a href={articleDefinition.href}>{articleDefinition.title}</a>
    {#if isActive}
        <ArrowBigLeftDash fill="currentColor" />
    {/if}
</li>
