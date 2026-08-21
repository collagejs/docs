import { describe, it, expect } from 'vitest';
import { cookieBannerDismissalKey, dismissCookieBanner, hasCookieBannerBeenDismissed } from './cookies.js';

describe('Cookie Banner Dismissal Helpers', () => {
	it('Should return false when the banner has not been dismissed.', () => {
		const storage = {
			getItem: () => null,
			setItem: () => undefined,
		};

		expect(hasCookieBannerBeenDismissed(storage)).toBe(false);
	});

	it('Should return true when the dismissal value is set to ok.', () => {
		const storage = {
			getItem: (key: string) => (key === cookieBannerDismissalKey ? 'ok' : null),
			setItem: () => undefined,
		};

		expect(hasCookieBannerBeenDismissed(storage)).toBe(true);
	});

	it('Should store the ok dismissal value in storage.', () => {
		let storedValue: string | null = null;
		const storage = {
			getItem: () => storedValue,
			setItem: (_key: string, value: string) => {
				storedValue = value;
			},
		};

		dismissCookieBanner(storage);

		expect(storedValue).toBe('ok');
	});
});
