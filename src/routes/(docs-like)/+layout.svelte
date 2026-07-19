<script lang="ts">
    import { page } from '$app/state';
    import type { ArticleDefinition, ArticleNode } from '../../types.js';
    import type { LayoutProps } from './$types';
    import Footer from './Footer.svelte';
    import NavArticleButtons from './NavArticleButtons/NavArticleButtons.svelte';
    import PrimarySidebar from './PrimarySidebar/PrimarySidebar.svelte';
    import { PrimarySidebarContext, setPrimarySidebar } from './PrimarySidebar/context.svelte.js';
    import TopNav from './TopNav.svelte';
    import { isArticleGroupDefinition } from './utils.js';
    import { ScrollDocContext, setScrollDoc } from '$lib/scrollDocContext.svelte.js';

    let { data, children }: LayoutProps = $props();

    const primarySidebarCtx = setPrimarySidebar(new PrimarySidebarContext());

    const flattenedArticleDefinitions = $derived.by(() => {
        const extract = (ads: ArticleNode[]) => {
            const result: ArticleDefinition[] = [];
            for (let ad of ads) {
                if (isArticleGroupDefinition(ad)) {
                    result.push(...extract(ad.articles));
                    continue;
                }
                result.push(ad);
            }
            return result;
        };
        return extract(primarySidebarCtx.value);
    });
    const currentArticleDefinitionIndex = $derived(
        flattenedArticleDefinitions.findIndex((ad) => page.url.pathname === ad.href)
    );
    const nextArticleDefinition = $derived(flattenedArticleDefinitions[currentArticleDefinitionIndex + 1]);
    const previousArticleDefinition = $derived(flattenedArticleDefinitions[currentArticleDefinitionIndex - 1]);

    if (import.meta.env.DEV) {
        setScrollDoc(new ScrollDocContext());
    }
</script>

<div class="contents d-flex flex-column gap-3 h-100">
    <TopNav />
    <div class="flex-grow-1 overflow-auto">
        <main class="container">
            <div class="row gx-1 gy-1">
                {#if primarySidebarCtx.value?.length > 0}
                    <div class="col-12 col-md-3 order-2 order-md-1">
                        <PrimarySidebar articleDefinitions={primarySidebarCtx.value} />
                    </div>
                {/if}
                <div class={['col-12 order-1 order-md-2', primarySidebarCtx.value?.length > 0 && 'col-md-9']}>
                    {@render children()}
                    {#if nextArticleDefinition || previousArticleDefinition}
                        <NavArticleButtons prev={previousArticleDefinition} next={nextArticleDefinition} />
                    {/if}
                </div>
            </div>
        </main>
        <Footer />
    </div>
</div>

<style>
    .contents {
        --widget-bg: rgba(var(--cjs-black-rgb), 0.8);
        --widget-fg: rgba(var(--cjs-white-rgb), 0.9);
    }
</style>
