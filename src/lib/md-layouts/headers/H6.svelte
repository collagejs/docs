<script lang="ts">
    import type { ComponentProps } from 'svelte';
    import Header from './Header.svelte';

    let {
        ...restProps
    }: Omit<ComponentProps<typeof Header>, 'level'> = $props();
</script>

<Header level={6} {...restProps} />
