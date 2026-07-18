<script lang="ts">
    import { FileBracesCorner, StarPlus, FastForward, Combine } from '@lucide/svelte';
    import Card from '../Card/Card.svelte';
    import viteLogo from '$lib/assets/vite.svg';
</script>

<div class="row gap-3">
    <Card class="col-12 col-md">
        <span class="card-title"><img src={viteLogo} alt="Vite" class="title-logo" />Vite v8 Plug-Ins</span>
        <ul class="list">
            <li>
                <StarPlus size="1em" color="var(--cjs-primary-200)" />&nbsp;<a
                    href="https://collagejs.dev/"
                    target="_blank">Vite-IM</a
                > - Import Map Handling
            </li>
            <li>
                <StarPlus size="1em" color="var(--cjs-primary-200)" />&nbsp;<a
                    href="https://collagejs.dev/"
                    target="_blank">Vite-CSS</a
                > - CSS Injection
            </li>
            <li>
                <StarPlus size="1em" color="var(--cjs-primary-200)" />&nbsp;<a
                    href="https://collagejs.dev/"
                    target="_blank">Vite-AIM</a
                > - Automatic externalization
            </li>
        </ul>
    </Card>
    <Card class="col col-md">
        <span class="card-title"><Combine />&nbsp;Import Maps</span>
        <ul class="list">
            <li><FileBracesCorner size="1em" color="var(--cjs-primary-200)" />&nbsp;Dev/build import maps</li>
            <li>
                <FileBracesCorner size="1em" color="var(--cjs-primary-200)" />&nbsp;Dev/build automatic externalization
            </li>
            <li><FileBracesCorner size="1em" color="var(--cjs-primary-200)" />&nbsp;Dev tool for overrides</li>
        </ul>
    </Card>
    <Card class="col col-md">
        <span class="card-title"><FastForward />&nbsp;Test-drive in minutes</span>
        <pre class="code-block">npx degit https://github.com/collagejs/root-template.git</pre>
        <p>Or <a href="https://github.com/new?template_name=root-template&template_owner=collagejs" target="_blank">Clone template on GitHub</a></p>
    </Card>
</div>

<style>
    .card-title {
        display: inline-block;
        font-size: 1.2rem;
        font-weight: bold;
        margin-bottom: 0.5rem;
        color: var(--cjs-primary-300);
    }
    .list {
        list-style-type: none;
        padding: 1em;
    }
    .title-logo {
        width: 1.5rem;
        height: 1.5rem;
        vertical-align: middle;
        margin-right: 0.5rem;
    }
</style>
