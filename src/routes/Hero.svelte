<script lang="ts">
    import collageJsBigLogo from '@collagejs/core/logo/512';
    import Highlights from './Highlights.svelte';
</script>

<div class="hero d-flex flex-column align-items-center flex-md-row gap-3">
    <img src={collageJsBigLogo} alt="CollageJS Logo" class="hero-logo" />
    <div class="side w-100">
        <h1>CollageJS</h1>
            <Highlights />
    </div>
</div>

<style>
    .hero {
        & .hero-logo {
            flex-shrink: 0;
            flex-grow: 0;
            width: 256px;
            height: 256px;
        }

        & .side {
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
        }

        & h1 {
            font-size: 3.5rem;
            font-weight: bold;
            margin: 0;
        }
    }
</style>