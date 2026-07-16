import { paletteCookie } from '$lib/cookies.js';
import type { LayoutServerLoad } from './$types';

export const load = (async ({ cookies }) => {
    const palette = cookies.get(paletteCookie) ?? 'accent';
    return {
        palette
    };
}) satisfies LayoutServerLoad;
