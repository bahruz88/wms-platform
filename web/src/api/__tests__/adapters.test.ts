import { describe, expect, it } from 'vitest';
import {
  batchRef,
  indexById,
  locationRef,
  moneyRef,
  normalizeBalance,
  productRef,
} from '../adapters';
import type { Location, ProductSummary } from '../endpoints';

const products = indexById<ProductSummary>([
  {
    id: 1,
    sku: 'LETTUCE',
    name: 'Kahı',
    baseUomId: 1,
    baseUomCode: 'G',
    productType: 'FOOD',
    requiresBatch: false,
    requiresExpiry: false,
    isActive: true,
  },
]);

const locations = indexById<Location>([
  {
    id: 2,
    code: 'BR-ELM',
    name: 'Elmlər filialı',
    locationType: 'RESTAURANT',
    isVirtual: false,
    isActive: true,
    allowsFood: true,
    allowsNonFood: true,
    rowVersion: 1,
  },
]);

/**
 * The gateway currently answers some endpoints with flat foreign keys where the contract declares
 * embedded reference objects. The adapters accept both and always produce the contract shape.
 */
describe('reference adapters', () => {
  it('builds a product reference from a flat productId by joining master data', () => {
    const ref = productRef({ productId: 1, qtyOnHand: '10' }, products);
    expect(ref).toMatchObject({ id: 1, sku: 'LETTUCE', name: 'Kahı', baseUomCode: 'G' });
  });

  it('prefers the embedded object when the endpoint already returns the contract shape', () => {
    const ref = productRef(
      { product: { id: 9, sku: 'X', name: 'Y', baseUomId: 3, baseUomCode: 'KG' } },
      products,
    );
    expect(ref).toMatchObject({ id: 9, sku: 'X', name: 'Y', baseUomCode: 'KG' });
  });

  it('shows the bare id rather than inventing a name when master data has no match', () => {
    const ref = productRef({ productId: 101 }, products);
    expect(ref.sku).toBe('#101');
    expect(ref.name).toBe('#101');
  });

  it('resolves a location and keeps the virtual flag', () => {
    expect(locationRef({ locationId: 2 }, locations)).toMatchObject({
      id: 2,
      code: 'BR-ELM',
      name: 'Elmlər filialı',
      isVirtual: false,
    });
  });

  it('treats batchId = 0 as "no batch", not as batch number zero', () => {
    expect(batchRef({ batchId: 0 })).toBeNull();
    expect(batchRef({ batchId: 7, batchNo: 'B-007' })).toMatchObject({ id: 7, batchNo: 'B-007' });
  });

  it('normalises a live balance row without losing its decimal strings', () => {
    const balance = normalizeBalance(
      {
        productId: 1,
        locationId: 2,
        batchId: 0,
        qtyOnHand: '2826.0870',
        qtyReserved: '0.0000',
        qtyAvailable: '2826.0870',
        avgUnitCost: '0.0030',
        totalValue: '8.4783',
        updatedAt: '2026-09-21T09:11:45.948+00:00',
      },
      products,
      locations,
    );
    expect(balance.product.sku).toBe('LETTUCE');
    expect(balance.location.name).toBe('Elmlər filialı');
    expect(balance.batch).toBeNull();
    // Strings stay strings — no float round-trip.
    expect(balance.qtyOnHand).toBe('2826.0870');
    expect(balance.totalValue).toBe('8.4783');
  });

  it('keeps the cost fields absent when the server stripped them for this role', () => {
    const balance = normalizeBalance(
      { productId: 1, locationId: 2, batchId: 0, qtyOnHand: '5000.0000' },
      products,
      locations,
    );
    expect(balance.avgUnitCost).toBeUndefined();
    expect(balance.totalValue).toBeUndefined();
  });
});

/**
 * The return-to-vendor endpoints disagree with their contract about `claimAmount`: the schema
 * says `Money { amount, currency }`, the running service sends and accepts a bare decimal
 * string. Reading `.amount` off the string produced `undefined`, which reached `Decimal` and
 * threw, blanking the whole document — so both shapes are absorbed at the edge.
 */
describe('moneyRef', () => {
  it('accepts the contract object', () => {
    expect(moneyRef({ amount: '40.0000', currency: 'USD' })).toEqual({
      amount: '40.0000',
      currency: 'USD',
    });
  });

  it('accepts the bare decimal string the service actually sends', () => {
    expect(moneyRef('40.0000')).toEqual({ amount: '40.0000', currency: 'AZN' });
  });

  it('defaults the currency only when the payload has none', () => {
    expect(moneyRef('7', 'USD')).toEqual({ amount: '7', currency: 'USD' });
    expect(moneyRef({ amount: '7', currency: 'EUR' }, 'USD')).toEqual({
      amount: '7',
      currency: 'EUR',
    });
  });

  it('reads an absent, null or empty amount as no money at all, never as zero', () => {
    expect(moneyRef(null)).toBeNull();
    expect(moneyRef(undefined)).toBeNull();
    expect(moneyRef('')).toBeNull();
    expect(moneyRef({})).toBeNull();
  });

  it('never turns the amount into a number', () => {
    expect(typeof moneyRef('0.1')?.amount).toBe('string');
    expect(moneyRef(0.1)?.amount).toBe('0.1');
  });
});
