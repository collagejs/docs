# CollageJS Docs

SvelteKit docs site configured for Cloudflare Workers (server-side), using `@sveltejs/adapter-cloudflare`.

## Local development

```sh
npm install
npm run dev
```

## Build for Cloudflare Workers

```sh
npm run build
```

This generates the Worker entry at `.svelte-kit/cloudflare/_worker.js` and static assets in `.svelte-kit/cloudflare`.

## Run the built Worker locally

```sh
npm run build
npm run cf:dev
```

## Deploy manually

1. Authenticate Wrangler once:

```sh
npx wrangler login
```

2. Deploy:

```sh
npm run build
npm run cf:deploy
```

## CI/CD (GitHub Actions)

The workflow at `.github/workflows/deploy-cloudflare-workers.yml` deploys on pushes to `main`.

Set these repository secrets:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

Token permissions should include Workers edit/deploy privileges for your account.

## Configure Worker name

Edit `wrangler.jsonc` and update:

- `name`: your Worker service name

The current placeholder is `collagejs-docs`.
