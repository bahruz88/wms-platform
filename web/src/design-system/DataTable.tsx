import type { ReactNode } from 'react';
import { format } from './format';

/**
 * DataTable — docs/design-system/components/DataTable/README.md.
 *
 * The permission rule is the important one: a column carrying `permission` is **not built at all**
 * unless the code is in `permissions`. An empty cell or `***` would leak the permission model —
 * the server already drops those fields from the JSON, and the interface repeats that, it does
 * not substitute for it (SPEC §16, ADR-013).
 *
 * Real `table` markup with `th` + `scope`; sorting, filtering and paging live outside the
 * component because the server returns `{ items, page, size, total }`.
 */
export interface Column<R = unknown> {
  key: string;
  header: ReactNode;
  width?: string;
  align?: 'left' | 'center' | 'right';
  /** Right-aligned, mono + tabular figures. */
  numeric?: boolean;
  decimals?: number;
  render?: (row: R, index: number) => ReactNode;
  /** When set, the column is rendered only if this code is in `permissions`. */
  permission?: string;
}

export interface DataTableProps<R = unknown> {
  columns: Column<R>[];
  rows: R[];
  /** The user's permission codes, e.g. ["master.product.view_cost"]. */
  permissions?: string[];
  rowKey?: (row: R, index: number) => string | number;
  dense?: boolean;
  caption?: ReactNode;
  label?: string;
  /** Empty-state text — say the reason and the next step. */
  empty?: ReactNode;
  footer?: Record<string, ReactNode | number>;
  maxHeight?: string;
  selectedKey?: string | number;
  onRowClick?: (row: R, index: number) => void;
}

/**
 * Drops every column the user is not allowed to see. Exported so screens and tests can assert on
 * the same filter the table applies.
 */
export function visibleColumns<R>(
  columns: Column<R>[],
  permissions: string[] | undefined,
): Column<R>[] {
  const granted = permissions ?? [];
  return columns.filter((c) => !c.permission || granted.includes(c.permission));
}

function cellValue<R>(row: R, column: Column<R>, index: number): ReactNode {
  if (column.render) return column.render(row, index);
  const raw = (row as Record<string, unknown>)[column.key];
  if (raw === null || raw === undefined) return column.numeric ? '—' : '';
  if (column.numeric) {
    return format.number(raw as string | number, column.decimals ?? 4);
  }
  return raw as ReactNode;
}

export function DataTable<R>({
  columns,
  rows,
  permissions,
  rowKey,
  dense = true,
  caption,
  label,
  empty,
  footer,
  maxHeight,
  selectedKey,
  onRowClick,
}: DataTableProps<R>) {
  const cols = visibleColumns(columns, permissions);

  const tableClasses = ['wms-table'];
  if (dense) tableClasses.push('wms-table--dense');

  const wrapClasses = ['wms-table-wrap'];
  if (onRowClick) wrapClasses.push('wms-row-click');

  return (
    <div className={wrapClasses.join(' ')} style={maxHeight ? { maxHeight } : undefined}>
      <table className={tableClasses.join(' ')} aria-label={label}>
        {caption ? <caption className="wms-table__caption">{caption}</caption> : null}
        <thead>
          <tr>
            {cols.map((column) => (
              <th
                key={column.key}
                scope="col"
                style={{
                  width: column.width,
                  textAlign: column.numeric ? 'right' : (column.align ?? 'left'),
                }}
              >
                {column.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.length === 0 ? (
            <tr>
              <td className="wms-table__empty" colSpan={Math.max(1, cols.length)}>
                {empty ?? 'Bu siyahıda sətir yoxdur.'}
              </td>
            </tr>
          ) : (
            rows.map((row, index) => {
              const key = rowKey ? rowKey(row, index) : index;
              const selected = selectedKey !== undefined && selectedKey === key;
              return (
                <tr
                  key={key}
                  aria-selected={selected || undefined}
                  onClick={onRowClick ? () => onRowClick(row, index) : undefined}
                >
                  {cols.map((column, colIndex) => (
                    <td
                      key={column.key}
                      className={column.numeric ? 'wms-td--num' : undefined}
                      style={
                        !column.numeric && column.align ? { textAlign: column.align } : undefined
                      }
                    >
                      {/* Keyboard access for a clickable row: one focusable element per row. */}
                      {onRowClick && colIndex === 0 ? (
                        <button
                          type="button"
                          className="wms-table__rowbtn"
                          onClick={(e) => {
                            e.stopPropagation();
                            onRowClick(row, index);
                          }}
                        >
                          {cellValue(row, column, index)}
                        </button>
                      ) : (
                        cellValue(row, column, index)
                      )}
                    </td>
                  ))}
                </tr>
              );
            })
          )}
        </tbody>
        {footer && rows.length > 0 ? (
          <tfoot>
            <tr>
              {cols.map((column) => (
                <td key={column.key} className={column.numeric ? 'wms-td--num' : undefined}>
                  {footer[column.key] ?? ''}
                </td>
              ))}
            </tr>
          </tfoot>
        ) : null}
      </table>
    </div>
  );
}
