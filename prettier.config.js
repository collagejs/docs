/** @type {import("prettier").Config} */
const config = {
	useTabs: false,
	singleQuote: true,
	semi: true,
	tabWidth: 4,
	trailingComma: 'none',
	printWidth: 120,
	plugins: ['prettier-plugin-svelte'],
	overrides: [{ files: '*.svelte', options: { parser: 'svelte' } }, {
		files: '.github/workflows/*.yml',
		options: {
			useTabs: false,
			tabWidth: 2,
			parser: 'yaml',
		}
	}]
};

export default config;
