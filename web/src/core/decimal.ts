import Decimal from 'decimal.js';

/**
 * ADR-008 — quantities and money arrive from the API as JSON strings and stay exact.
 *
 * `Decimal` is configured once for the whole app: enough precision for DECIMAL(18,8) conversion
 * factors, and `ROUND_HALF_UP` so that client-side previews agree with the server's
 * `MidpointRounding.AwayFromZero` (SPEC §6.3). Rounding for storage still happens on the server;
 * the client only ever rounds for display.
 */
Decimal.set({ precision: 34, rounding: Decimal.ROUND_HALF_UP, toExpNeg: -30, toExpPos: 30 });

export type DecimalInput = string | Decimal | Quantity | Money;

/** The contract's `Decimal` schema: a plain JSON string such as `"12.5000"`. */
export type DecimalString = string;

function toDecimal(value: DecimalInput): Decimal {
  if (value instanceof Quantity) return value.value;
  if (value instanceof Money) return value.amount;
  if (value instanceof Decimal) return value;
  return new Decimal(value);
}

/**
 * A quantity expressed in one unit of measure. `uomId` / `uomCode` are carried alongside because a
 * bare number is meaningless in this domain (design-system README: "Rəqəm heç vaxt tək qalmır").
 */
export class Quantity {
  readonly value: Decimal;
  readonly uomId?: number;
  readonly uomCode?: string;

  private constructor(value: Decimal, uomId?: number, uomCode?: string) {
    this.value = value;
    this.uomId = uomId;
    this.uomCode = uomCode;
  }

  /** Parses a contract `Decimal` string. Throws on anything that is not a finite decimal. */
  static parse(raw: DecimalString, uomId?: number, uomCode?: string): Quantity {
    const d = new Decimal(raw);
    if (!d.isFinite()) throw new TypeError(`Quantity.parse: not a finite decimal: ${raw}`);
    return new Quantity(d, uomId, uomCode);
  }

  /** Parses a nullable field; `null` / `undefined` / `''` become `null`. */
  static parseOrNull(
    raw: DecimalString | null | undefined,
    uomId?: number,
    uomCode?: string,
  ): Quantity | null {
    if (raw === null || raw === undefined || raw === '') return null;
    return Quantity.parse(raw, uomId, uomCode);
  }

  static zero(uomId?: number, uomCode?: string): Quantity {
    return new Quantity(new Decimal(0), uomId, uomCode);
  }

  withUom(uomId?: number, uomCode?: string): Quantity {
    return new Quantity(this.value, uomId, uomCode);
  }

  plus(other: DecimalInput): Quantity {
    return new Quantity(this.value.plus(toDecimal(other)), this.uomId, this.uomCode);
  }

  minus(other: DecimalInput): Quantity {
    return new Quantity(this.value.minus(toDecimal(other)), this.uomId, this.uomCode);
  }

  times(factor: DecimalInput): Quantity {
    return new Quantity(this.value.times(toDecimal(factor)), this.uomId, this.uomCode);
  }

  dividedBy(divisor: DecimalInput): Quantity {
    return new Quantity(this.value.dividedBy(toDecimal(divisor)), this.uomId, this.uomCode);
  }

  negated(): Quantity {
    return new Quantity(this.value.negated(), this.uomId, this.uomCode);
  }

  abs(): Quantity {
    return new Quantity(this.value.abs(), this.uomId, this.uomCode);
  }

  isZero(): boolean {
    return this.value.isZero();
  }

  isNegative(): boolean {
    return this.value.isNegative() && !this.value.isZero();
  }

  isPositive(): boolean {
    return this.value.isPositive() && !this.value.isZero();
  }

  comparedTo(other: DecimalInput): number {
    return this.value.comparedTo(toDecimal(other));
  }

  /** Back to the contract representation, with the field's declared scale. */
  toContract(decimals = 4): DecimalString {
    return this.value.toFixed(decimals);
  }

  toString(): string {
    return this.value.toString();
  }
}

/** An amount in a single ISO-4217 currency. Arithmetic across currencies is refused. */
export class Money {
  readonly amount: Decimal;
  readonly currency: string;

  private constructor(amount: Decimal, currency: string) {
    this.amount = amount;
    this.currency = currency;
  }

  static parse(raw: DecimalString, currency = 'AZN'): Money {
    const d = new Decimal(raw);
    if (!d.isFinite()) throw new TypeError(`Money.parse: not a finite decimal: ${raw}`);
    return new Money(d, currency);
  }

  static parseOrNull(raw: DecimalString | null | undefined, currency = 'AZN'): Money | null {
    if (raw === null || raw === undefined || raw === '') return null;
    return Money.parse(raw, currency);
  }

  static zero(currency = 'AZN'): Money {
    return new Money(new Decimal(0), currency);
  }

  private assertSameCurrency(other: Money): void {
    if (other.currency !== this.currency) {
      throw new TypeError(
        `Money: currency mismatch (${this.currency} vs ${other.currency}) — convert with the frozen fxRate first.`,
      );
    }
  }

  plus(other: Money): Money {
    this.assertSameCurrency(other);
    return new Money(this.amount.plus(other.amount), this.currency);
  }

  minus(other: Money): Money {
    this.assertSameCurrency(other);
    return new Money(this.amount.minus(other.amount), this.currency);
  }

  times(factor: DecimalInput): Money {
    return new Money(this.amount.times(toDecimal(factor)), this.currency);
  }

  /** Converts with a frozen rate (`proc_purchase_order.fx_rate`), never with a live lookup. */
  convert(rate: DecimalString | Decimal, toCurrency: string): Money {
    return new Money(this.amount.times(toDecimal(rate)), toCurrency);
  }

  negated(): Money {
    return new Money(this.amount.negated(), this.currency);
  }

  isZero(): boolean {
    return this.amount.isZero();
  }

  isNegative(): boolean {
    return this.amount.isNegative() && !this.amount.isZero();
  }

  comparedTo(other: Money): number {
    this.assertSameCurrency(other);
    return this.amount.comparedTo(other.amount);
  }

  toContract(decimals = 4): DecimalString {
    return this.amount.toFixed(decimals);
  }

  toString(): string {
    return `${this.amount.toString()} ${this.currency}`;
  }
}

/** Sums a list of contract decimal strings without ever going through `number`. */
export function sumDecimals(values: readonly DecimalString[]): Decimal {
  return values.reduce((acc, v) => acc.plus(new Decimal(v)), new Decimal(0));
}

export { Decimal };
