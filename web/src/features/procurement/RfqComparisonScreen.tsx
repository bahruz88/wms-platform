import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Alert,
  Badge,
  Button,
  DataTable,
  Dialog,
  TextField,
  VarianceIndicator,
  type Column,
} from '@ds/index';
import { useApiQuery } from '@api/hooks';
import {
  getRfq,
  getRfqComparison,
  selectQuotation,
  type RfqComparison,
  type RfqComparisonRow,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatNumber } from '@core/format';
import { DocNo, ErrorState, LoadingState, Page, Section } from '@/components/Page';

/**
 * Quotation comparison — docs/ux/screen-map.md §4.3. Web only: a multi-column matrix has no mobile
 * form.
 *
 * The rule this screen exists to enforce: **choosing anything other than the cheapest quotation
 * requires a `selectionNote`**. The dialog opens a text field in that case and keeps the confirm
 * button disabled until it is filled — the server's `422 SELECTION_NOTE_REQUIRED` is the backstop,
 * not the first line of defence (SPEC §10).
 */
export function RfqComparisonScreen() {
  const { id } = useParams();
  const rfqId = Number(id);
  const { can } = useAuth();
  const queryClient = useQueryClient();

  const [choice, setChoice] = useState<number | null>(null);
  const [note, setNote] = useState('');

  const comparison = useApiQuery<RfqComparison>(['rfq-comparison', rfqId], () =>
    getRfqComparison(rfqId),
  );

  const data = comparison.data;
  /*
   * The comparison payload carries no RFQ status, and selection is only legal while the RFQ is
   * `SENT`: once it is closed the server answers `409 INVALID_STATE_TRANSITION`. So the status is
   * fetched alongside, and the select buttons say why they are off rather than letting the click
   * come back as a conflict.
   */
  const rfq = useApiQuery<{ status: string }>(['rfq', rfqId], () => getRfq(rfqId) as never, {
    retry: false,
  });
  const selectable = rfq.data?.status === 'SENT';

  const chosen = data?.quotations.find((q) => q.id === choice);
  // The quotation the server reports as selected — not `chosen`, which is only what the dialog asked
  // about and would still point at the old pick if the request failed.
  const selected = data?.quotations.find((q) => q.isSelected);
  const isCheapest = chosen ? chosen.id === data?.cheapestQuotationId : true;
  const noteRequired = Boolean(chosen) && !isCheapest;
  const canConfirm = Boolean(chosen) && (!noteRequired || note.trim().length > 0);

  const select = useMutation({
    mutationFn: () => selectQuotation(chosen!.id, chosen!.rowVersion, note.trim() || undefined),
    onSuccess: () => {
      setChoice(null);
      setNote('');
      void queryClient.invalidateQueries({ queryKey: ['rfq-comparison', rfqId] });
    },
  });

  if (comparison.isLoading) return <LoadingState />;
  if (comparison.isError)
    return <ErrorState error={comparison.error} onRetry={() => void comparison.refetch()} />;
  if (!data) return null;

  const columns: Column<RfqComparisonRow>[] = [
    {
      key: 'sku',
      header: 'SKU',
      width: '110px',
      render: (row) => <span className="wms-doc-no">{row.product.sku}</span>,
    },
    { key: 'product', header: 'Məhsul', render: (row) => row.product.name },
    {
      key: 'qty',
      header: 'Miqdar',
      numeric: true,
      decimals: 4,
      render: (row) => `${formatNumber(row.qty, 4)} ${row.uomCode}`,
    },
    {
      key: 'prevPriceBase',
      header: 'Əvvəlki qiymət',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
    // One column per quotation — the matrix the screen exists for.
    ...data.quotations.map<Column<RfqComparisonRow>>((quotation) => ({
      key: `q-${quotation.id}`,
      header: (
        <span className="wms-stack">
          <span>{quotation.supplier.name}</span>
          <span className="wms-row">
            {quotation.id === data.cheapestQuotationId ? (
              <Badge tone="success">Ən ucuz</Badge>
            ) : null}
            {quotation.isSelected ? <Badge tone="accent">Seçilib</Badge> : null}
            <Badge tone="neutral" variant="outline">
              {quotation.currency}
            </Badge>
          </span>
        </span>
      ),
      numeric: true,
      decimals: 4,
      render: (row) => {
        const cell = row.cells.find((c) => c.quotationId === quotation.id);
        if (!cell || cell.unitPriceBase === null || cell.unitPriceBase === undefined) {
          return <span className="wms-muted">Təklif verilməyib</span>;
        }
        return (
          <div className="wms-stack" style={{ alignItems: 'flex-end', gap: 2 }}>
            <span className="wms-num">
              {formatNumber(cell.unitPrice, 4)} {cell.currency}
            </span>
            <span className="wms-num" style={{ fontSize: 12, color: 'var(--ink-muted)' }}>
              = {formatNumber(cell.unitPriceBase, 4)} {data.baseCurrency}
            </span>
            {cell.lineTotalBase ? (
              <span className="wms-num" style={{ fontSize: 12, color: 'var(--ink-muted)' }}>
                cəm {formatNumber(cell.lineTotalBase, 2)}
              </span>
            ) : null}
            <span className="wms-row">
              {cell.isLowest ? <Badge tone="success">Sətirdə ən aşağı</Badge> : null}
              {cell.diffFromPrevPct !== null && cell.diffFromPrevPct !== undefined ? (
                <VarianceIndicator
                  book="100"
                  counted={`${100 + Number(cell.diffFromPrevPct)}`}
                  decimals={2}
                  reasonCode="qiymət dəyişməsi"
                />
              ) : null}
            </span>
          </div>
        );
      },
    })),
  ];

  return (
    <Page
      title={<DocNo value={data.rfqDocNo} />}
      subtitle="Təkliflərin müqayisəsi — sətirlər RFQ sətirləri, sütunlar təkliflər"
    >
      {select.isError ? <ErrorState error={select.error} /> : null}
      {select.isSuccess ? (
        <Alert tone="success" title="Təklif seçildi">
          <div className="wms-stack">
            <span>Seçim audit jurnalına düşdü. Sifariş bu təklifin qiymətləri ilə yaradılır.</span>
            {can('proc.po.create') && selected ? (
              <Link
                to={`/procurement/purchase-orders/new?quotationId=${selected.id}`}
                className="wms-btn wms-btn--primary"
              >
                Sifariş yarat
              </Link>
            ) : null}
          </div>
        </Alert>
      ) : null}

      <Section title="Təkliflər">
        <div className="wms-row">
          {data.quotations.map((quotation) => (
            <Button
              key={quotation.id}
              variant={quotation.isSelected ? 'primary' : 'secondary'}
              disabled={!can('proc.quotation.select') || quotation.isSelected || !selectable}
              title={
                !can('proc.quotation.select')
                  ? '`proc.quotation.select` icazəniz yoxdur'
                  : quotation.isSelected
                    ? 'Bu təklif artıq seçilib'
                    : !selectable
                      ? 'RFQ bağlanıb — seçim bağlanmadan əvvəl edilməlidir'
                      : undefined
              }
              onClick={() => {
                setChoice(quotation.id);
                setNote('');
              }}
            >
              {quotation.supplier.name} · {formatNumber(quotation.totalAmountBase, 2)}{' '}
              {data.baseCurrency}
            </Button>
          ))}
        </div>
      </Section>

      <Section title="Müqayisə matrisi">
        <DataTable<RfqComparisonRow>
          columns={columns}
          rows={data.rows}
          permissions={can('master.product.view_cost') ? ['master.product.view_cost'] : []}
          rowKey={(row) => row.rfqLineId}
          dense={false}
          label="Təklif müqayisəsi"
          empty="Bu RFQ-də sətir yoxdur. RFQ-yə tələb sətirləri əlavə edin."
        />
      </Section>

      <Dialog
        open={choice !== null}
        title="Təklifi seçim?"
        subtitle={
          noteRequired
            ? 'Ən ucuz təklif seçilmir — səbəb məcburidir (SPEC §10).'
            : 'Ən ucuz təklif seçilir.'
        }
        onClose={select.isPending ? undefined : () => setChoice(null)}
        footer={
          <>
            <Button
              disabled={select.isPending}
              title={select.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setChoice(null)}
            >
              İmtina
            </Button>
            <Button
              variant="primary"
              loading={select.isPending}
              disabled={!canConfirm}
              title={!canConfirm ? 'Seçim qeydini doldurun' : undefined}
              onClick={() => select.mutate()}
            >
              Seç
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          <span>
            {chosen?.supplier.name} — cəm {formatNumber(chosen?.totalAmountBase, 2)}{' '}
            {data.baseCurrency}.
          </span>
          {noteRequired ? (
            <TextField
              label="Seçim qeydi"
              required
              value={note}
              hint="Bu mətn təsdiq zəncirində və audit jurnalında görünür."
              error={note.trim() ? undefined : 'Ən ucuz olmayan təklif üçün səbəb məcburidir.'}
              placeholder="Çatdırılma müddəti 3 gün qısadır"
              onChange={(e) => setNote(e.target.value)}
            />
          ) : (
            <Alert tone="info" title="Ən ucuz təklif">
              Bu təklif RFQ üzrə ən aşağı ümumi məbləğə malikdir; əlavə izah tələb olunmur.
            </Alert>
          )}
        </div>
      </Dialog>
    </Page>
  );
}
