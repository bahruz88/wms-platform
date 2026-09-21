#!/usr/bin/env node
/**
 * gen-api.mjs — contracts/openapi/<module>.v1.yaml → src/api/generated/<module>.ts
 *
 * Mirrors scripts/gen-client.sh on the Dart side: the same nine specs, one output per module,
 * output git-ignored, regenerated on demand. `openapi-typescript` emits only types (`paths`,
 * `components`); the calls themselves go through `openapi-fetch` in src/api/client.ts.
 *
 * Usage:
 *   npm run gen:api                       # all modules
 *   npm run gen:api -- inventory identity # selected modules
 */
import { mkdirSync, writeFileSync, readdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';
import openapiTS, { astToString } from 'openapi-typescript';

const here = dirname(fileURLToPath(import.meta.url));
const SPEC_DIR = resolve(here, '../../contracts/openapi');
const OUT_DIR = resolve(here, '../src/api/generated');

const ALL_MODULES = [
  'common',
  'identity',
  'masterdata',
  'inventory',
  'procurement',
  'documents',
  'notifications',
  'consumption',
  'reporting',
];

const selected = process.argv.slice(2).filter((a) => !a.startsWith('-'));
const modules = selected.length > 0 ? selected : ALL_MODULES;

const known = new Set(
  readdirSync(SPEC_DIR)
    .filter((f) => f.endsWith('.v1.yaml'))
    .map((f) => f.replace('.v1.yaml', '')),
);

mkdirSync(OUT_DIR, { recursive: true });

const banner = (module) => `/**
 * GENERATED FILE — do not edit.
 * Source: contracts/openapi/${module}.v1.yaml
 * Regenerate: npm run gen:api
 *
 * Every quantity / money / rate / percent field is \`string\` on purpose
 * (common.v1.yaml#/components/schemas/Decimal, ADR-008). Parse with decimal.js
 * through src/core/decimal.ts — never with Number() or parseFloat().
 */
`;

let failed = false;

for (const module of modules) {
  if (!known.has(module)) {
    console.error(`error: unknown module "${module}" (known: ${[...known].sort().join(', ')})`);
    failed = true;
    continue;
  }
  const spec = resolve(SPEC_DIR, `${module}.v1.yaml`);
  const target = resolve(OUT_DIR, `${module}.ts`);
  try {
    const ast = await openapiTS(new URL(`file://${spec}`), {
      alphabetize: true,
      emptyObjectsUnknown: true,
      defaultNonNullable: false,
      excludeDeprecated: false,
    });
    writeFileSync(target, banner(module) + astToString(ast), 'utf8');
    console.log(`==> ${module}.v1.yaml  ->  src/api/generated/${module}.ts`);
  } catch (error) {
    console.error(`error: generation failed for ${module}: ${error.message}`);
    failed = true;
  }
}

if (failed) process.exit(1);

console.log(`
Post-generation notes:
  1. DECIMALS ARE STRINGS ON PURPOSE. Wrap them in Quantity / Money (src/core/decimal.ts).
     The ESLint rule wms/no-number-for-decimal fails the build if one is typed as number.
  2. Generated sources are git-ignored; see src/api/generated/README.md.
  3. The typed wrapper (bearer token, Idempotency-Key, problem+json) lives in src/api/client.ts.`);
