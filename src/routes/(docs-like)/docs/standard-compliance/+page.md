---
  title: Standard Compliance
  description: |
    Summary of how each official adapter complies with the official standard for framework adapters.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import Compliance from './Compliance.svelte';
    import Ol from '$lib/md-layouts/Ol.svelte';
    import Li from '$lib/md-layouts/Li.svelte';
</script>

This document summarizes how well each official framework adapter complies with the sought standard for framework adapters.  It can be regarded as an official adapter checklist for anyone building a framework adapter.

## Piece Building

These are the definitions of the standardizations for piece building:

| Item | Description |
| - | - |
| Main function: `buildPiece` | The `buildPiece` function is the one in charge of creating core pieces. |
| No additional required functions | The `buildPiece` function is the only required function for core piece creation. |
| Standard Parameters | `(component, options)`, where `options` is optional. |
| Standard minimum options | <ul><Li><code>remountable?: boolean</code></Li><Li><code>relocation?: 'supported' \| 'unsupported' \| Relocate</code></Li><Li><code>meta?: TMeta</code></Li></ul> |
| Optional `update` lifecycle | Produces pieces that can receive updated property values. |
| Optional `relocate` lifecycle | Produces pieces that can relocate their DOM trees without a mounting cycle. |
| Enforces `meta.remountable` | Makes sure the piece cannot be remounted whenever the `remountable` option is explicitly set to `false`. |
| Ensures `meta.remountable` | Ensures the property is defined and correctly set according to the framework's capabilities and user preference. |
| Ensures `meta.relocatable` | Ensures the property is defined and correctly set according to the framework's capabilities and user preference. |

### React

| Item | Compliance |
| - | - |
| Main function: `buildPiece` | <Compliance compliant /> |
| No additional required functions | <Compliance compliant /> |
| Standard parameters | <Compliance compliant /> |
| Standard minimum options | <Compliance compliant /> |
| Optional `update` lifecycle | <Compliance compliant /> |
| Optional `relocate` lifecycle | <Compliance compliant /> |
| Enforces `meta.remountable` | <Compliance compliant /> |
| Ensures `meta.remountable` | <Compliance compliant /> |
| Ensures `meta.relocatable` | <Compliance compliant /> |

### Svelte

| Item | Compliance |
| - | - |
| Main function: `buildPiece` | <Compliance compliant /> |
| No additional required functions | <Compliance compliant /> |
| Standard parameters | <Compliance compliant /> |
| Standard minimum options | <Compliance compliant /> |
| Optional `update` lifecycle | <Compliance compliant /> |
| Optional `relocate` lifecycle | <Compliance compliant /> |
| Enforces `meta.remountable` | <Compliance compliant /> |
| Ensures `meta.remountable` | <Compliance compliant /> |
| Ensures `meta.relocatable` | <Compliance compliant /> |

### VueJS

| Item | Compliance |
| - | - |
| Main function: `buildPiece` | <Compliance compliant /> |
| No additional required functions | <Compliance compliant /> |
| Standard parameters | <Compliance compliant /> |
| Standard minimum options | <Compliance compliant /> |
| Optional `update` lifecycle | <Compliance compliant /> |
| Optional `relocate` lifecycle | <Compliance compliant /> |
| Enforces `meta.remountable` | <Compliance compliant /> |
| Ensures `meta.remountable` | <Compliance compliant /> |
| Ensures `meta.relocatable` | <Compliance compliant /> |

## Piece Mounting

These are the definitions of the standardizations for piece mounting:

| Item | Description |
| - | - |
| Main component: `Piece` | The `Piece` component is the one in charge of mounting core pieces. |
| No additional components | The `Piece` component is the only needed component for core piece mounting. |
| Property namespace belongs to core piece | Properties passed to `Piece` are all forwarded to the core piece. |
| `Piece` is configured via the `piece` function | The helper function `piece` is used to configure the `Piece` component. |
| `piece` standard parameters | `(corePiece, options)`, where `options` is optional. |
| `piece` standard minimum options | <ul><Li><code>shadow?: boolean \| ShadowRootInit</code></Li><Li><code>containerProps?: FrameworkSpecificType</code></Li><ul> |
| Updates reactively | The `Piece` component is capable of transmit updated properties to the core piece. |
| Relocates when appropriate | Calls the core piece's <code>relocate</code> lifecycle whenever appropriate, for example whenever the <code>shadow</code> setting changes in runtime. |

### React

| Item | Compliance |
| - | - |
| Main component: `Piece` | <Compliance compliant /> |
| No additional components | <Compliance compliant /> |
| Property namespace belongs to core piece | <Compliance compliant /> |
| `Piece` is configured via the `piece` function | <Compliance compliant /> |
| `piece` standard parameters | <Compliance compliant /> |
| `piece` standard minimum options | <Compliance compliant /> |
| Updates reactively | <Compliance compliant /> |
| Relocates when appropriate | <Compliance compliant /> |

### Svelte

| Item | Compliance |
| - | - |
| Main component: `Piece` | <Compliance compliant /> |
| No additional components | <Compliance compliant /> |
| Property namespace belongs to core piece | <Compliance compliant /> |
| `Piece` is configured via the `piece` function | <Compliance compliant /> |
| `piece` standard parameters | <Compliance compliant /> |
| `piece` standard minimum options | <Compliance compliant /> |
| Updates reactively | <Compliance compliant /> |
| Relocates when appropriate | <Compliance compliant /> |

### VueJS

| Item | Compliance |
| - | - |
| Main component: `Piece` | <Compliance compliant /> |
| No additional components | <Compliance compliant /> |
| Property namespace belongs to core piece | <Compliance compliant={false} /> |
| `Piece` is configured via the `piece` function | <Compliance compliant={false} /> |
| `piece` standard parameters | <Compliance compliant={false} /> |
| `piece` standard minimum options | <Compliance compliant={null} /> |
| Updates reactively | <Compliance compliant /> |
| Relocates when appropriate | <Compliance compliant /> |
