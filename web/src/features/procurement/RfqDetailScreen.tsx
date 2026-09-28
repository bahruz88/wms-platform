import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Dialog, type Column } from '@ds/index';
import { useApiQuery } from '@api/hooks';
import { closeRfq, getRfq, sendRfq } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate } from '@core/format';
import { Card, DocumentPage, ErrorState, LoadingState, Meta, MetaGrid } from '@/components/Page';

/**
 * Request for quotation (spec §11.2–§11.4).
 *
 * Two transitions: sending it opens the window in which suppliers may quote, and closing it ends
 * that window so the comparison can be decided on a fixed set of offers. Closing before any
 * quotation has arrived would leave nothing to compare, so the button says so rather than letting
 * the request go out and come back as a 422.
 *
 * The comparison itself lives on its own screen — it is a table of suppliers against lines and
 * needs the width.
 */
type Rfq = {
  id: number;
  docNo: string;
  docDate: string;
  dueDate?: string | null;
  status: string;
  supplierCount: number;
  quotationCount: number;
  selectedQuotationId?: number | null;
  rowVersion: number;
  note?: string | null;
  lines: Line[];
  suppliers: Array<{ id: number; code: string; name: string }>;
};

type Line = {
  id: number;
  lineNo: number;
  product: { id: number; sku: string; name: string };
  qty: string;
  uomCode?: string | null;
  note?: string | null;
};

export function RfqDetailScreen() {
  const { id } = useParams();
  const rfqId = Number(id);
  const { can } = useAuth();
  const queryClient = useQueryClient();
  const [action, setAction] = useState<'send' | 'close' | null>(null);

  const rfq = useApiQuery<Rfq>(['rfq', rfqId], () => getRfq(rfqId) as Promise<Rfq>);

  const run = useMutation({
    mutationFn: () => {
      const rowVersion = rfq.data?.rowVersion ?? 1;
      return action === 'send' ? sendRfq(rfqId, rowVersion) : closeRfq(rfqId, rowVersion);
    },
    onSuccess: () => {
      setAction(null);
      void queryClient.invalidateQueries({ queryKey: ['rfq', rfqId] });
      void queryClient.invalidateQueries({ queryKey: ['rfqs'] });
    },
  });

  if (rfq.isLoading) return <LoadingState />;
  if (rfq.isError)
    return (
      <DocumentPage breadcrumb="Satınalma · RFQ" docNo={`#${rfqId}`}>
        <ErrorState error={rfq.error} onRetry={() => void rfq.refetch()} />
      </DocumentPage>
    );
  const doc = rfq.data;
  if (!doc) return null;

  const isDraft = doc.status === 'DRAFT';
  const isSent = doc.status === 'SENT';
  const hasQuotations = doc.quotationCount > 0;

  const columns: Column<Line>[] = [
    { key: 'lineNo', header: '#', width: '50px', numeric: true, decimals: 0 },
    {
      key: 'sku',
      header: 'SKU',
      width: '120px',
      render: (row) => <span className="wms-doc-no">{row.product.sku}</span>,
    },
    { key: 'product', header: 'Məhsul', render: (row) => row.product.name },
    { key: 'qty', header: 'Miqdar', numeric: true, decimals: 4 },
    {
      key: 'uomCode',
      header: 'Vahid',
      width: '70px',
      render: (row) => row.uomCode || <span className="wms-muted">—</span>,
    },
    {
      key: 'note',
      header: 'Qeyd',
      render: (row) => row.note ?? <span className="wms-muted">—</span>,
    },
  ];

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/procurement/requisitions">Satınalma</Link> ·{' '}
          <Link to="/procurement/rfqs">RFQ</Link>
        </>
      }
      docNo={doc.docNo}
      status={doc.status}
      context={`${doc.supplierCount} təchizatçı · ${doc.quotationCount} təklif`}
      actions={
        <>
          <Button variant="ghost" onClick={() => window.print()}>
            Çap et
          </Button>
          {hasQuotations ? (
            <Link
              to={`/procurement/rfqs/${doc.id}/comparison`}
              className="wms-btn wms-btn--secondary"
            >
              Müqayisə
            </Link>
          ) : null}
          {isDraft ? (
            can('proc.rfq.send') ? (
              <Button variant="primary" onClick={() => setAction('send')}>
                Təchizatçılara göndər
              </Button>
            ) : (
              <Button disabled title="`proc.rfq.send` icazəniz yoxdur">
                Təchizatçılara göndər
              </Button>
            )
          ) : isSent ? (
            can('proc.rfq.close') ? (
              <Button
                variant="secondary"
                disabled={!hasQuotations}
                title={!hasQuotations ? 'Bağlamaq üçün ən azı bir təklif lazımdır' : undefined}
                onClick={() => setAction('close')}
              >
                Bağla
              </Button>
            ) : null
          ) : (
            <Badge tone="neutral">{STATUS_NOTES[doc.status] ?? 'RFQ bağlıdır'}</Badge>
          )}
        </>
      }
    >
      {run.isError ? <ErrorState error={run.error} /> : null}
      {isDraft ? (
        <Alert tone="info" title="Qaralama təchizatçıya görünmür">
          RFQ yalnız «Təchizatçılara göndər» addımından sonra təklif qəbul edir.
        </Alert>
      ) : null}
      {isSent && !hasQuotations ? (
        <Alert tone="warning" title="Hələ təklif gəlməyib">
          Təchizatçıların təklifi «Təkliflər» ekranından daxil edilir. Müqayisə ən azı bir təklifdən
          sonra mümkündür.
        </Alert>
      ) : null}

      <Card>
        <MetaGrid columns={6}>
          <Meta
            label="Sənəd tarixi"
            value={<span className="wms-num">{formatDate(doc.docDate)}</span>}
          />
          <Meta
            label="Cavab son tarixi"
            value={<span className="wms-num">{doc.dueDate ? formatDate(doc.dueDate) : '—'}</span>}
          />
          <Meta label="Təchizatçı sayı" value={String(doc.supplierCount)} />
          <Meta label="Gələn təklif" value={String(doc.quotationCount)} />
          <Meta
            label="Seçilmiş təklif"
            value={doc.selectedQuotationId ? `#${doc.selectedQuotationId}` : '—'}
          />
          <Meta label="Qeyd" value={doc.note ?? '—'} />
        </MetaGrid>
      </Card>

      <Card title="Dəvət edilən təchizatçılar">
        <div className="wms-row">
          {(doc.suppliers ?? []).map((supplier) => (
            <Badge key={supplier.id} tone="neutral" title={supplier.code}>
              {supplier.name}
            </Badge>
          ))}
          {(doc.suppliers ?? []).length === 0 ? (
            <span className="wms-muted">Təchizatçı yoxdur.</span>
          ) : null}
        </div>
      </Card>

      <Card
        title="RFQ sətirləri"
        actions={
          isSent && can('proc.quotation.create') ? (
            <Link
              to={`/procurement/quotations/new?rfqId=${doc.id}`}
              className="wms-btn wms-btn--secondary"
            >
              Təklif daxil et
            </Link>
          ) : null
        }
      >
        <DataTable<Line>
          columns={columns}
          rows={doc.lines ?? []}
          rowKey={(row) => row.id}
          empty="Sətir yoxdur."
        />
      </Card>

      <Dialog
        open={action !== null}
        title={action === 'send' ? 'RFQ-nu təchizatçılara göndərim?' : 'RFQ-nu bağlayım?'}
        subtitle={
          action === 'send'
            ? `${doc.supplierCount} təchizatçı təklif verə biləcək.`
            : 'Bağlandıqdan sonra yeni təklif qəbul edilmir; müqayisə mövcud təkliflər üzrə aparılır.'
        }
        onClose={run.isPending ? undefined : () => setAction(null)}
        footer={
          <>
            <Button disabled={run.isPending} onClick={() => setAction(null)}>
              İmtina
            </Button>
            <Button variant="primary" loading={run.isPending} onClick={() => run.mutate()}>
              {action === 'send' ? 'Göndər' : 'Bağla'}
            </Button>
          </>
        }
      >
        <span>
          <span className="wms-doc-no">{doc.docNo}</span> — {doc.lines?.length ?? 0} sətir.
        </span>
      </Dialog>
    </DocumentPage>
  );
}

const STATUS_NOTES: Record<string, string> = {
  CLOSED: 'Bağlanıb',
  CANCELLED: 'Ləğv edilib',
};
