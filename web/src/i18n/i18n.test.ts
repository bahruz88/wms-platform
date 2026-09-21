import { describe, expect, it } from 'vitest';
import az from './locales/az.json';
import en from './locales/en.json';
import ru from './locales/ru.json';
import i18n, { LANGUAGE_NAMES, SUPPORTED_LANGUAGES, setLanguage } from './index';

type Tree = Record<string, unknown>;

function flatten(tree: Tree, prefix = ''): string[] {
  return Object.entries(tree).flatMap(([key, value]) =>
    typeof value === 'object' && value !== null
      ? flatten(value as Tree, `${prefix}${key}.`)
      : [`${prefix}${key}`],
  );
}

function values(tree: Tree): string[] {
  return Object.values(tree).flatMap((value) =>
    typeof value === 'object' && value !== null ? values(value as Tree) : [String(value)],
  );
}

describe('i18n', () => {
  it('offers az, en and ru, with az the default', () => {
    expect(SUPPORTED_LANGUAGES).toEqual(['az', 'en', 'ru']);
    expect(i18n.options.fallbackLng).toEqual(['az']);
    expect(Object.keys(LANGUAGE_NAMES)).toEqual(['az', 'en', 'ru']);
  });

  it('keeps the three bundles in step — a missing key would silently fall back', () => {
    const azKeys = flatten(az).sort();
    expect(flatten(en).sort()).toEqual(azKeys);
    expect(flatten(ru).sort()).toEqual(azKeys);
    expect(azKeys.length).toBeGreaterThan(50);
  });

  it('never ships an all-caps string — `i` uppercases to `I`, which is wrong in Azerbaijani', () => {
    const shouting = values(az).filter(
      (text) => text.length > 3 && text === text.toLocaleUpperCase('az') && /\p{L}/u.test(text),
    );
    expect(shouting).toEqual([]);
  });

  it('uses no emoji anywhere in the interface strings', () => {
    const emoji = /\p{Extended_Pictographic}/u;
    expect(values(az).filter((t) => emoji.test(t))).toEqual([]);
    expect(values(en).filter((t) => emoji.test(t))).toEqual([]);
    expect(values(ru).filter((t) => emoji.test(t))).toEqual([]);
  });

  it('translates through the active language and back', async () => {
    await i18n.changeLanguage('az');
    expect(i18n.t('nav.balances')).toBe('Qalıq');
    setLanguage('en');
    await i18n.changeLanguage('en');
    expect(i18n.t('nav.balances')).toBe('Balances');
    setLanguage('az');
    await i18n.changeLanguage('az');
    expect(i18n.t('nav.balances')).toBe('Qalıq');
  });

  it('interpolates the gateway status into the not-implemented message', async () => {
    await i18n.changeLanguage('az');
    expect(i18n.t('state.notImplementedBody', { status: 404 })).toContain('404');
  });
});
