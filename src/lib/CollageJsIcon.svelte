<script lang="ts">
    import collageJsLogo16 from '@collagejs/core/logo/16';
    import collageJsLogo48 from '@collagejs/core/logo/48';
    import collageJsLogo64 from '@collagejs/core/logo/64';

    type Props = {
        logo?: 16 | 48 | 64;
        size?: string;
    };

    let {
        logo = 16,
        size = '1.1em'
    }: Props = $props();

    const logoMap = new Map<Props['logo'], string>([
        [16, collageJsLogo16],
        [48, collageJsLogo48],
        [64, collageJsLogo64]
    ]);

    const finalLogo = $derived(logoMap.get(logo))
</script>

<img
    src={finalLogo}
    alt="CollageJS"
    style="width: {size}; height: {size};"
/>
