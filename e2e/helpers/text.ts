import type { Locator, Page } from '@playwright/test';

/**
 * The brand book's typographic rules, asserted mechanically — docs/design-system/README.md.
 *
 * These are not style preferences; each one is a bug the product has already had:
 *   · `text-transform: uppercase` / `toUpperCase()` turns Azerbaijani `i` into `I` instead of `İ`;
 *   · the decimal separator is a comma and the thousands separator is U+202F (narrow no-break
 *     space), so a ledger column lines up;
 *   · the minus sign is U+2212, not the hyphen-minus U+002D;
 *   · emoji are not used anywhere in the interface.
 */

export const NARROW_NBSP = ' ';
export const MINUS = '−';

/** Emoji and pictographs. Excludes the arrows and box characters the interface legitimately uses. */
const EMOJI = /[\u{1F000}-\u{1FAFF}\u{1F300}-\u{1F5FF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{FE0F}]/u;

export function findEmoji(text: string): string[] {
  return [...text].filter((ch) => EMOJI.test(ch));
}

/**
 * Words that betray an uppercasing artefact in Azerbaijani text.
 *
 * `toUpperCase()` (and `text-transform: uppercase`) map `i` → `I`; the correct Azerbaijani
 * upper case of `i` is `İ`. So the fingerprint of a wrongly-uppercased Azerbaijani word is an
 * all-caps run holding an Azerbaijani-specific letter (`Ə Ğ Ö Ş Ü Ç`) **and** a bare `I`:
 * «TƏSDIQLƏ» where «TƏSDİQLƏ» was meant.
 *
 * The rule deliberately does not fire on a machine constant the product prints verbatim —
 * `ADMIN`, `RECEIPT`, `LOCATION_FROZEN`, a SKU such as `TRIM`. Those are values, not prose, and
 * the brand book forbids uppercasing *prose*. The prose rule itself — no `text-transform:
 * uppercase` anywhere — is asserted straight from the computed style in `11-brand-book.spec.ts`,
 * which needs no heuristic at all.
 */
const AZ_SPECIFIC_UPPER = /[ƏĞÖŞÜÇ]/u;

export function uppercaseArtefacts(text: string): string[] {
  const words = text.split(/[\s.,;:()«»"'`/·\u202F\u00A0]+/).filter(Boolean);
  return words.filter((word) => {
    const stripped = word.replace(/[^\p{L}\p{N}_-]/gu, '');
    if (stripped.length < 4) return false;
    if (!AZ_SPECIFIC_UPPER.test(stripped)) return false;
    if (!stripped.includes('I')) return false;
    const letters = [...stripped].filter((c) => /\p{L}/u.test(c));
    if (letters.length < 4) return false;
    return letters.every(
      (c) => c === c.toLocaleUpperCase('az') && c !== c.toLocaleLowerCase('az'),
    );
  });
}

/** Numbers the interface rendered: `1 284,5000`, `−23,5000`, `0,00`. */
export function extractRenderedNumbers(text: string): string[] {
  const pattern = new RegExp(`[${MINUS}\\-+]?\\d[\\d${NARROW_NBSP} ]*(?:[.,]\\d+)?`, 'gu');
  return text.match(pattern) ?? [];
}

/** A quantity/figure cell must use a comma, never a dot, as the decimal separator. */
export function dottedDecimals(text: string): string[] {
  return (text.match(/(?<![\d.])\d+\.\d+(?![\d.])/g) ?? []).filter(
    // ISO dates and version strings are not quantities.
    (n) => !/^\d{4}\.\d{2}$/.test(n),
  );
}

/** A rendered negative figure must carry U+2212, not the ASCII hyphen. */
export function asciiMinusFigures(text: string): string[] {
  return text.match(/(?<![\w-])-\d+[,.]\d+/g) ?? [];
}

/** All visible text of a page or a locator subtree — the separators matter, so no normalising. */
export async function visibleText(target: Page | Locator): Promise<string> {
  const locator = 'goto' in target ? (target as Page).locator('body') : (target as Locator);
  return locator.innerText();
}
