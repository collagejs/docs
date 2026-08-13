import { defineConfig } from 'vitest/config';
import { join } from 'path';
import { playwright } from '@vitest/browser-playwright';
import adapter from '@sveltejs/adapter-cloudflare';
import { sveltekit } from '@sveltejs/kit/vite';
import { mdsvex } from 'mdsvex';
import rehypeSlug from 'rehype-slug';
import type { Literal, Node } from 'unist';
import visit from 'unist-util-visit';
import type { Transformer } from 'unified';

function unescapePipesInTables(): Transformer {
    return (tree) => {
        function replace(node: Node) {
			visit(node, (child: any) => {
				if (child.value && !child.children) {
					child.value = child.value.replace(/\\\|/g, '|');
				}
            });
		}
		visit(tree, 'tableCell', replace);
    };
}

export default defineConfig({
	plugins: [
		sveltekit({
			extensions: ['.svelte', '.md'],
			compilerOptions: {
				// Force runes mode for the project, except for libraries. Can be removed in svelte 6.
				runes: ({ filename }) => {
					const parts = filename.split(/[/\\]/);
					const fileName = parts[parts.length - 1];
					return parts.includes('node_modules') ||
						fileName.endsWith('.md') ? undefined : true;
				}
			},
			adapter: adapter(),
			preprocess: mdsvex({
				extensions: ['.md'],
				remarkPlugins: [
					unescapePipesInTables
				],
				rehypePlugins: [
					// @ts-expect-error TS2322 mdsvex urgently needs to update packages
					rehypeSlug,
					unescapePipesInTables,
				],
				smartypants: true,
				layout: join(import.meta.dirname, './src/lib/md-layouts/MdLayout.svelte'),
			}),
		}),
	],
	test: {
		expect: { requireAssertions: true },
		projects: [
			{
				extends: './vite.config.ts',
				test: {
					name: 'client',
					browser: {
						enabled: true,
						provider: playwright(),
						instances: [{ browser: 'chromium', headless: true }]
					},
					include: ['src/**/*.svelte.{test,spec}.{js,ts}'],
					exclude: ['src/lib/server/**']
				}
			},

			{
				extends: './vite.config.ts',
				test: {
					name: 'server',
					environment: 'node',
					include: ['src/**/*.{test,spec}.{js,ts}'],
					exclude: ['src/**/*.svelte.{test,spec}.{js,ts}']
				}
			}
		]
	},
	css: {
		preprocessorOptions: {
			scss: {
				silenceDeprecations: [
					'import',
					'color-functions',
					'global-builtin',
					'if-function',
				]
			}
		}
	}
});
