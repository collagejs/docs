---
  title: '@collagejs/vite-aim'
  description: |
    API reference for the @collagejs/vite-aim NPM package.
---

<script lang="ts">
    import type { PageProps } from './$types';
</script>

This NPM package provides the "auto-externalize import map" plug-in.  It provides 2 modules:

- The main module that exports the plug-in factory function
- The virtual `/im` module that exports the import map

## Main Module

### Functions

#### cjsAimPlugin

Builds the AIM Vite plug-in that auto-externalizes import maps.

```typescript
function cjsAimPlugin(options: CollageJsAimPluginOptions): Plugin;
```

##### Options

| Option | Type | Default Value | Description |
| - | - | - | - |
| `importMapEndpoint` | `string` | `'/__import_map'` | Defines the HTTP endpoint used to accept import map information from `@collagejs/imo`. |
| `allowedOrigins` | `string[]` | `undefined` | Sets the list of allowed origins that can send import map data. |
| `pathExceptions` | `string[]` | `[]` | List of paths that the plug-in will allow through without blocking. |
| `importMapTimeout` | `number` | `2_000` | The maximum time (in milliseconds) to block an HTTP GET request when import map data hasn't been received. |
| `logLevel` | `LogLevel` | `undefined` | Log level for this plug-in's logger object.  When not set, it inherits Vite's own log level value. |
| `banner` | `boolean` | `true` | Controls the inclusion of the CollageJS banner whenever Vite starts. |
| `importMap` | `ImportMap` | `undefined` | Import map to use during Vite's `build` mode. |
| `externalizationMode` | `'id' \| 'resolved'` | `'id'` | Determines the resolved value of modules during building.  The value of `id` simply leaves the module specifier untouched, while `resolved` returns the the import map's resolved value. |
| `shouldBlock` | `(request: Connect.IncomingMessage, stockPredicate: () => boolean) => boolean` | `undefined` | Predicate function to use instead of the stock predicate to determine if an HTTP request should be blocked or not. |

## Virtual `/im` Module

### Objects

#### importMap

Obtains the import map being used by the Vite plug-in.  The import map is the one:

- Received via the HTTP development server if Vite is running in `serve` mode
- Configured in the options when Vite is running in `build` mode

```typescript
import { importMap } from '@collagejs/vite-aim/im';
```
