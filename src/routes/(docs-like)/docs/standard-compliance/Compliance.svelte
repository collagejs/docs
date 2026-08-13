<script lang="ts">
    import { CircleCheckBig, CircleMinus, CircleSlash2,  } from '@lucide/svelte';

    type Props = {
        compliant: boolean | null;
    };

    let {
        compliant,
    }: Props = $props();

    const Icon = $derived(compliant === true ? CircleCheckBig : compliant === false ? CircleSlash2 : CircleMinus);
    const label = $derived(compliant === true ? 'Compliant' : compliant === false ? 'Non-compliant' : 'Partially compliant');
</script>

<span
    title={label}
    class:compliant={compliant === true}
    class:non-compliant={compliant === false}
    class:partially-compliant={compliant === null}
>
    <Icon />
</span>

<style>
    .compliant {
        color: var(--cjs-success);
    }
    .non-compliant {
        color: var(--cjs-error);
    }
    .partially-compliant {
        color: var(--cjs-warning);
    }
</style>
