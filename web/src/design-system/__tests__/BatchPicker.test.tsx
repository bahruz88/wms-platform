import { describe, expect, it, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import {
  BatchPicker,
  isSelectableBatch,
  sortBatches,
  suggestedBatchId,
  type Batch,
} from '../BatchPicker';

const batches: Batch[] = [
  {
    id: 1,
    batchNo: 'B-003',
    expiryDate: '2026-12-01',
    receivedAt: '2026-09-01',
    available: '40',
    status: 'ACTIVE',
  },
  {
    id: 2,
    batchNo: 'B-001',
    expiryDate: '2026-10-05',
    receivedAt: '2026-08-01',
    available: '12',
    status: 'ACTIVE',
  },
  {
    id: 3,
    batchNo: 'B-002',
    expiryDate: '2026-09-01',
    receivedAt: '2026-07-01',
    available: '42',
    status: 'EXPIRED',
  },
  {
    id: 4,
    batchNo: 'B-004',
    expiryDate: '2027-01-01',
    receivedAt: '2026-06-01',
    available: '80',
    status: 'BLOCKED',
  },
];

const today = '2026-09-21';

/** components/BatchPicker/README.md. */
describe('BatchPicker', () => {
  it('flags the FEFO suggestion — the earliest expiry among selectable batches', () => {
    render(<BatchPicker batches={batches} strategy="FEFO" today={today} />);
    expect(screen.getByText('FEFO təklifi')).toBeInTheDocument();
    // B-001 expires first among ACTIVE batches; B-002 expires earlier but is EXPIRED.
    expect(suggestedBatchId(batches, 'FEFO')).toBe(2);
  });

  it('flags the FIFO suggestion by receipt date instead', () => {
    render(<BatchPicker batches={batches} strategy="FIFO" today={today} />);
    expect(screen.getByText('FIFO təklifi')).toBeInTheDocument();
    expect(suggestedBatchId(batches, 'FIFO')).toBe(2);
  });

  it('keeps non-ACTIVE batches visible but unselectable, with the reason on the control', () => {
    render(<BatchPicker batches={batches} today={today} />);
    const expired = screen.getByRole('button', { name: /B-002/ });
    const blocked = screen.getByRole('button', { name: /B-004/ });
    expect(expired).toBeVisible();
    expect(expired).toBeDisabled();
    expect(expired).toHaveAttribute('title', 'Vaxtı keçib — ayrıla bilməz');
    expect(blocked).toBeDisabled();
    expect(blocked).toHaveAttribute('title', 'Bloklanıb — ayrıla bilməz');
  });

  it('does not call onChange for a non-ACTIVE batch', async () => {
    const onChange = vi.fn();
    render(<BatchPicker batches={batches} today={today} onChange={onChange} />);
    await userEvent.click(screen.getByRole('button', { name: /B-002/ }));
    expect(onChange).not.toHaveBeenCalled();
    await userEvent.click(screen.getByRole('button', { name: /B-001/ }));
    expect(onChange).toHaveBeenCalledWith(2, expect.objectContaining({ batchNo: 'B-001' }));
  });

  it('warns and demands a reason when the user picks away from the suggestion', () => {
    const { rerender } = render(<BatchPicker batches={batches} today={today} value={2} />);
    expect(screen.queryByTestId('wms-batch-off-suggestion')).not.toBeInTheDocument();
    rerender(<BatchPicker batches={batches} today={today} value={1} />);
    const warning = screen.getByTestId('wms-batch-off-suggestion');
    expect(warning).toHaveAttribute('role', 'alert');
    expect(warning.textContent).toContain('Səbəb kodu və qeyd məcburidir');
  });

  it('marks an expired batch with the days that have passed', () => {
    render(<BatchPicker batches={batches} today={today} />);
    expect(screen.getByText('20 gün keçib')).toBeInTheDocument();
  });

  it('applies the two-step expiry signal from inv_setting', () => {
    render(<BatchPicker batches={batches} today={today} criticalDays={7} warningDays={30} />);
    // B-001 expires 2026-10-05 → 14 days → warning tone.
    const warningBadge = screen.getByText('14 gün qalıb');
    expect(warningBadge).toHaveClass('wms-badge--warning');
  });

  it('keeps a batch with less than the required quantity, marked as a partial allocation', () => {
    render(<BatchPicker batches={batches} today={today} requiredQty="20" uom="KG" />);
    expect(screen.getByRole('button', { name: /B-001/ })).toBeVisible();
    expect(screen.getByText('Qismən ayırma')).toBeInTheDocument();
  });

  it('orders ACTIVE first, then QUARANTINE, BLOCKED, EXPIRED', () => {
    const ordered = sortBatches([
      { id: 1, batchNo: 'X', available: '1', status: 'EXPIRED' },
      { id: 2, batchNo: 'Y', available: '1', status: 'ACTIVE' },
      { id: 3, batchNo: 'Z', available: '1', status: 'BLOCKED' },
      { id: 4, batchNo: 'W', available: '1', status: 'QUARANTINE' },
    ]);
    expect(ordered.map((b) => b.status)).toEqual(['ACTIVE', 'QUARANTINE', 'BLOCKED', 'EXPIRED']);
  });

  it('treats a batch with no status as ACTIVE', () => {
    expect(isSelectableBatch({ id: 9, batchNo: 'N', available: '1' })).toBe(true);
  });

  it('shows an empty state that names the next step', () => {
    render(<BatchPicker batches={[]} today={today} />);
    expect(
      screen.getByText('Bu məhsul üçün bu lokasiyada partiya yoxdur. Qəbul sənədi yaradın.'),
    ).toBeInTheDocument();
  });
});
