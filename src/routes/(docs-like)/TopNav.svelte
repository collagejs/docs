<script lang="ts">
    import PaletteToggler from '$lib/PaletteToggler/PaletteToggler.svelte';
    import collageJsLogo from '@collagejs/core/logo/16';
    import { palette } from '$lib/contexts.svelte.js';
    import { page } from '$app/state';
    import { MediaQuery } from 'svelte/reactivity';
    import { browser } from '$app/env';

    const pal = palette();
    let showCollapsible = $state(false);
    const collapseMq = new MediaQuery('(min-width: 768px)');
    const finalShowCollapsible = $derived(browser ? collapseMq.current || showCollapsible : true);

    function isActive(path: string) {
        return page.route.id?.startsWith(`/(docs-like)${path}`) ?? false;
    }
</script>

<nav class="navbar widget p-3">
    <div class="container-md d-flex flex-column flex-md-row align-items-md-center gap-3">
        <div class="d-flex">
            <div class="title flex-grow-0">
                <a href="/"><img src={collageJsLogo} alt="CollageJS" /></a>&nbsp;CollageJS
            </div>
            <button
                type="button"
                class="cjs-btn cjs-btn-neutral cjs-btn-sm hamburger d-md-none ms-auto"
                aria-label="Toggle navigation"
                onclick={() => (showCollapsible = !showCollapsible)}
            >
                <div class="line"></div>
                <div class="line"></div>
                <div class="line"></div>
            </button>
        </div>
        <div
            class={[
                'collapsible',
                'ms-5',
                'd-none',
                'd-md-flex',
                'flex-grow-1',
                'flex-column',
                'flex-md-row',
                'align-items-start',
                'align-items-md-center',
                'gap-3',
                'justify-content-start',
                'justify-content-md-between'
            ]}
            style={`display: ${finalShowCollapsible ? 'flex' : 'none'} !important;`}
        >
            <div>
                <PaletteToggler bind:name={pal.value} />
            </div>
            <ul class="items d-flex flex-row gap-3">
                <li><a href="/docs" class:active={isActive('/docs')}>Docs</a></li>
                <li><a href="/guides" class:active={isActive('/guides')}>Guides</a></li>
                <li><a href="/api" class:active={isActive('/api')}>API</a></li>
            </ul>
        </div>
    </div>
</nav>

<style>
    .navbar {
        & .title {
            font-size: 1.3em;
            font-weight: bold;

            & img {
                height: 1.3em;
            }
        }

        & .hamburger {
            flex-direction: column;
            justify-content: space-between;
            width: 1.5em;
            height: 1.5em;
            background: none;
            border: none;
            padding: 0;

            & .line {
                width: 100%;
                height: 0.3em;
                background-color: var(--cjs-white);
            }
        }

        & ul.items {
            list-style: none;
            margin: 0;
            padding: 0;
        }
    }
</style>
