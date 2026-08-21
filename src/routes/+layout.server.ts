import { paletteCookie, renderAsListCookie } from '$lib/cookies.js';
import type { LayoutServerLoad } from './$types';

export const load = (async ({ cookies }) => {
    const palette = cookies.get(paletteCookie) ?? 'accent';
    const renderAsList = cookies.get(renderAsListCookie) === 'true';
    return {
        palette,
        renderAsList
    };
}) satisfies LayoutServerLoad;
