import { describe, expect, it } from 'vitest';
import {
  MINUS_SIGN,
  NARROW_NBSP,
  compareBySortKey,
  daysUntil,
  formatCount,
  formatDate,
  formatDateTime,
  formatMoney,
  formatNumber,
  formatPercent,
  formatQuantity,
  formatSigned,
} from './format';
import { Money, Quantity } from './decimal';

/**
 * The brand book fixes these exactly (docs/design-system/README.md, "Dil və mətn"):
 * comma decimal separator, U+202F thousands separator, U+2212 minus, dd.MM.yyyy dates.
 */
describe('formatNumber', () => {
  it('uses a comma decimal separator', () => {
    expect(formatNumber('12.5', 4)).toBe('12,5000');
  });

  it('groups thousands with a narrow no-break space (U+202F), not a plain space', () => {
    expect(formatNumber('1284.5', 4)).toBe(`1${NARROW_NBSP}284,5000`);
    expect(formatNumber('1284.5', 4)).not.toContain(' ');
  });

  it('groups every three digits', () => {
    expect(formatNumber('1234567.89', 2)).toBe(`1${NARROW_NBSP}234${NARROW_NBSP}567,89`);
  });

  it('uses the minus sign U+2212, never the hyphen-minus U+002D', () => {
    const result = formatNumber('-23.5', 4);
    expect(result).toBe(`${MINUS_SIGN}23,5000`);
    expect(result.startsWith('-')).toBe(false);
    expect(result.charCodeAt(0)).toBe(0x2212);
  });

  it('keeps the declared scale without truncating', () => {
    expect(formatNumber('2826.087', 4)).toBe(`2${NARROW_NBSP}826,0870`);
    expect(formatNumber('0.08333333', 8)).toBe('0,08333333');
  });

  it('does not go through a float: 0.1 + 0.2 stays exact', () => {
    expect(formatNumber('0.30000000000000004', 2)).toBe('0,30');
    expect(formatNumber('12345678901234567.8901', 4)).toBe(
      `12${NARROW_NBSP}345${NARROW_NBSP}678${NARROW_NBSP}901${NARROW_NBSP}234${NARROW_NBSP}567,8901`,
    );
  });

  it('renders an em dash for a missing value', () => {
    expect(formatNumber(null)).toBe('—');
    expect(formatNumber(undefined)).toBe('—');
    expect(formatNumber('')).toBe('—');
  });

  it('renders zero with the requested scale and no sign', () => {
    expect(formatNumber('0', 4)).toBe('0,0000');
    expect(formatNumber('-0.0000', 4)).toBe('0,0000');
  });
});

describe('formatSigned', () => {
  it('always shows the sign for a non-zero value', () => {
    expect(formatSigned('12', 4)).toBe('+12,0000');
    expect(formatSigned('-12', 4)).toBe(`${MINUS_SIGN}12,0000`);
  });

  it('leaves zero unsigned — in a count, zero is the expected result', () => {
    expect(formatSigned('0', 4)).toBe('0,0000');
  });

  it('signs grouped figures', () => {
    expect(formatSigned('-2600', 3)).toBe(`${MINUS_SIGN}2${NARROW_NBSP}600,000`);
  });
});

describe('formatPercent / formatMoney / formatQuantity', () => {
  it('appends the percent sign', () => {
    expect(formatPercent('18.0000', 2)).toBe('18,00 %');
  });

  it('prints money with a narrow space before the currency code', () => {
    expect(formatMoney(Money.parse('1284.5', 'AZN'), 2)).toBe(
      `1${NARROW_NBSP}284,50${NARROW_NBSP}AZN`,
    );
  });

  it('prints a quantity with its unit, and without one when the unit is unknown', () => {
    expect(formatQuantity(Quantity.parse('12.5', 1, 'KG'), 4)).toBe(`12,5000${NARROW_NBSP}KG`);
    expect(formatQuantity(Quantity.parse('12.5'), 4)).toBe('12,5000');
    expect(formatQuantity(null)).toBe('—');
  });
});

describe('dates', () => {
  it('formats an ISO date as dd.MM.yyyy', () => {
    expect(formatDate('2026-09-20')).toBe('20.09.2026');
  });

  it('zero-pads day and month', () => {
    expect(formatDate('2026-01-05')).toBe('05.01.2026');
  });

  it('formats a timestamp as dd.MM.yyyy HH:mm', () => {
    const local = new Date(2026, 8, 20, 14, 35);
    expect(formatDateTime(local)).toBe('20.09.2026 14:35');
  });

  it('renders an em dash for a missing or unparseable date', () => {
    expect(formatDate(null)).toBe('—');
    expect(formatDateTime('not a date')).toBe('—');
  });
});

describe('formatCount', () => {
  it('groups counts but never adds decimals', () => {
    expect(formatCount(1284)).toBe(`1${NARROW_NBSP}284`);
    expect(formatCount(0)).toBe('0');
    expect(formatCount(null)).toBe('—');
  });
});

describe('compareBySortKey', () => {
  it('orders by nameSortKey, which carries the Azerbaijani alphabet order', () => {
    const rows = [
      { name: 'Zəfəran', nameSortKey: '900' },
      { name: 'Əncir', nameSortKey: '100' },
      { name: 'Kahı', nameSortKey: '500' },
    ];
    expect([...rows].sort(compareBySortKey).map((r) => r.name)).toEqual([
      'Əncir',
      'Kahı',
      'Zəfəran',
    ]);
  });
});

describe('daysUntil', () => {
  it('counts whole days forward and backward', () => {
    expect(daysUntil('2026-09-27', '2026-09-20')).toBe(7);
    expect(daysUntil('2026-09-13', '2026-09-20')).toBe(-7);
    expect(daysUntil('2026-09-20', '2026-09-20')).toBe(0);
    expect(daysUntil(null, '2026-09-20')).toBeNull();
  });
});
