<script lang="ts">
    import type { ArticleGroupDefinition } from '../../../types.js';
    import { isArticleGroupDefinition } from '../utils.js';
    import Self from './Section.svelte';
    import ArticlesContainer from './ArticlesContainer.svelte';
    import ArticleLink from './ArticleLink.svelte';

    type Props = {
        level?: number;
        group: ArticleGroupDefinition;
    };

    let { level = 1, group }: Props = $props();
</script>

<div>
    <svelte:element this={`h${Math.min(level + 3, 6)}`}>{group.title}</svelte:element>
    <ArticlesContainer>
        {#each group.articles as article}
            {#if isArticleGroupDefinition(article)}
                <Self level={level + 1} group={article}></Self>
            {:else}
                <ArticleLink articleDefinition={article} />
            {/if}
        {/each}
    </ArticlesContainer>
</div>

<style>
    h4, h5, h6 {
        font-size: 1rem;
        font-weight: 600;
        margin-top: 1rem;
        margin-bottom: 0.75rem;
    }
</style>
