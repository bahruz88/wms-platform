import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Dialog, type Column } from '@ds/index';
import { useApiQuery } from '@api/hooks';
import {
  cancelStockRequest,
  getStockRequest,
  submitStockRequest,
  type StockRequest,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { Decimal } from '@core/decimal';
import { formatDate, formatDateTime, formatNumber } from '@core/format';
import {
  Card,
  DocumentPage,
  ErrorState,
  LoadingState,
  Meta,
  MetaGrid,
  ProductCell,
} from '@/components/Page';

type Line = StockRequest['lines'][number];

/**
 * Stock request document — docs/ux/screen-map.md §3.5.
 *
 * The branch writes the request, the warehouse fulfils it. Both sides read this screen, so the
 * per-line «Qalıq» column — requested minus already issued — is the important one: it is what
 * tells the keeper whether the request is done, and it is computed through `Decimal`, never
 * through floats.
 *
 * `submit` and `cancel` are both `inv.request.create` on the service.
 */
export function StockRequestDetailScreen() {
  const { id } = useParams();
  const requestId = Number(id);
  const { can } = useAuth();
  const queryClient = useQueryClient();
  const [action, setAction] = useState<'submit' | 'cancel' | null>(null);

  const request = useApiQuery<StockRequest>(['stock-request', requestId], () =>
    getStockRequest(requestId),
  );

  const rowVersion = request.data?.rowVersion ?? 1;

  const run = useMutation({
    mutationFn: () =>
      action === 'submit'
        ? submitStockRequest(requestId, rowVersion)
        : cancelStockRequest(requestId, rowVersion),
    onSuccess: () => {
      setAction(null);
      void queryClient.invalidateQueries({ queryKey: ['stock-request', requestId] });
      void queryClient.invalidateQueries({ queryKey: ['stock-requests'] });
    },
  });

  if (request.isLoading) return <LoadingState />;
  if (request.isError)
    return (
      <DocumentPage breadcrumb="Anbar · Mal tələbi" docNo={`#${requestId}`}>
        <ErrorState error={request.error} onRetry={() => void request.refetch()} />
      </DocumentPage>
    );
  const doc = request.data;
  if (!doc) return null;

  const isDraft = doc.status === 'DRAFT';
  const isOpen = ['SUBMITTED', 'PICKING', 'PARTIALLY_ISSUED'].includes(doc.status);
  const isFinished = ['ISSUED', 'CLOSED', 'CANCELLED'].includes(doc.status);

  const remaining = (line: Line): string | null => {
    try {
      return new Decimal(line.qty).minus(new Decimal(line.issuedQty ?? '0')).toString();
    } catch {
      return null;
    }
  };

  const columns: Column<Line>[] = [
    { key: 'lineNo', header: '#', numeric: true, decimals: 0, width: '44px' },
    {
      key: 'product',
      header: 'Məhsul',
      render: (row) => <ProductCell name={row.product.name} sku={row.product.sku} />,
    },
    {
      key: 'qty',
      header: 'Tələb olunan',
      width: '150px',
      numeric: true,
      render: (row) => `${formatNumber(row.qty, 4)} ${row.uomCode}`,
    },
    {
      key: 'issuedQty',
      header: 'Məxaric edilib',
      width: '150px',
      numeric: true,
      render: (row) => `${formatNumber(row.issuedQty ?? '0', 4)} ${row.uomCode}`,
    },
    {
      key: 'remaining',
      header: 'Qalıq',
      width: '150px',
      numeric: true,
      render: (row) => {
        const left = remaining(row);
        if (left === null) return <span className="wms-muted">—</span>;
        const done = left === '0';
        return done ? (
          <Badge tone="success">Tam verilib</Badge>
        ) : (
          <span className="wms-num">
            {formatNumber(left, 4)} {row.uomCode}
          </span>
        );
      },
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
          <Link to="/inventory/balances">Anbar</Link> ·{' '}
          <Link to="/inventory/stock-requests">Mal tələbi</Link>
        </>
      }
      docNo={doc.docNo}
      status={doc.status}
      context={`${doc.fromLocation.name} → ${doc.toLocation.name}`}
      actions={
        <>
          <Button variant="ghost" onClick={() => window.print()}>
            Çap et
          </Button>
          {isDraft || isOpen ? (
            can('inv.request.create') ? (
              <Button variant="secondary" onClick={() => setAction('cancel')}>
                Ləğv et
              </Button>
            ) : null
          ) : null}
          {isDraft ? (
            can('inv.request.create') ? (
              <Button variant="primary" onClick={() => setAction('submit')}>
                Təsdiqə göndər
              </Button>
            ) : (
              <Button disabled title="`inv.request.create` icazəniz yoxdur">
                Təsdiqə göndər
              </Button>
            )
          ) : isOpen && can('inv.issue.create') ? (
            <Link
              to={`/inventory/issues/new?requestId=${doc.id}&fromLocationId=${doc.fromLocation.id}&toLocationId=${doc.toLocation.id}`}
              className="wms-btn wms-btn--primary"
            >
              Məxaric yarat
            </Link>
          ) : isFinished ? (
            <Badge tone="neutral">Tələb bağlanıb</Badge>
          ) : (
            <Button disabled title="`inv.issue.create` icazəniz yoxdur">
              Məxaric yarat
            </Button>
          )}
        </>
      }
    >
      {run.isError ? <ErrorState error={run.error} /> : null}
      {isDraft ? (
        <Alert tone="info" title="Qaralama anbara görünmür">
          Tələb yalnız «Təsdiqə göndər» addımından sonra anbarın növbəsinə düşür.
        </Alert>
      ) : null}

      <Card>
        <MetaGrid columns={6}>
          <Meta
            label="Sənəd tarixi"
            value={<span className="wms-num">{formatDate(doc.docDate)}</span>}
          />
          <Meta label="Haradan" value={doc.fromLocation.name} sub={doc.fromLocation.code} />
          <Meta label="Hara" value={doc.toLocation.name} sub={doc.toLocation.code} />
          <Meta
            label="Tələb olunan tarix"
            value={
              <span className="wms-num">
                {doc.requiredDate ? formatDate(doc.requiredDate) : '—'}
              </span>
            }
          />
          <Meta
            label="Məxaric sənədləri"
            value={
              (doc.issueIds ?? []).length === 0 ? (
                <span className="wms-muted">yoxdur</span>
              ) : (
                <span className="wms-row">
                  {(doc.issueIds ?? []).map((issueId) => (
                    <Link key={issueId} to={`/inventory/issues/${issueId}`} className="wms-num">
                      #{issueId}
                    </Link>
                  ))}
                </span>
              )
            }
          />
          <Meta label="Qeyd" value={doc.note ?? '—'} />
        </MetaGrid>
      </Card>

      <Card title="Tələb sətirləri" flush>
        <DataTable<Line>
          columns={columns}
          rows={doc.lines}
          rowKey={(row) => row.id}
          label="Tələb sətirləri"
          empty="Bu tələbdə sətir yoxdur."
        />
      </Card>

      <Card title="Sənəd izi">
        <MetaGrid columns={4}>
          <Meta
            label="Yaradılıb"
            value={
              <span className="wms-num">
                {doc.audit?.createdAt ? formatDateTime(doc.audit.createdAt) : '—'}
              </span>
            }
          />
          <Meta
            label="Yenilənib"
            value={
              <span className="wms-num">
                {doc.audit?.updatedAt ? formatDateTime(doc.audit.updatedAt) : '—'}
              </span>
            }
          />
          <Meta label="Sətir sayı" value={<span className="wms-num">{doc.lines.length}</span>} />
          <Meta label="rowVersion" value={<span className="wms-num">{doc.rowVersion}</span>} />
        </MetaGrid>
      </Card>

      <Dialog
        open={action !== null}
        title={action === 'submit' ? 'Tələbi göndərim?' : 'Tələbi ləğv edim?'}
        subtitle={
          action === 'submit'
            ? 'Tələb anbarın növbəsinə düşür; sətirlər bundan sonra dəyişmir.'
            : 'Ləğv edilmiş tələb üzrə məxaric yaradıla bilməz.'
        }
        onClose={run.isPending ? undefined : () => setAction(null)}
        footer={
          <>
            <Button
              disabled={run.isPending}
              title={run.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setAction(null)}
            >
              İmtina
            </Button>
            <Button
              variant={action === 'cancel' ? 'danger' : 'primary'}
              loading={run.isPending}
              onClick={() => run.mutate()}
            >
              {action === 'submit' ? 'Göndər' : 'Ləğv et'}
            </Button>
          </>
        }
      >
        <span>
          <span className="wms-doc-no">{doc.docNo}</span> — {doc.lines.length} sətir,{' '}
          {doc.fromLocation.name} → {doc.toLocation.name}.
        </span>
      </Dialog>
    </DocumentPage>
  );
}
