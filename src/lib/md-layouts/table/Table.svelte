<script lang="ts">
    import type { HTMLTableAttributes } from 'svelte/elements';

    let { children, ...restProps }: HTMLTableAttributes = $props();
</script>

<table {...restProps}>
    {@render children?.()}
</table>

<style>
    table {
        border: 1px solid var(--cjs-primary);
        :global {
            & tbody {
                tr:nth-child(even) {
                    background-color: rgba(var(--cjs-white-rgb), 0.05);
                }
                tr:hover {
                    background-color: rgba(var(--cjs-white-rgb), 0.15);
                }
            }
        }
    }
</style>
