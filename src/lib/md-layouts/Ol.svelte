<script lang="ts">
    import type { HTMLOlAttributes } from "svelte/elements";
    import { ListContext, setListContext } from "./list-context.svelte";

    let {
        children,
        ...restProps
    }: HTMLOlAttributes = $props();

    setListContext(new ListContext(true));
</script>

<ol {...restProps}>
    {@render children?.()}
</ol>
