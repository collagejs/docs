<script lang="ts">
    type Props = {
        size?: string;
    };

    let {
        size = '1.1em'
    }: Props = $props();
</script>

<img
    src="https://github.githubassets.com/favicons/favicon-dark.svg"
    alt="github"
    style="width: {size}; height: {size};"
/>
