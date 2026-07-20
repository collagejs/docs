import { createContext } from "svelte";

export class ScrollDocContext {
    value = $state<boolean>(true);
}

export const [scrollDoc, setScrollDoc] = createContext<ScrollDocContext>();
