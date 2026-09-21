import { RuleTester } from 'eslint';
import tsParser from '@typescript-eslint/parser';
import { describe, it } from 'vitest';
// @ts-expect-error -- the rule is plain ESM JavaScript with no type declarations.
import rule, { isDecimalFieldName } from '../no-number-for-decimal.mjs';
import { expect } from 'vitest';

/**
 * ADR-008 is enforced by lint, not only by convention. This proves the rule actually fires on the
 * shapes it is meant to catch, and stays quiet on counters and identifiers.
 */
const ruleTester = new RuleTester({
  languageOptions: { parser: tsParser, ecmaVersion: 2022, sourceType: 'module' },
});

describe('wms/no-number-for-decimal', () => {
  it('flags number-typed decimal fields and allows the rest', () => {
    ruleTester.run('no-number-for-decimal', rule, {
      valid: [
        'interface Line { qty: string }',
        'interface Line { unitPrice: DecimalString }',
        'interface Line { totalValue: Money }',
        'interface Page { total: number }',
        'interface Doc { lineCount: number }',
        'interface Cfg { rateLimit: number }',
        'interface Row { variancePct: number }',
        'interface Row { daysToExpiry: number }',
        'interface Row { priceListId: number }',
        'class Row { readonly qty: string = "0" }',
      ],
      invalid: [
        { code: 'interface Line { qty: number }', errors: [{ messageId: 'numberDecimal' }] },
        { code: 'interface Line { qtyBase: number }', errors: [{ messageId: 'numberDecimal' }] },
        { code: 'interface Line { unitPrice: number }', errors: [{ messageId: 'numberDecimal' }] },
        { code: 'interface Line { totalAmount: number }', errors: [{ messageId: 'numberDecimal' }] },
        { code: 'interface Line { avgUnitCost: number }', errors: [{ messageId: 'numberDecimal' }] },
        { code: 'interface Line { totalValue: number }', errors: [{ messageId: 'numberDecimal' }] },
        { code: 'interface Line { fxRate: number }', errors: [{ messageId: 'numberDecimal' }] },
        { code: 'interface Line { unit_price: number }', errors: [{ messageId: 'numberDecimal' }] },
        // unions and arrays hide a number just as well
        { code: 'interface Line { qty: string | number }', errors: [{ messageId: 'numberDecimal' }] },
        { code: 'interface Line { amounts: number[] }', errors: [{ messageId: 'numberDecimal' }] },
        { code: 'class Row { subtotal: number = 0 }', errors: [{ messageId: 'numberDecimal' }] },
      ],
    });
  });

  it('classifies field names by word token, not by substring', () => {
    expect(isDecimalFieldName('qtyOnHand')).toBe(true);
    expect(isDecimalFieldName('unitPrice')).toBe(true);
    expect(isDecimalFieldName('varianceValue')).toBe(true);
    expect(isDecimalFieldName('total')).toBe(false);
    expect(isDecimalFieldName('lineCount')).toBe(false);
    expect(isDecimalFieldName('rateLimit')).toBe(false);
    expect(isDecimalFieldName('value')).toBe(false);
  });
});
