<script lang="ts">
    type Props = {
        size?: string;
    };

    let {
        size = '1.1em'
    }: Props = $props();
</script>

<img
    src="https://static-production.npmjs.com/da3ab40fb0861d15c83854c29f5f2962.png"
    alt="npmjs"
    style="width: {size}; height: {size};"
/>
