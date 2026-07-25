<script lang="ts">
    import type { HTMLAttributes } from 'svelte/elements';
    import { Link } from '@lucide/svelte';

    type Props = HTMLAttributes<HTMLHeadingElement> & {
        level: 1 | 2 | 3 | 4 | 5 | 6;
    };

    let { level, id, class: cssClass, children, ...restProps }: Props = $props();
</script>

{#snippet copiableLink()}
    <a href="#{id}" class="cjs-header-link" aria-label="Link to this section">
        <Link size="1em" />
    </a>
{/snippet}

<svelte:element this={`h${level}`} class={['cjs-header', cssClass]} {id} {...restProps}>
    {@render children?.()}
    {#if id}
        {@render copiableLink()}
    {/if}
</svelte:element>

<style>
    .cjs-header {
        color: var(--cjs-primary-400);
        text-shadow: 0 0 1px rgba(var(--cjs-black-rgb), 0.5);

        & .cjs-header-link {
            display: block;
            overflow: hidden;
            color: var(--cjs-primary-400);
            text-decoration: none;
            width: 1px;
            height: 1px;
            transition: width 0.2s ease-in-out, height 0.2s ease-in-out;

            &:focus {
                display: inline;
                overflow: visible;
                width: auto;
                height: auto;
            }
        }

        &:hover {
            & .cjs-header-link {
                display: inline;
                overflow: visible;
                width: auto;
                height: auto;
            }
        }
    }   
</style>
