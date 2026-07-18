<script lang="ts">
    import type { HTMLLiAttributes } from 'svelte/elements';
    import type { ArticleDefinition } from '../../../types.js';
    import { page } from '$app/state';

    type Props = HTMLLiAttributes & {
        articleDefinition: ArticleDefinition;
    };

    let { class: cssClass, articleDefinition, ...restProps }: Props = $props();

    const isActive = $derived(page.url.pathname.endsWith(articleDefinition.href));
</script>

<li class={['my-2', cssClass]} {...restProps}>
    <a class={[isActive && 'active']} href={articleDefinition.href}>{articleDefinition.title}</a>
</li>
