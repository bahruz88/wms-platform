import { describe, expect, it } from 'vitest';
import { Decimal } from '@core/decimal';
import {
  addDays,
  categorySlices,
  cumulative,
  expiryTone,
  fillDays,
  flowScale,
  niceStep,
  signedTick,
  utcDate,
  windowDays,
} from '../series';

describe('dashboard series helpers', () => {
  it('builds the window in UTC, oldest day first, ending on the server’s today', () => {
    expect(utcDate('2026-09-30T23:30:00+04:00')).toBe('2026-09-30');
    expect(utcDate('2026-10-01T02:30:00+04:00')).toBe('2026-09-30');
    expect(windowDays('2026-09-30', 3)).toEqual(['2026-09-28', '2026-09-29', '2026-09-30']);
    expect(addDays('2026-02-28', 1)).toBe('2026-03-01');
  });

  it('fills the days the server left out with zero and keeps Decimal precision', () => {
    const filled = fillDays(
      [
        { date: '2026-09-29', value: '0.1' },
        { date: '2026-09-29', value: '0.2' },
      ],
      windowDays('2026-09-30', 3),
    );
    expect(filled.map((d) => d.value.toString())).toEqual(['0', '0.3', '0']);
  });

  it('turns expiries per day into a running count', () => {
    const run = cumulative(
      fillDays(
        [
          { date: '2026-10-01', value: '2' },
          { date: '2026-10-03', value: '1' },
        ],
        windowDays('2026-10-03', 3),
      ),
    );
    expect(run.map((d) => d.value.toNumber())).toEqual([2, 2, 3]);
  });

  it('reads the flow axis in thousands only once it would need five digits', () => {
    expect(flowScale(new Decimal('9999.99')).unit).toBe('AZN');
    expect(flowScale(new Decimal('21400')).unit).toBe('min AZN');
    expect(niceStep(35)).toBe(10);
    expect(niceStep(9)).toBe(2.5);
    expect(niceStep(0)).toBe(1);
  });

  it('signs axis labels with U+2212 and a comma decimal', () => {
    expect(signedTick(20, 0)).toBe('+20');
    expect(signedTick(-10, 0)).toBe('−10');
    expect(signedTick(21.4, 1)).toBe('+21,4');
    expect(signedTick(0, 1)).toBe('0');
  });

  it('rolls leaf categories up to their root and folds the tail into «Digər»', () => {
    const categories = [
      { id: 1, parentId: null, name: 'Ət' },
      { id: 11, parentId: 1, name: 'Toyuq' },
      { id: 2, parentId: null, name: 'Süd' },
      { id: 3, parentId: null, name: 'Çörək' },
      { id: 4, parentId: null, name: 'Sous' },
      { id: 5, parentId: null, name: 'Tərəvəz' },
      { id: 6, parentId: null, name: 'Qablaşdırma' },
    ];
    const slices = categorySlices(
      [
        { categoryId: 11, value: '300' },
        { categoryId: 1, value: '100' },
        { categoryId: 2, value: '250' },
        { categoryId: 3, value: '150' },
        { categoryId: 4, value: '100' },
        { categoryId: 5, value: '60' },
        { categoryId: 6, value: '40' },
      ],
      categories,
      { uncategorised: 'Kateqoriyasız', other: 'Digər' },
    );
    expect(slices.map((s) => s.label)).toEqual(['Ət', 'Süd', 'Çörək', 'Sous', 'Digər']);
    expect(slices[0]?.value.toString()).toBe('400');
    expect(slices[4]?.value.toString()).toBe('100');
    expect(slices.reduce((acc, s) => acc.plus(s.share), new Decimal(0)).toNumber()).toBeCloseTo(
      100,
    );
  });

  it('keeps value the catalogue could not place instead of dropping it', () => {
    const slices = categorySlices(
      [
        { categoryId: null, value: '10' },
        { categoryId: 99, value: '5' },
      ],
      [],
      { uncategorised: 'Kateqoriyasız', other: 'Digər' },
    );
    expect(slices).toHaveLength(1);
    expect(slices[0]?.label).toBe('Kateqoriyasız');
    expect(slices[0]?.value.toString()).toBe('15');
  });

  it('colours shelf life against the tenant thresholds, and nothing without them', () => {
    expect(expiryTone(5, 7, 30)).toBe('danger');
    expect(expiryTone(14, 7, 30)).toBe('warning');
    expect(expiryTone(18, 7, 30)).toBe('warning');
    expect(expiryTone(22, 7, 30)).toBe('success');
    expect(expiryTone(3, 7, null)).toBe('danger');
    expect(expiryTone(22, 7, null)).toBe('neutral');
    expect(expiryTone(2, null, null)).toBe('neutral');
  });
});
