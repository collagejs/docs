---
  title: '@collagejs/vite-css'
  description: |
    API reference for the @collagejs/vite-css NPM package.
---

<script lang="ts">
    import type { PageProps } from './$types';
</script>

This NPM package configures a Vite project to export JavaScript objects (like a library or NPM package) and provides a virtual module capable of providing *CollageJS* lifecycle functions that can mount, in synchrony, any CSS assets needed in UI components.

We have 2 modules:

- The main module that exports the Vite plug-in factory
- The virtual `/ex` module that provides the CSS-mounting algorithm

## Main Module

### Functions

#### cjsCssPlugin

Builds the Vite-CSS plug-in that configures the project and injects the CSS algorithm, if used.

```typescript
function cjsCssPlugin(
  options: CollageJsCssPluginOptions,
  aimOptions?: CollageJsAimPluginOptions
): [Plugin, Plugin | null];
```

##### Options

| Option | Type | Default Value | Description |
| - | - | - | - |
| `serverPort` | `number` | | Fixes the project's server port (development and preview) to the specified value. |
| `input` | `string | string[]` | `'src/piece.ts'` | File or list of files to configure as entry modules. |
| `projectId` | `string` | `undefined` | Unique project identifier that is introduced in CSS file names to support the CSS algorithm.  When not defined, the project's name from `package.json` is used. |
| `assetFileNames` | `string` | `'assets/[name]-[hash][extname]'` | Asset file name pattern for bundled assets.  CSS file names will be of the form `'cjcss(<project id>)<pattern>'` as the plug-in must control the CSS file names to a minimum extent. |
| `aim` | `boolean` | `true` | Controls the inclusion of the *Vite-AIM* plug-in.  Turn this off if the project doesn't require knowledge of the import map configured in the root project. |

For the second set of options, refer to the [Vite-AIM](/api/packages/vite-aim) plug-in reference.

## Virtual `/ex` Module

### Classes

#### CssFactory

Class that provides instantiation of *CollageJS* lifecycle functions that synchronize mounting and dismounting of CSS stylesheets with the lifecycle of their corresponding core pieces.

- Best practice says the class is used in entry modules
- The module URL is used to determine:
    + The module's current base path; used to find CSS files by appending the bundled CSS file names (and directories)
    + The module's name; used to determine the correct set of CSs files to use
- A "fabricated" module URL is acceptable so long it works to determine the 2 pieces of information described in the previous point
- This is an optional algorithm; projects can opt out and not use it

##### constructor

Initializes a new instance of this class.

```typescript
constructor(moduleUrl: string, options?: CssFactoryOptions): CssFactory;
```

| Parameter | Description |
| - | - |
| `moduleUrl` | The ES module's URL, which is torn in 2:  The base path and the module's name.  The base path is used to locate CSS, making no use of Vite's `base` option. |
| `options` | Optional set of configuration values.  See next subsection. |

###### Options

| Option | Type | Default Value | Description |
| - | - | - | - |
| `loadTimeout` | `number` | `1_500` | Maximum time (in milliseconds) to wait for a CSS to be loaded by the web browser before giving up. |
| `failOnTimeout` | `boolean` | `false` | Controls what happens when a timeout occurs when loading a CSS file.  When `true`, an error is thrown. |
| `failOnError` | `boolean` | `false` | Controls what happens when an error occurs when loading a CSS file.  When `true`, an error is thrown. |

##### instantiate

Method that generates a `mount` and a `relocate` *CollageJS* lifecycle function.

- Always instantiate these functions as the related core piece object is instantiated
- Only use the `relocate` function if the piece itself supports relocation

```typescript
instantiate(): { mount: MountFn; relocate: RelocateFn; };
```

### Functions

#### configureLogger

Configures the logger object used to log CSS events and data.

- By default, logging is turned off.

```typescript
function configureLogger(option: boolean | ILogger): void;
```

| Parameter | Description |
| - | - |
| `option` | A Boolean value to indicate if the console should be used as logger, or a custom logger object. |

A custom logger object only needs to implement the same signature of the `console` object for `debug`, `info`, `warn` and `error`.

### Objects

#### viteEnv

A global object with Vite-related information.

| Property | Type | Description |
| - | - | - |
| `serving` | `boolean` | Indicates if the current code is running in Vite's development server. |
| `built` | `boolean` | Indicates if the current code is running from a built version of the project. |
| `mode` | `string` | The mode given to Vite when either starting the development server or when the project was built. |
