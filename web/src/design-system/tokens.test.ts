import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';
import { expectedCss, generate, readTokens } from '../../scripts/gen-tokens.mjs';

const TOKENS_CSS = resolve(__dirname, 'tokens.css');
const BUNDLE_CSS = resolve(__dirname, 'bundle.css');
const SOURCE_BUNDLE = resolve(__dirname, '../../../docs/design-system/components/bundle.css');

/**
 * tokens.css is generated from docs/design-system/tokens.json and must never be edited by hand.
 * This test is what stops the two from drifting: if someone changes the JSON without running
 * `npm run gen:tokens`, or edits the CSS directly, the suite fails.
 */
describe('generated tokens.css', () => {
  it('is up to date with docs/design-system/tokens.json', () => {
    const onDisk = readFileSync(TOKENS_CSS, 'utf8');
    expect(onDisk).toBe(expectedCss());
  });

  it('declares every colour token from the source, for both themes', () => {
    const tokens = readTokens();
    const css = readFileSync(TOKENS_CSS, 'utf8');
    expect(tokens.color.tokens.length).toBe(29);
    for (const token of tokens.color.tokens) {
      // once on :root, once under prefers-color-scheme, once per explicit [data-theme]
      const occurrences = css.split(`--${token.name}:`).length - 1;
      expect(occurrences, token.name).toBe(4);
    }
  });

  it('copies token values literally, never approximates them', () => {
    const css = readFileSync(TOKENS_CSS, 'utf8');
    expect(css).toContain('--accent: #1a5fd0;');
    expect(css).toContain('--accent: #4c8dff;');
    expect(css).toContain('--border-control: #7f878f;');
    expect(css).toContain('--scrim: rgba(15,18,20,0.55);');
  });

  it('resolves the ledger aliases to the tokens they point at', () => {
    const css = readFileSync(TOKENS_CSS, 'utf8');
    // ledger-in = {success}, ledger-out = {danger} — in both themes.
    expect(css).toContain('--ledger-in: #146c43;');
    expect(css).toContain('--ledger-out: #b3261e;');
    expect(css).toContain('--ledger-in: #3fb27f;');
    expect(css).toContain('--ledger-out: #ff6b5e;');
  });

  it('emits all 11 text styles and the spacing, radius, shadow and opacity scales', () => {
    const tokens = readTokens();
    const css = readFileSync(TOKENS_CSS, 'utf8');
    const styles = tokens.type.groups.flatMap((g) => g.styles);
    expect(styles.length).toBe(11);
    for (const style of styles) expect(css).toContain(`.wms-type-${style.name} {`);
    for (const t of tokens.spacing.tokens) expect(css).toContain(`--${t.name}: ${t.value};`);
    for (const t of tokens.radius.tokens) expect(css).toContain(`--${t.name}: ${t.value};`);
    for (const t of tokens.opacity.tokens) expect(css).toContain(`--${t.name}: ${t.value};`);
    for (const t of tokens.shadow.tokens) expect(css).toContain(`--${t.name}: ${t.value.light};`);
  });

  it('lets an explicit theme choice win over prefers-color-scheme in both directions', () => {
    const css = readFileSync(TOKENS_CSS, 'utf8');
    expect(css).toContain(":root:not([data-theme='light'])");
    expect(css).toContain(":root[data-theme='dark']");
    expect(css).toContain(":root[data-theme='light']");
  });

  it('regenerates deterministically', () => {
    expect(generate(readTokens())).toBe(generate(readTokens()));
  });
});

/**
 * bundle.css is copied in verbatim, not rewritten (ADR-013). If the design system ships a new
 * bundle, this test fails until the copy is refreshed.
 */
describe('bundle.css', () => {
  it('is byte-identical to docs/design-system/components/bundle.css', () => {
    expect(readFileSync(BUNDLE_CSS, 'utf8')).toBe(readFileSync(SOURCE_BUNDLE, 'utf8'));
  });
});
