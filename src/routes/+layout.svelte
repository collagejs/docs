<script lang="ts">
	import favicon from '@collagejs/core/logo/16';
    import PaletteToggler from '$lib/PaletteToggler/PaletteToggler.svelte';
	import '../scss/app.scss';
    import { paletteCookie } from '$lib/cookies.js';

	let { children, data } = $props();

	// svelte-ignore state_referenced_locally
	let paletteName = $state<string>(data.palette);

	$effect(() => {
		document.cookie = `${paletteCookie}=${paletteName}; path=/; max-age=31536000`;
	});
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<title>CollageJS - Microfrontends Made Simple</title>
</svelte:head>
<div class="position-absolute end-0 m-3">
	<PaletteToggler bind:name={paletteName} />
</div>
<div class={["root", paletteName && `cjs-theme-${paletteName}`]}>
	<div class="container">
		<div class="content d-flex flex-column">
			{@render children()}
		</div>
	</div>
</div>

<style>
	.content {
		min-height: 100vh;
	}
	.root {
		background: var(--cjs-primary-gradient);
		overflow: auto;
	}
</style>