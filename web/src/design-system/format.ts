import {
  formatDate,
  formatDateTime,
  formatNumber,
  formatSigned,
  type FormattableNumber,
} from '@core/format';

/**
 * The `format` helper exported by the design system, with the signatures declared in
 * docs/design-system/components/index.d.ts. The implementation lives in `@core/format` so the
 * same rules apply to screens that format outside a component.
 */
export const format = {
  /** `1234.5` → `1 234,5000` (narrow no-break space + comma). */
  number(value: FormattableNumber, decimals = 4): string {
    return formatNumber(value, decimals);
  },
  /** Always signed: `+12,0000` / `−12,0000`. */
  signed(value: FormattableNumber, decimals = 4): string {
    return formatSigned(value, decimals);
  },
  /** ISO → `dd.MM.yyyy`. */
  date(value?: string | Date | null): string {
    return formatDate(value);
  },
  /** ISO → `dd.MM.yyyy HH:mm`. */
  dateTime(value?: string | Date | null): string {
    return formatDateTime(value);
  },
};

export type WmsFormat = typeof format;
