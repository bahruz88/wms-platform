import { describe, expect, it } from 'vitest';
import { batchRef, indexById, locationRef, normalizeBalance, productRef } from '../adapters';
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
