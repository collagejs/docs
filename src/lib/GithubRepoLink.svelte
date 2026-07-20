<script lang="ts">
    import type { ComponentProps } from "svelte";
    import GithubIcon from "./GithubIcon.svelte";

    type Props = ComponentProps<typeof GithubIcon> & {
        name: string;
    };

    let {
        name,
        ...restProps
    }: Props = $props();
</script>

<a
    href={`https://github.com/collagejs/${name}`}
    target="_blank"
    rel="nofollow noreferrer"
    title={`View ${name} on GitHub`}
>
    <GithubIcon {...restProps} />
</a>
