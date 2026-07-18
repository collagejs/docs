<script lang="ts">
    import type { ArticleNode } from '../../../types.js';
    import ArticleLink from './ArticleLink.svelte';
    import ArticlesContainer from './ArticlesContainer.svelte';
    import Section from './Section.svelte';
    import { isArticleGroupDefinition } from '../utils.js';

    type Props = {
        articleDefinitions: ArticleNode[];
    };

    let { articleDefinitions }: Props = $props();
</script>

<aside class="widget widget-rounded py-2 px-3">
    <ArticlesContainer>
        {#each articleDefinitions as articleDefinition}
            {#if isArticleGroupDefinition(articleDefinition)}
                <Section group={articleDefinition}></Section>
            {:else}
                <ArticleLink {articleDefinition} />
            {/if}
        {/each}
    </ArticlesContainer>
</aside>
