<script lang="ts">
    import { onMount } from 'svelte';
    import { dismissCookieBanner, hasCookieBannerBeenDismissed } from '$lib/cookies.js';
    import { Palette } from '@lucide/svelte';

    let show = $state(false);

    onMount(() => {
        show = !hasCookieBannerBeenDismissed();
    });

    function handleDismiss() {
        dismissCookieBanner();
        show = false;
    }
</script>

{#if show}
    <div class="cookie-banner cjs-glass" role="dialog" aria-live="polite" aria-label="Cookie notice">
        <p>
            This site uses two cookies: Your color palette selection (<Palette
                size="1.2em"
                class="cjs-text-primary"
                strokeWidth="3"
            />) and a screen-width value used to render tables correctly on smaller screens.
        </p>
        <button type="button" class="cjs-btn cjs-btn-sm cjs-btn-primary" onclick={handleDismiss}> OK </button>
    </div>
{/if}

<style>
    .cookie-banner {
        position: fixed;
        left: 50%;
        bottom: 1rem;
        transform: translateX(-50%);
        z-index: 1050;
        max-width: min(90vw, 24rem);
        width: max-content;
        padding: 0.9rem 1rem;
        border: 1px solid rgba(255, 255, 255, 0.2);
        border-radius: 0.75rem;
        color: #f8fafc;
        box-shadow: 0 0.75rem 2rem rgba(0, 0, 0, 0.2);
        display: flex;
        align-items: center;
        gap: 0.75rem;
    }
    .cookie-banner p {
        margin: 0;
        font-size: 0.9rem;
        line-height: 1.4;
    }
    .cookie-banner button {
        white-space: nowrap;
    }
</style>
