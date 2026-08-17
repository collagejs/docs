---
  title: '@collagejs/importmap'
  description: |
    API reference for the @collagejs/importmap NPM package.
---

<script lang="ts">
    import type { PageProps } from './$types';
    import { Flag } from '@lucide/svelte';
</script>

This is a utility package that can validate and use import map objects for module resolution.  It can be used on its own, but its primary use is in [@collagejs/imo](/api/packages/imo) and [@collagejs/vite-aim](/api/packages/vite-aim).

## Classes

### Resolver

This class is not actually exported, but it's documented here as it is usable via the `resolver` function.

| Property | Type | Description |
| - | - | - |
| `valid` | `boolean` | Gets a Boolean value that indicates if the currently-held import map is valid.  This is a shortcut for `validationResult.valid`|
| `validationResult` | `ValidationResult` | The validation result object obtained for the currently-held import map. |

#### resolve

```typescript
resolve(specifier: string, importer?: string | undefined): string | undefined;
```

Resolves a module specifier using the contained import map.

| Parameter | Description |
| - | - |
| `specifier` | Module specifier to resolve. |
| `importer` | Module specifier of the module importing the one specified for `specifier`. |

##### Return Value

The value specified in the import map if the module specifier was found; `undefined` if it wasn't found and `specifier` was a bare module specifier, or `specifier` when no match was found but it was a relative, absolute or full URL.

> **<Flag /> Special Case**
> 
> If `specifier` is a relative URL and `importer` is a URL and no match was found, the returned value will be a "resolved" URL.  Example: `"../module"` imported by `"/my/app"`.  If the import map cannot resolve, then the returned value will be `"/my/module"`.

### ValidationResult

This class is not actually exported, but is the return value of the [validate](#validate) function and therefore, we document it here.

| Property | Type | Description |
| - | - | - |
| `valid` | `boolean` | Gets a BOolean value that indicates if the validated import map turned out to be valid or not. |
| `errors` | `string[]` | Gets the collection of validation error messages collected during the validation process. |

#### addError

Adds an error to the collection of errors and makes sure the `valid` property is set to `false`.

```typescript
addError(error: string): void;
```

| Parameter | Description |
| - | - |
| `error` | Error message to append to the collection of errors. |

## Functions

### resolver

Creates an import map resolver object out of the provided import map object.  The import map is validated on construction and the result of the validation is exposed via the `valid` and `validationResult` properties.

- Validation cannot be skipped.
- Module resolution will throw an error if the import map is deemed as invalid.

```typescript
function resolver(importMap: ImportMap): Resolver;
```

| Parameter | Description |
| - | - |
| `importMap` | The import map object that will be used to resolve module specifiers. |

#### Return Value

A newly created `Resolver` object.

### validate

Validates an import map object according to the Import Maps specification and several additional security checks.

```typescript
function validate(importMap: ImportMap): ValidationResult;
```

| Parameter | Description |
| - | - |
| `importMap` | Import map object to validate. |

#### Return Value

An object of type `ValidationResult` with the `valid` and `errors` properties that detail the result of the validation process.

#### Validations

- The import map must be a plain POJO.
- The `imports` value must be a plain POJO.
- The `scopes` value must be a plain POJO, if it exists.
- Every defined object inside `scopes` must be a plain POJO.
- Scope prefixes cannot be an empty string.
- If the scope prefix contains a protocol, it must be a valid URL.
- The `integrity` value must be a plain POJO, if it exists.
- The import map cannot have any unknown top-level properties.
- Module specifiers and their values must be strings.
- Values must not contain Unicode characters considered dangerous:
    + Invisible/zero-width characters
    + Characters used in bidirectional text attacks
    + Characters commonly used in homograph attacks
- Entries must be consistent when ending in slash (module specifier and resolved value must match)
- Integrity values cannot be empty.
- Integrity values must be valid integrity values (i. e. start with the algorithm, etc.).
