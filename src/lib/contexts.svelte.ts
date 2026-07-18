import { createContext } from "svelte";

export class PaletteContext {
    value = $state<string>('');
}

export const [palette, setPalette] = createContext<PaletteContext>();
