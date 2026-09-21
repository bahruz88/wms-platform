import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import { LedgerTable, isVirtualLocationType, type LedgerLine } from '../LedgerTable';
import { RAW } from './testUtils';

const balanced: LedgerLine[] = [
  {
    lineNo: 1,
    product: 'Kahı',
    sku: 'LETTUCE',
    location: 'Təchizatçı (virtual)',
    locationType: 'V_SUPPLIER',
    qtyBase: '-2173.9130',
    uom: 'G',
    unitCost: '0.0030',
  },
  {
    lineNo: 2,
    product: 'Kahı',
    sku: 'LETTUCE',
    location: 'Elmlər filialı',
    locationType: 'RESTAURANT',
    qtyBase: '2173.9130',
    uom: 'G',
    unitCost: '0.0030',
  },
];

const unbalanced: LedgerLine[] = [
  { ...(balanced[0] as LedgerLine) },
  { ...(balanced[1] as LedgerLine), qtyBase: '2000.0000' },
];

/** components/LedgerTable/README.md: sign always visible, zero-sum row always rendered. */
describe('LedgerTable', () => {
  it('always shows the sign — + for a receipt, U+2212 for an issue', () => {
    render(<LedgerTable lines={balanced} />);
    expect(screen.getByText('+2 173,9130', RAW)).toBeInTheDocument();
    expect(screen.getByText('−2 173,9130', RAW)).toBeInTheDocument();
  });

  it('colours the sign as a duplicate signal, never as the only one', () => {
    const { container } = render(<LedgerTable lines={balanced} />);
    const out = container.querySelector('.wms-ledger__qty--out');
    const inc = container.querySelector('.wms-ledger__qty--in');
    expect(out?.textContent).toContain('−');
    expect(inc?.textContent).toContain('+');
  });

  it('renders the zero-sum check row and reports a balanced group', () => {
    render(<LedgerTable lines={balanced} />);
    const check = screen.getByTestId('wms-ledger-balance-check');
    expect(check).toHaveClass('wms-ledger__check--ok');
    expect(check.textContent).toContain('Qrup cəmi sıfırdır');
  });

  it('flags an unbalanced group in danger and says the document cannot be posted', () => {
    render(<LedgerTable lines={unbalanced} />);
    const check = screen.getByTestId('wms-ledger-balance-check');
    expect(check).toHaveClass('wms-ledger__check--fail');
    expect(check).toHaveAttribute('role', 'alert');
    expect(check.textContent).toContain('Sənəd post edilə bilməz');
  });

  it('shows the check row even for an empty group', () => {
    render(<LedgerTable lines={[]} />);
    expect(screen.getByTestId('wms-ledger-balance-check')).toBeInTheDocument();
  });

  it('can hide the check only when explicitly asked', () => {
    render(<LedgerTable lines={balanced} showBalanceCheck={false} />);
    expect(screen.queryByTestId('wms-ledger-balance-check')).not.toBeInTheDocument();
  });

  it('badges a virtual location so it cannot be mistaken for a warehouse', () => {
    const { container } = render(<LedgerTable lines={balanced} />);
    const badges = container.querySelectorAll('.wms-badge--virtual');
    expect(badges).toHaveLength(1);
    expect(badges[0]?.textContent).toContain('Təchizatçı (virtual)');
  });

  it('hides the cost column unless showCost is passed', () => {
    const { rerender } = render(<LedgerTable lines={balanced} />);
    expect(screen.queryByRole('columnheader', { name: 'Vahid dəyəri' })).not.toBeInTheDocument();
    rerender(<LedgerTable lines={balanced} showCost />);
    expect(screen.getByRole('columnheader', { name: 'Vahid dəyəri' })).toBeInTheDocument();
  });

  it('offers no edit control — movements are append-only', () => {
    const { container } = render(<LedgerTable lines={balanced} showCost />);
    expect(container.querySelectorAll('button')).toHaveLength(0);
    expect(container.textContent).not.toContain('Redaktə');
  });

  it('knows which location types are virtual', () => {
    expect(isVirtualLocationType('V_WASTE')).toBe(true);
    expect(isVirtualLocationType('IN_TRANSIT')).toBe(true);
    expect(isVirtualLocationType('V_CONSUMPTION')).toBe(true);
    expect(isVirtualLocationType('CENTRAL_WAREHOUSE')).toBe(false);
    expect(isVirtualLocationType(undefined)).toBe(false);
  });
});
