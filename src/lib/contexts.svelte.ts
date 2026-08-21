import { createContext } from "svelte";

export class PaletteContext {
    value;

    constructor(value: string = '') {
        this.value = $state<string>(value);
    }
}

export const [palette, setPalette] = createContext<PaletteContext>();

export class RenderAsListContext {
    value;

    constructor(value: boolean = false) {
        this.value = $state<boolean>(value);
    }
}

export const [renderAsList, setRenderAsList] = createContext<RenderAsListContext>();
