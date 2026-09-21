#!/usr/bin/env node
/**
 * gen-tokens.mjs — docs/design-system/tokens.json → src/design-system/tokens.css
 *
 * Token values are copied literally, never guessed (docs/CONVENTIONS.md, "Dizayn sistemi").
 * The generated file declares every colour token twice — once on `:root` (light) and once for
 * dark, resolved both by `prefers-color-scheme` and by an explicit `[data-theme]` attribute so a
 * user override always wins. Type, spacing, radius, shadow and opacity scales follow.
 *
 * Usage:
 *   node scripts/gen-tokens.mjs            # write src/design-system/tokens.css
 *   node scripts/gen-tokens.mjs --check    # exit 1 if the file on disk is stale
 */
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const SOURCE = resolve(here, '../../docs/design-system/tokens.json');
const TARGET = resolve(here, '../src/design-system/tokens.css');

/** Resolves `{success}` style aliases against the same theme. */
function resolveAlias(value, theme, tokens) {
  const match = /^\{([a-z0-9-]+)\}$/i.exec(value);
  if (!match) return value;
  const target = tokens.find((t) => t.name === match[1]);
  if (!target) throw new Error(`tokens.json: alias {${match[1]}} has no matching token`);
  return resolveAlias(target.value[theme], theme, tokens);
}

export function generate(tokensJson) {
  const colour = tokensJson.color.tokens;
  const themes = tokensJson.color.themes.map((t) => t.id);

  const colourBlock = (theme, indent) =>
    colour
      .map((t) => `${indent}--${t.name}: ${resolveAlias(t.value[theme], theme, colour)};`)
      .join('\n');

  const families = Object.entries(tokensJson.type.families)
    .map(([name, value]) => `  --font-${name}: ${value};`)
    .join('\n');

  const typeStyles = tokensJson.type.groups
    .flatMap((group) =>
      group.styles.map((style) => {
        const family = `var(--font-${group.family})`;
        const parts = [
          `.wms-type-${style.name} {`,
          `  font-family: ${family};`,
          `  font-size: ${style.fontSize};`,
          `  line-height: ${style.lineHeight};`,
          `  font-weight: ${style.fontWeight};`,
        ];
        if (style.letterSpacing) parts.push(`  letter-spacing: ${style.letterSpacing};`);
        if (group.family === 'mono') {
          parts.push('  font-variant-numeric: tabular-nums;');
          parts.push('  font-feature-settings: "tnum" 1;');
        }
        parts.push('}');
        return parts.join('\n');
      }),
    )
    .join('\n\n');

  const scale = (section) =>
    tokensJson[section].tokens.map((t) => `  --${t.name}: ${t.value};`).join('\n');

  const shadowBlock = (theme, indent) =>
    tokensJson.shadow.tokens.map((t) => `${indent}--${t.name}: ${t.value[theme]};`).join('\n');

  const [light, dark] = themes;

  return `/* GENERATED FILE — do not edit.
 * Source: docs/design-system/tokens.json (${tokensJson.name}, version ${tokensJson.version})
 * Regenerate: npm run gen:tokens   ·   Check: node scripts/gen-tokens.mjs --check
 */

:root {
  color-scheme: light dark;

${colourBlock(light, '  ')}

${families}

${scale('spacing')}

${scale('radius')}

${shadowBlock(light, '  ')}

${scale('opacity')}
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme='${light}']) {
${colourBlock(dark, '    ')}

${shadowBlock(dark, '    ')}
  }
}

:root[data-theme='${dark}'] {
${colourBlock(dark, '  ')}

${shadowBlock(dark, '  ')}
}

:root[data-theme='${light}'] {
${colourBlock(light, '  ')}

${shadowBlock(light, '  ')}
}

${typeStyles}
`;
}

export function readTokens() {
  return JSON.parse(readFileSync(SOURCE, 'utf8'));
}

export function expectedCss() {
  return generate(readTokens());
}

export function currentCss() {
  return existsSync(TARGET) ? readFileSync(TARGET, 'utf8') : '';
}

const isMain = process.argv[1] && resolve(process.argv[1]) === resolve(fileURLToPath(import.meta.url));
if (isMain) {
  const css = expectedCss();
  if (process.argv.includes('--check')) {
    if (currentCss() !== css) {
      console.error('tokens.css is stale — run `npm run gen:tokens`.');
      process.exit(1);
    }
    console.log('tokens.css is up to date.');
  } else {
    writeFileSync(TARGET, css, 'utf8');
    const count = readTokens().color.tokens.length;
    console.log(`tokens.css written (${count} colour tokens, light + dark).`);
  }
}
