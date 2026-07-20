<script lang="ts">
    import type { ComponentProps } from "svelte";
    import NpmJsIcon from "./NpmJsIcon.svelte";

    type Props = ComponentProps<typeof NpmJsIcon> & {
        name: string;
    };

    let {
        name,
        ...restProps
    }: Props = $props();
</script>

<a
    href={`https://npmjs.com/package/${name}`}
    target="_blank"
    rel="nofollow noreferrer"
    title={`View ${name} on npmjs.com`}
>
    <NpmJsIcon {...restProps} />
</a>
