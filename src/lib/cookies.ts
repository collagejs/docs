export const paletteCookie = 'palette';
export const renderAsListCookie = 'render-as-list';
export const cookieBannerDismissalKey = 'cookie-banner-dismissed';

export function hasCookieBannerBeenDismissed(storage: Pick<Storage, 'getItem'> | null = null) {
	const targetStorage = storage ?? (typeof window === 'undefined' ? null : window.localStorage);
	return targetStorage?.getItem(cookieBannerDismissalKey)?.toLowerCase() === 'ok';
}

export function dismissCookieBanner(storage: Pick<Storage, 'setItem'> | null = null): void {
	const targetStorage = storage ?? (typeof window === 'undefined' ? null : window.localStorage);
	targetStorage?.setItem(cookieBannerDismissalKey, 'ok');
}
