import { useQueries } from '@tanstack/react-query';
import { guarded } from './client';
import { listProductUoms, type ProductSummary, type ProductUomRow } from './endpoints';
import type { ApiError } from './problem';
import type { ProductUom as SelectableUom } from '@ds/index';

/**
 * `master_product_uom` — the alternative units a product may be entered in.
 *
 * `QtyUomInput` exists to make the `1 QUTUDA` column part of the arithmetic instead of a note
 * on the side: the user types `8 CASE` and the field shows `= 96 PCS` underneath. That only
 * works when the product's unit rows are known. While `GET /masterdata/products/{id}/uoms` was
 * unrouted, every creation screen built a one-element list out of the product's base unit, and
 * the select was permanently stuck on it — the control could not do the one thing it is for.
 *
 * The route serves now, so the rows come from the server and the per-screen fallback is gone.
 * A product whose rows cannot be read keeps a usable field — the base unit, which is always a
 * real row (factor 1) — and `error` is raised so the screen can say the list is short rather
 * than pretending the product has exactly one unit.
 */

export interface ProductUomSet {
  /** The contract rows, valid today. */
  rows: ProductUomRow[];
  /** `QtyUomInput`'s option list; `factorToBase` stays the contract decimal string. */
  options: SelectableUom[];
  /** What a new line starts on: the purchase/issue default, else the base unit. */
  defaultUomId: number | null;
  /** True when the rows came from the server rather than from the product's base unit alone. */
  fromServer: boolean;
}

export interface ProductUoms {
  uomsFor: (product: ProductSummary | undefined | null) => ProductUomSet;
  isLoading: boolean;
  /** The first failure, if any — the screen names it instead of silently offering one unit. */
  error: ApiError | null;
}

const EMPTY: ProductUomSet = { rows: [], options: [], defaultUomId: null, fromServer: false };

/** The base unit on its own: what a product without readable rows can still be entered in. */
function baseOnly(product: ProductSummary): ProductUomSet {
  return {
    rows: [],
    options: [{ id: product.baseUomId, code: product.baseUomCode ?? '—', factorToBase: '1' }],
    defaultUomId: product.baseUomId,
    fromServer: false,
  };
}

function toSet(rows: ProductUomRow[], prefer: 'issue' | 'purchase'): ProductUomSet {
  const preferred =
    rows.find((r) => (prefer === 'purchase' ? r.isPurchaseDefault : r.isIssueDefault)) ??
    rows.find((r) => r.factorToBase === '1' || Number(r.factorToBase) === 1) ??
    rows[0];
  return {
    rows,
    options: rows.map((r) => ({ id: r.uomId, code: r.uomCode, factorToBase: r.factorToBase })),
    defaultUomId: preferred?.uomId ?? null,
    fromServer: true,
  };
}

/**
 * Reads the unit rows of every product currently on the screen.
 *
 * One query per product, cached by id: a line editor with three products issues three requests
 * once and none again while the user types.
 */
export function useProductUoms(
  productIds: readonly number[],
  prefer: 'issue' | 'purchase' = 'issue',
): ProductUoms {
  const ids = [...new Set(productIds.filter((id) => Number.isFinite(id) && id > 0))].sort(
    (a, b) => a - b,
  );

  const results = useQueries({
    queries: ids.map((id) => ({
      queryKey: ['product-uoms', id] as const,
      queryFn: () => guarded(() => listProductUoms(id), `product-uoms/${id}`),
      retry: false,
      staleTime: 5 * 60 * 1000,
    })),
  });

  const byProduct = new Map<number, ProductUomRow[]>();
  ids.forEach((id, index) => {
    const rows = results[index]?.data;
    if (Array.isArray(rows)) byProduct.set(id, rows as ProductUomRow[]);
  });

  const failure = results.find((r) => r.isError)?.error;

  return {
    isLoading: results.some((r) => r.isLoading),
    error: (failure as ApiError | undefined) ?? null,
    uomsFor: (product) => {
      if (!product) return EMPTY;
      const rows = byProduct.get(product.id);
      if (!rows || rows.length === 0) return baseOnly(product);
      return toSet(rows, prefer);
    },
  };
}
