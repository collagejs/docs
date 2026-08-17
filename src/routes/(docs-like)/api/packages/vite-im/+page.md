---
  title: '@collagejs/vite-im'
  description: |
    API reference for the @collagejs/vite-im NPM package.
---

<script lang="ts">
    import type { PageProps } from './$types';
</script>

This NPM package provides a Vite plug-in that injects overridable import maps and the `@collagejs/imo` import map overriding capabilities to a Vite-powered project.


## Functions

### cjsImPlugin

Builds the IM Vite plug-in that injects import maps.

```typescript
function cjsImPlugin(
  options: CollageJsImPluginOptions
): [Plugin, Plugin | null];
```

#### Options

| Option | Type | Default Value | Description |
| - | - | - | - |
| `importMaps` | `string \| ImportMapsSpec` | `{ dev: 'src/importMap.dev.json', build: 'src/importMap.json' }` | Specifies the import map files to injecdt to the project's main HTML file. |
| `imo` | `ImoSource \| ImoSpec` | `true` | Controls the inclusion of the `@collagejs/imo` NPM package's overriding script. |
| `imoUi` | `boolean \| ImoUiFactoryOptions` | Controls the inclusion of the `@collagejs/imo` NPM package's user interface. |
| `aim` | `boolean` | `undefined` | Turns on or off the [Vite-AIM](/api/packages/vite-aim) plug-in. |

##### `imo` Option

- Set to `false` to avoid including the import map overriding script.
- Set to `true` to inject the overriding script from the JSDelivr network using the NPM package's latest version.
- Set to a function that returns a string to control the CDN and package version that is injected.

###### ImoSpec

```typescript
type ImoSpec = {
  source: ImoSource;
  options?: ImPostingOptions | undefined;
}
```

Use this variant to configure the source of the overriding script as seen above, plus be able to provide options according to the documentation for [@collagejs/imo](/api/packages/imo).
