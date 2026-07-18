import { createContext } from "svelte";

export class ListContext {
    value = $state(false);
    constructor(initial: boolean = false) {
        this.value = initial;
    }
}

export const [listContext, setListContext] = createContext<ListContext>();
