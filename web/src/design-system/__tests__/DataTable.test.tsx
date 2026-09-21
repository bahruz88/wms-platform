import { describe, expect, it, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { DataTable, visibleColumns, type Column } from '../DataTable';
import { RAW } from './testUtils';

interface Row {
  sku: string;
  name: string;
  qtyOnHand: string;
  avgUnitCost: string;
  totalValue: string;
}

const rows: Row[] = [
  {
    sku: 'LETTUCE',
    name: 'Kahı',
    qtyOnHand: '2826.0870',
    avgUnitCost: '0.0030',
    totalValue: '8.4783',
  },
  {
    sku: 'CHICKEN',
    name: 'Toyuq',
    qtyOnHand: '5000.0000',
    avgUnitCost: '0.0095',
    totalValue: '47.5000',
  },
];

const columns: Column<Row>[] = [
  { key: 'sku', header: 'SKU' },
  { key: 'name', header: 'Məhsul' },
  { key: 'qtyOnHand', header: 'Qalıq', numeric: true, decimals: 4 },
  {
    key: 'avgUnitCost',
    header: 'Orta maya',
    numeric: true,
    decimals: 4,
    permission: 'master.product.view_cost',
  },
  {
    key: 'totalValue',
    header: 'Dəyər',
    numeric: true,
    decimals: 2,
    permission: 'master.product.view_cost',
  },
];

/**
 * The rule from components/DataTable/README.md and SPEC §16: a column with a `permission` is not
 * built at all without it. Masking it with `***` or an empty cell would leak the permission model.
 */
describe('DataTable permission gating', () => {
  it('renders cost columns for a user who holds master.product.view_cost', () => {
    render(<DataTable columns={columns} rows={rows} permissions={['master.product.view_cost']} />);
    expect(screen.getByRole('columnheader', { name: 'Orta maya' })).toBeInTheDocument();
    expect(screen.getByRole('columnheader', { name: 'Dəyər' })).toBeInTheDocument();
  });

  it('does not render the cost column header without the permission', () => {
    render(<DataTable columns={columns} rows={rows} permissions={['inv.balance.view']} />);
    expect(screen.queryByRole('columnheader', { name: 'Orta maya' })).not.toBeInTheDocument();
    expect(screen.queryByRole('columnheader', { name: 'Dəyər' })).not.toBeInTheDocument();
  });

  it('does not leak the cost values into the DOM at all — not masked, not hidden', () => {
    const { container } = render(
      <DataTable columns={columns} rows={rows} permissions={['inv.balance.view']} />,
    );
    expect(container.textContent).not.toContain('0,0030');
    expect(container.textContent).not.toContain('47,50');
    expect(container.textContent).not.toContain('***');
    // The row count is unchanged; only the columns are gone.
    expect(container.querySelectorAll('tbody tr')).toHaveLength(2);
    expect(container.querySelectorAll('thead th')).toHaveLength(3);
  });

  it('treats a missing permissions array as "no permissions"', () => {
    render(<DataTable columns={columns} rows={rows} />);
    expect(screen.queryByRole('columnheader', { name: 'Orta maya' })).not.toBeInTheDocument();
  });

  it('exposes the same filter as a pure function', () => {
    expect(visibleColumns(columns, []).map((c) => c.key)).toEqual(['sku', 'name', 'qtyOnHand']);
    expect(visibleColumns(columns, ['master.product.view_cost']).map((c) => c.key)).toEqual([
      'sku',
      'name',
      'qtyOnHand',
      'avgUnitCost',
      'totalValue',
    ]);
  });
});

describe('DataTable rendering', () => {
  it('formats numeric columns with the brand book rules', () => {
    render(<DataTable columns={columns} rows={rows} permissions={['master.product.view_cost']} />);
    expect(screen.getByText('2 826,0870', RAW)).toBeInTheDocument();
  });

  it('uses real table markup with scoped headers', () => {
    const { container } = render(<DataTable columns={columns} rows={rows} label="Qalıq" />);
    expect(container.querySelector('table')).toBeInTheDocument();
    container.querySelectorAll('th').forEach((th) => expect(th.getAttribute('scope')).toBe('col'));
  });

  it('shows the empty state text, which must name a next step', () => {
    render(
      <DataTable
        columns={columns}
        rows={[]}
        empty="Bu lokasiyada qalıq yoxdur. Qəbul sənədi yaradın."
      />,
    );
    expect(
      screen.getByText('Bu lokasiyada qalıq yoxdur. Qəbul sənədi yaradın.'),
    ).toBeInTheDocument();
  });

  it('gives a clickable row a focusable element for keyboard access', async () => {
    const onRowClick = vi.fn();
    render(
      <DataTable columns={columns} rows={rows} onRowClick={onRowClick} rowKey={(r) => r.sku} />,
    );
    const button = screen.getByRole('button', { name: 'LETTUCE' });
    button.focus();
    expect(button).toHaveFocus();
    await userEvent.keyboard('{Enter}');
    expect(onRowClick).toHaveBeenCalledWith(rows[0], 0);
  });

  it('marks the selected row with aria-selected', () => {
    const { container } = render(
      <DataTable columns={columns} rows={rows} rowKey={(r) => r.sku} selectedKey="CHICKEN" />,
    );
    const selected = container.querySelectorAll('tr[aria-selected="true"]');
    expect(selected).toHaveLength(1);
    expect(selected[0]?.textContent).toContain('Toyuq');
  });
});
