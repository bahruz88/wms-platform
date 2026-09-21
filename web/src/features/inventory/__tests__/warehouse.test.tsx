import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { confirmValid, safeEquals } from '../IssueDetailScreen';
import { exceeds } from '../CountDetailScreen';
import { approvalLink } from '@features/dashboard/DashboardScreen';
import { BatchPicker, LedgerTable, VarianceIndicator, suggestedBatchId } from '@ds/index';
import type { Issue } from '@api/endpoints';

/**
 * The warehouse rules the artboards make visible, tested where they live.
 *
 * These are the invariants a screenshot cannot prove: a branch confirmation that differs from
 * what was sent needs a reason and a note, a variance percentage is compared against the
 * tenant's threshold rather than a hard-coded one, an issue preview must sum to zero, and the
 * FEFO suggestion is the batch with the nearest expiry, not the first in the list.
 */

const line = (id: number, qty: string) =>
  ({
    id,
    lineNo: id,
    qty,
    qtyBase: qty,
    uomId: 1,
    uomCode: 'PCS',
    product: {
      id: 1,
      sku: 'BSB-0114',
      name: 'Bread Stick Black',
      baseUomId: 1,
      baseUomCode: 'PCS',
    },
  }) as unknown as Issue['lines'][number];

describe('branch receipt confirmation', () => {
  const doc = { lines: [line(1, '120'), line(2, '60')] };

  it('accepts a confirmation that matches what was sent, with no reason', () => {
    expect(
      confirmValid(doc, {
        1: { receivedQty: '120', reasonCodeId: '', note: '' },
        2: { receivedQty: '60', reasonCodeId: '', note: '' },
      }),
    ).toBe(true);
  });

  it('refuses a short delivery with no reason code', () => {
    expect(
      confirmValid(doc, {
        1: { receivedQty: '118', reasonCodeId: '', note: 'iki ədəd əzik' },
        2: { receivedQty: '60', reasonCodeId: '', note: '' },
      }),
    ).toBe(false);
  });

  it('refuses a short delivery with a reason code but no note', () => {
    expect(
      confirmValid(doc, {
        1: { receivedQty: '118', reasonCodeId: '7', note: '   ' },
        2: { receivedQty: '60', reasonCodeId: '', note: '' },
      }),
    ).toBe(false);
  });

  it('accepts a short delivery once both the reason and the note are there', () => {
    expect(
      confirmValid(doc, {
        1: { receivedQty: '118', reasonCodeId: '7', note: 'iki ədəd əzik' },
        2: { receivedQty: '60', reasonCodeId: '', note: '' },
      }),
    ).toBe(true);
  });

  it('refuses an empty quantity outright', () => {
    expect(confirmValid(doc, { 1: { receivedQty: '', reasonCodeId: '', note: '' } })).toBe(false);
  });

  it('compares quantities as decimals, not as strings', () => {
    expect(safeEquals('120.0000', '120')).toBe(true);
    expect(safeEquals('120.0001', '120')).toBe(false);
    // An unparsable value counts as different, so the reason is demanded rather than skipped.
    expect(safeEquals('yüz iyirmi', '120')).toBe(false);
  });
});

describe('count variance threshold', () => {
  it('compares the absolute percentage against the tenant setting', () => {
    expect(exceeds('2.5', 2)).toBe(true);
    expect(exceeds('-2.5', 2)).toBe(true);
    expect(exceeds('1.9', 2)).toBe(false);
    // Exactly at the threshold is not over it.
    expect(exceeds('2', 2)).toBe(false);
  });

  it('treats a missing percentage as no breach', () => {
    expect(exceeds(null, 2)).toBe(false);
    expect(exceeds(undefined, 2)).toBe(false);
  });
});

describe('pending approval links', () => {
  /**
   * This test used to be green while `/inventory/waste/:id` was not a route at all, so a WASTE
   * link from the dashboard landed on `NotFoundScreen`: asserting the string proved only that
   * the string had not changed. The route now exists, and
   * `features/inventory/__tests__/screens.test.tsx` mounts the real route table at this very
   * URL — that is the assertion that would have caught it.
   */
  it('sends each document type to the screen that can decide it', () => {
    expect(approvalLink({ docType: 'PO', docId: 87 })).toBe('/procurement/purchase-orders/87');
    expect(approvalLink({ docType: 'WASTE', docId: 67 })).toBe('/inventory/waste/67');
    expect(approvalLink({ docType: 'COUNT_ADJUST', docId: 12 })).toBe('/inventory/counts/12');
  });

  it('keeps an unknown document type on the approvals list rather than inventing a route', () => {
    expect(approvalLink({ docType: 'RFQ' as 'PO', docId: 3 })).toBe('/procurement/approvals');
  });
});

describe('issue ledger preview', () => {
  it('sums to zero: what leaves the warehouse is exactly what enters transit', () => {
    render(
      <LedgerTable
        lines={[
          {
            lineNo: 1,
            product: 'Bread Stick Black',
            sku: 'BSB-0114',
            batchNo: 'BSB-2602-B',
            location: 'Food WH',
            locationType: 'CENTRAL_WAREHOUSE',
            qtyBase: '-120',
            uom: 'PCS',
          },
          {
            lineNo: 2,
            product: 'Bread Stick Black',
            sku: 'BSB-0114',
            batchNo: 'BSB-2602-B',
            location: 'Yolda',
            locationType: 'IN_TRANSIT',
            qtyBase: '120',
            uom: 'PCS',
          },
        ]}
        decimals={0}
        showBalanceCheck
        label="Ledger ön baxışı"
      />,
    );
    // The zero-sum check row is the interface twin of the nightly DoubleEntryCheck job.
    expect(document.querySelector('.wms-ledger__check--ok')).toBeInTheDocument();
    expect(document.querySelector('.wms-ledger__check--fail')).toBeNull();
  });
});

describe('FEFO suggestion', () => {
  const batches = [
    { id: 3, batchNo: 'BSB-2602-B', expiryDate: '2027-02-18', available: '1284', status: 'ACTIVE' },
    { id: 1, batchNo: 'BSB-2509-A', expiryDate: '2026-09-25', available: '96', status: 'ACTIVE' },
    { id: 4, batchNo: 'BSB-2508-X', expiryDate: '2026-09-10', available: '42', status: 'EXPIRED' },
  ];

  it('suggests the nearest usable expiry, skipping a batch that cannot be issued', () => {
    expect(String(suggestedBatchId(batches, 'FEFO'))).toBe('1');
  });

  it('shows the non-selectable batch but does not let it be picked', () => {
    render(
      <MemoryRouter>
        <BatchPicker batches={batches} strategy="FEFO" today="2026-09-20" decimals={0} />
      </MemoryRouter>,
    );
    expect(screen.getByText('BSB-2508-X')).toBeInTheDocument();
    const expired = screen.getByText('BSB-2508-X').closest('button');
    expect(expired).toBeDisabled();
  });
});

describe('goods receipt variance column', () => {
  it('demands a reason when the received quantity differs from what was ordered', () => {
    render(<VarianceIndicator book="30" counted="22.4" decimals={3} thresholdPct={0} />);
    expect(screen.getByText(/Səbəb kodu yoxdur/)).toBeInTheDocument();
  });

  it('drops the warning once the note is there', () => {
    render(
      <VarianceIndicator
        book="30"
        counted="22.4"
        decimals={3}
        thresholdPct={0}
        reasonCode="çatışmazlıq"
      />,
    );
    expect(screen.queryByText(/Səbəb kodu yoxdur/)).toBeNull();
  });
});
