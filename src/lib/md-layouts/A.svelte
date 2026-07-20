<script lang="ts">
    import type { HTMLAnchorAttributes } from 'svelte/elements';
    import { page } from '$app/state';
    import ExternalLink from '$lib/ExternalLink/ExternalLink.svelte';

    let { href, children, ...restProps }: HTMLAnchorAttributes = $props();

    function isExternalLink(href: string | null | undefined): boolean {
        if (!href) return false;
        try {
            const url = new URL(href);
            return url.origin !== page.url.origin;
        } catch {
            return false;
        }
    }
</script>

{#if isExternalLink(href)}
    <ExternalLink {href} {children} {...restProps} />
{:else}
    <a {href} {...restProps}>
        {@render children?.()}
    </a>
{/if}
