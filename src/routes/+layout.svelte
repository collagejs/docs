<script lang="ts">
	import favicon from '@collagejs/core/logo/16';
	import '../scss/app.scss';
    import { paletteCookie, renderAsListCookie } from '$lib/cookies.js';
	import { PaletteContext, setPalette, RenderAsListContext, setRenderAsList } from '$lib/contexts.svelte.js';

	let { children, data } = $props();
	
	// svelte-ignore state_referenced_locally
	const palette = new PaletteContext(data.palette);
	setPalette(palette);
	// svelte-ignore state_referenced_locally
	setRenderAsList(new RenderAsListContext(data.renderAsList));

	let innerWidth = $state(0);

	$effect(() => {
		document.cookie = `${paletteCookie}=${palette.value}; path=/; max-age=31536000`;
	});

	$effect(() => {
		document.cookie = `${renderAsListCookie}=${innerWidth <= 576}; path=/; max-age=31536000`;
	});
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<title>CollageJS - Microfrontends Made Simple</title>
</svelte:head>
<svelte:window bind:innerWidth />
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
