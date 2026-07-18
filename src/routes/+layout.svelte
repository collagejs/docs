<script lang="ts">
	import favicon from '@collagejs/core/logo/16';
	import '../scss/app.scss';
    import { paletteCookie } from '$lib/cookies.js';
	import { PaletteContext, setPalette } from '$lib/contexts.svelte.js';

	let { children, data } = $props();
	
	let palette = new PaletteContext();
	// svelte-ignore state_referenced_locally
	palette.value = data.palette;
	setPalette(palette);

	$effect(() => {
		document.cookie = `${paletteCookie}=${palette.value}; path=/; max-age=31536000`;
	});
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<title>CollageJS - Microfrontends Made Simple</title>
</svelte:head>
<div class={["root", palette.value && `cjs-palette-${palette.value}`]}>
	<div class="content d-flex flex-column overflow-auto">
		{@render children()}
	</div>
</div>

<style>
	.content {
		height: 100vh;
	}
	.root {
		background: var(--cjs-primary-gradient);
		position: relative;
	}
</style>