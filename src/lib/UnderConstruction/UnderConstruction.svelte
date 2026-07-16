<script lang="ts">
    import collageJsLogo from '@collagejs/core/logo/128';
    import { Construction, HardHat, Pickaxe } from '@lucide/svelte';
</script>

<div class="d-flex flex-column gap-5 justify-content-center align-items-center">
    <h1>Under Construction</h1>
    <div class="d-flex gap-3 align-items-center">
        <span class="d-none d-md-inline">
            <Construction size="5em" />
            <Construction size="5em" />
        </span>
        <span class="hat"><HardHat size="5em" /></span>
        <img src={collageJsLogo} alt="CollageJS Logo" class="logo" />
        <span class="pickaxe"><Pickaxe size="5em" /></span>
        <span class="d-none d-md-inline">
            <Construction size="5em" />
            <Construction size="5em" />
        </span>
    </div>
    <p>
         We're working hard on this.  Thank you for your patience!
    </p>
</div>

<style>
    p {
        font-size: 1.5em;
    }
    h1 {
        font-weight: bold;
    }
    .hat {
        transform: rotate(-25deg);
        position: relative;
        left: 5.3em;
        top: -4.5em;
    }
    .pickaxe {
        position: relative;
        left: -2.6em;
        top: 1em;
        animation: pickaxe-swing 1s ease-in-out infinite;
    }
    @keyframes pickaxe-swing {
        0%, 100% {
            transform: rotate(25deg);
        }
        50% {
            transform: rotate(0deg);
        }
    }
</style>