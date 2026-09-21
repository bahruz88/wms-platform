import { describe, expect, it } from 'vitest';
import { Decimal, Money, Quantity, sumDecimals } from './decimal';

/**
 * ADR-008: every quantity and amount arrives as a JSON string and must stay exact. These tests
 * pin the behaviour a `number` would break.
 */
describe('Quantity', () => {
  it('parses a contract decimal string exactly', () => {
    expect(Quantity.parse('2826.0870').toContract(4)).toBe('2826.0870');
  });

  it('adds without float drift', () => {
    const a = Quantity.parse('0.1');
    const b = Quantity.parse('0.2');
    expect(a.plus(b).toContract(4)).toBe('0.3000');
    // The float path this exists to avoid:
    expect(0.1 + 0.2).not.toBe(0.3);
  });

  it('keeps 8-decimal conversion factors intact', () => {
    const qty = Quantity.parse('8');
    expect(qty.times('0.08333333').toContract(8)).toBe('0.66666664');
  });

  it('carries its unit of measure', () => {
    const qty = Quantity.parse('12.5', 3, 'KG');
    expect(qty.uomId).toBe(3);
    expect(qty.uomCode).toBe('KG');
    expect(qty.withUom(4, 'G').uomCode).toBe('G');
  });

  it('reports sign and zero without rounding to a float', () => {
    expect(Quantity.parse('-0.00000001').isNegative()).toBe(true);
    expect(Quantity.parse('0.0000').isZero()).toBe(true);
    expect(Quantity.parse('0').isPositive()).toBe(false);
  });

  it('refuses a non-decimal string', () => {
    expect(() => Quantity.parse('abc')).toThrow();
  });

  it('maps a nullable field to null rather than to zero', () => {
    expect(Quantity.parseOrNull(null)).toBeNull();
    expect(Quantity.parseOrNull('')).toBeNull();
    expect(Quantity.parseOrNull('0')?.isZero()).toBe(true);
  });
});

describe('Money', () => {
  it('refuses arithmetic across currencies — conversion needs the frozen fxRate', () => {
    const azn = Money.parse('100', 'AZN');
    const usd = Money.parse('100', 'USD');
    expect(() => azn.plus(usd)).toThrow(/currency mismatch/);
  });

  it('converts with an explicit rate', () => {
    const usd = Money.parse('100', 'USD');
    const azn = usd.convert('1.70000000', 'AZN');
    expect(azn.currency).toBe('AZN');
    expect(azn.toContract(4)).toBe('170.0000');
  });

  it('adds in the same currency exactly', () => {
    const total = Money.parse('6.5217', 'AZN')
      .plus(Money.parse('142.5000', 'AZN'))
      .plus(Money.parse('45.0000', 'AZN'));
    expect(total.toContract(4)).toBe('194.0217');
  });
});

describe('sumDecimals', () => {
  it('sums a ledger group to exactly zero', () => {
    const lines = ['-2173.9130', '2173.9130', '-15000.0000', '15000.0000'];
    expect(sumDecimals(lines).isZero()).toBe(true);
  });

  it('keeps a non-zero group non-zero at the fourth decimal', () => {
    expect(sumDecimals(['1.0000', '-0.9999']).equals(new Decimal('0.0001'))).toBe(true);
  });
});
