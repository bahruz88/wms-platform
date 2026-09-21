import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Dialog, type Column } from '@ds/index';
import { useApiQuery } from '@api/hooks';
import { getSample, postSample, type Sample, type WasteLine } from '@api/endpoints';
import { useAuth } from '@auth/index';
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

/**
 * Sample (AQTA and other authorities) — docs/ux/screen-map.md §3.10.
 *
 * A sample has no approval step: `DRAFT → POSTED` in one action, which writes the `SAMPLE`
 * movement group. The service enforces `inv.sample.create` on the post operation, not a separate
 * `inv.sample.post` (`InventoryPermissions.cs`), so that is what the button checks.
 */
export function SampleDetailScreen() {
  const { id } = useParams();
  const sampleId = Number(id);
  const { session, can } = useAuth();
  const queryClient = useQueryClient();
  const [postOpen, setPostOpen] = useState(false);

  const sample = useApiQuery<Sample>(['sample', sampleId], () => getSample(sampleId));

  const post = useMutation({
    mutationFn: () => postSample(sampleId, sample.data?.rowVersion ?? 1),
    onSuccess: () => {
      setPostOpen(false);
      void queryClient.invalidateQueries({ queryKey: ['sample', sampleId] });
      void queryClient.invalidateQueries({ queryKey: ['samples'] });
    },
  });

  if (sample.isLoading) return <LoadingState />;
  if (sample.isError)
    return (
      <DocumentPage breadcrumb="Anbar · Nümunə" docNo={`#${sampleId}`}>
        <ErrorState error={sample.error} onRetry={() => void sample.refetch()} />
      </DocumentPage>
    );
  const doc = sample.data;
  if (!doc) return null;

  const isDraft = doc.status === 'DRAFT';

  const columns: Column<WasteLine>[] = [
    { key: 'lineNo', header: '#', numeric: true, decimals: 0, width: '44px' },
    {
      key: 'product',
      header: 'Məhsul',
      render: (row) => <ProductCell name={row.product.name} sku={row.product.sku} />,
    },
    {
      key: 'batchNo',
      header: 'Partiya',
      width: '140px',
      render: (row) =>
        row.batch ? (
          <span className="wms-num wms-small">{row.batch.batchNo}</span>
        ) : (
          <span className="wms-muted wms-small">partiyasız</span>
        ),
    },
    {
      key: 'qty',
      header: 'Miqdar',
      width: '150px',
      numeric: true,
      render: (row) => `${formatNumber(row.qty, 4)} ${row.uomCode}`,
    },
    { key: 'qtyBase', header: 'Baza miqdarı', width: '140px', numeric: true, decimals: 4 },
    {
      key: 'totalValue',
      header: 'Dəyər, AZN',
      width: '130px',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
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
          <Link to="/inventory/balances">Anbar</Link> · <Link to="/inventory/samples">Nümunə</Link>
        </>
      }
      docNo={doc.docNo}
      status={doc.status}
      badges={
        <Badge tone="neutral" variant="outline">
          {doc.authority}
        </Badge>
      }
      context={`${doc.lines.length} sətir · ${doc.location.name}`}
      actions={
        <>
          <Button variant="ghost" onClick={() => window.print()}>
            Çap et
          </Button>
          {isDraft ? (
            can('inv.sample.create') ? (
              <Button variant="primary" onClick={() => setPostOpen(true)}>
                Post et
              </Button>
            ) : (
              <Button disabled title="`inv.sample.create` icazəniz yoxdur">
                Post et
              </Button>
            )
          ) : (
            <Badge tone="neutral" title="SPEC §9.4">
              Post edilmiş sənəd redaktə olunmur
            </Badge>
          )}
        </>
      }
    >
      {post.isError ? <ErrorState error={post.error} /> : null}
      {post.isSuccess ? (
        <Alert tone="success" title={`Post edildi — ${doc.docNo}`}>
          `SAMPLE` qrupu yazıldı; nümunə balansdan çıxdı.
        </Alert>
      ) : null}

      <Card>
        <MetaGrid columns={6}>
          <Meta
            label="Sənəd tarixi"
            value={<span className="wms-num">{formatDate(doc.docDate)}</span>}
          />
          <Meta label="Lokasiya" value={doc.location.name} sub={doc.location.code} />
          <Meta label="Orqan" value={doc.authority} />
          <Meta label="Məqsəd" value={doc.purpose ?? '—'} />
          <Meta
            label="Akt / protokol"
            value={
              (doc.attachmentIds ?? []).length > 0 ? (
                <span className="wms-num">{(doc.attachmentIds ?? []).length}</span>
              ) : (
                <span className="wms-muted">yoxdur</span>
              )
            }
          />
          <Meta
            label="Hərəkət qrupu"
            value={
              doc.movementGroupId ? (
                <Link to={`/inventory/movement-groups/${doc.movementGroupId}`} className="wms-num">
                  #{doc.movementGroupId}
                </Link>
              ) : (
                '—'
              )
            }
          />
        </MetaGrid>
      </Card>

      <Card title="Nümunə sətirləri" flush>
        <DataTable<WasteLine>
          columns={columns}
          rows={doc.lines}
          permissions={session?.permissions ?? []}
          rowKey={(row) => row.id}
          label="Nümunə sətirləri"
          empty="Bu sənəddə sətir yoxdur. Nümunə sətirləri mobil tətbiqdə qeyd olunur."
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
          <Meta label="Səbəb kodu" value={doc.reasonCodeId ? `#${doc.reasonCodeId}` : '—'} />
          <Meta label="rowVersion" value={<span className="wms-num">{doc.rowVersion}</span>} />
        </MetaGrid>
      </Card>

      <Dialog
        open={postOpen}
        title="Nümunəni post edim?"
        subtitle="Nümunə təsdiq addımı olmadan birbaşa post edilir."
        onClose={post.isPending ? undefined : () => setPostOpen(false)}
        footer={
          <>
            <Button
              disabled={post.isPending}
              title={post.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setPostOpen(false)}
            >
              İmtina
            </Button>
            <Button variant="primary" loading={post.isPending} onClick={() => post.mutate()}>
              Post et
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          <span>
            <span className="wms-doc-no">{doc.docNo}</span> — {doc.lines.length} sətir,{' '}
            {doc.authority} üçün.
          </span>
          <Alert tone="info" title="Post geri alınmır">
            Lokasiyadan −miqdar, `V_SAMPLE` üzərinə +miqdar yazılır. Düzəliş yalnız storno ilə
            mümkündür (SPEC §9.4).
          </Alert>
        </div>
      </Dialog>
    </DocumentPage>
  );
}
