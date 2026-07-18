import { createContext } from "svelte";
import type { ArticleNode } from "../../../types.js";

export class PrimarySidebarContext {
    value = $state<ArticleNode[]>([]);
}

export const [primarySidebar, setPrimarySidebar] = createContext<PrimarySidebarContext>();
