<script lang="ts">
    import type { LayoutProps } from './$types';
    import { primarySidebar } from '../PrimarySidebar/context.svelte.js';
    import docsPrimarySidebar from './primary-sidebar.json' with { type: 'json' };

    let { data, children }: LayoutProps = $props();
    primarySidebar().value = docsPrimarySidebar;
</script>

{@render children()}