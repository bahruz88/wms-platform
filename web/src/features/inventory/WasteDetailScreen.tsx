import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Dialog, TextField, type Column } from '@ds/index';
import { useApiQuery } from '@api/hooks';
import {
  decideWaste,
  getWaste,
  postWaste,
  submitWaste,
  type Waste,
  type WasteLine,
} from '@api/endpoints';
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
 * Waste document — docs/ux/screen-map.md §3.9, the screen the dashboard's pending-approval link
 * for a `WASTE` document lands on (`/inventory/waste/:id`).
 *
 * The web side is approval and control, which is exactly the part that was missing: the list
 * screen said so in its own comment while offering no way to open a document, so a keeper could
 * neither send a draft for approval nor a manager decide one. The whole cycle the backend serves
 * is here:
 *
 *   `DRAFT → PENDING_APPROVAL` — `inv.waste.create`, the creator's own action;
 *   `PENDING_APPROVAL → APPROVED | REJECTED` — `inv.waste.approve`, and **never the creator**
 *     (self-approval is forbidden, SPEC §7.1 / §12.6);
 *   `APPROVED → POSTED` — `inv.waste.post`, writes the `WASTE` movement group.
 *
 * `totalValue` and `unitCost` are permission-bound: without `master.product.view_cost` the
 * columns are absent, not masked (SPEC §16).
 */
export function WasteDetailScreen() {
  const { id } = useParams();
  const wasteId = Number(id);
  const { session, can } = useAuth();
  const queryClient = useQueryClient();
  const [action, setAction] = useState<'submit' | 'approve' | 'reject' | 'post' | null>(null);
  const [comment, setComment] = useState('');

  const waste = useApiQuery<Waste>(['waste', wasteId], () => getWaste(wasteId));

  const invalidate = () => {
    setAction(null);
    setComment('');
    void queryClient.invalidateQueries({ queryKey: ['waste', wasteId] });
    void queryClient.invalidateQueries({ queryKey: ['waste'] });
  };

  const rowVersion = waste.data?.rowVersion ?? 1;

  const run = useMutation({
    mutationFn: () => {
      switch (action) {
        case 'submit':
          return submitWaste(wasteId, rowVersion);
        case 'approve':
          return decideWaste(wasteId, rowVersion, 'APPROVED', comment.trim() || undefined);
        case 'reject':
          return decideWaste(wasteId, rowVersion, 'REJECTED', comment.trim());
        case 'post':
          return postWaste(wasteId, rowVersion);
        default:
          return Promise.reject(new Error('Əməliyyat seçilməyib'));
      }
    },
    onSuccess: invalidate,
  });

  if (waste.isLoading) return <LoadingState />;
  if (waste.isError)
    return (
      <DocumentPage breadcrumb="Anbar · Tullantı" docNo={`#${wasteId}`}>
        <ErrorState error={waste.error} onRetry={() => void waste.refetch()} />
      </DocumentPage>
    );
  const doc = waste.data;
  if (!doc) return null;

  const canViewCost = can('master.product.view_cost');
  const isDraft = doc.status === 'DRAFT';
  const isPending = doc.status === 'PENDING_APPROVAL';
  const isApproved = doc.status === 'APPROVED';
  const isPosted = doc.status === 'POSTED';

  // SoD: the person who wrote the document may not decide it. `createdBy` is 0 until the JWT
  // carries the internal user id, so the rule cannot be enforced here yet — say so rather than
  // pretend it is being applied.
  const createdBy = doc.audit?.createdBy ?? 0;
  const selfApprovalUnknown = createdBy === 0;

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
      key: 'expiryDate',
      header: 'Son istifadə',
      width: '120px',
      render: (row) => (
        <span className="wms-num wms-small">{formatDate(row.batch?.expiryDate)}</span>
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
      key: 'unitCost',
      header: 'Vahid dəyəri',
      width: '130px',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
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
          <Link to="/inventory/balances">Anbar</Link> · <Link to="/inventory/waste">Tullantı</Link>
        </>
      }
      docNo={doc.docNo}
      status={doc.status}
      badges={
        <Badge tone="neutral" variant="outline" title={`reasonCodeId = ${doc.reasonCodeId}`}>
          {doc.reasonCodeName}
        </Badge>
      }
      context={`${doc.lines.length} sətir · ${doc.location.name}`}
      actions={
        <>
          <Button variant="ghost" onClick={() => window.print()}>
            Çap et
          </Button>
          {isDraft ? (
            can('inv.waste.create') ? (
              <Button variant="primary" onClick={() => setAction('submit')}>
                Təsdiqə göndər
              </Button>
            ) : (
              <Button disabled title="`inv.waste.create` icazəniz yoxdur">
                Təsdiqə göndər
              </Button>
            )
          ) : null}
          {isPending ? (
            can('inv.waste.approve') ? (
              <>
                <Button
                  variant="danger"
                  onClick={() => {
                    setAction('reject');
                    setComment('');
                  }}
                >
                  Rədd et
                </Button>
                <Button
                  variant="primary"
                  onClick={() => {
                    setAction('approve');
                    setComment('');
                  }}
                >
                  Təsdiqlə
                </Button>
              </>
            ) : (
              <Button disabled title="`inv.waste.approve` icazəniz yoxdur">
                Təsdiqlə
              </Button>
            )
          ) : null}
          {isApproved ? (
            can('inv.waste.post') ? (
              <Button variant="primary" onClick={() => setAction('post')}>
                Post et
              </Button>
            ) : (
              <Button disabled title="`inv.waste.post` icazəniz yoxdur">
                Post et
              </Button>
            )
          ) : null}
          {isPosted ? (
            <Badge tone="neutral" title="SPEC §9.4">
              Post edilmiş sənəd redaktə olunmur
            </Badge>
          ) : null}
        </>
      }
    >
      {run.isError ? <ErrorState error={run.error} /> : null}
      {run.isSuccess ? (
        <Alert tone="success" title={`${doc.docNo} yeniləndi`}>
          Sənədin yeni statusu: <span className="wms-num">{doc.status}</span>.
        </Alert>
      ) : null}

      {isPending ? (
        <Alert tone="warning" title="Təsdiq gözləyir" code="APPROVAL_REQUIRED">
          Səbəb kodu <span className="wms-num">{doc.reasonCodeName}</span> təsdiq tələb edir.
          {selfApprovalUnknown
            ? ' Sənədi yazan istifadəçi token-də daşınmadığı üçün öz-özünü təsdiq qadağası bu ekranda yoxlanıla bilmir — qadağanı server tətbiq edir (SPEC §12.6).'
            : ' Sənədi yazan özü təsdiqləyə bilməz (SoD, SPEC §7.1).'}
        </Alert>
      ) : null}
      {doc.status === 'REJECTED' ? (
        <Alert tone="danger" title="Sənəd rədd edilib" code="REJECTED">
          {doc.approvalComment ?? 'Rədd şərhi yazılmayıb.'}
        </Alert>
      ) : null}

      <Card>
        <MetaGrid columns={6}>
          <Meta
            label="Sənəd tarixi"
            value={<span className="wms-num">{formatDate(doc.docDate)}</span>}
          />
          <Meta label="Lokasiya" value={doc.location.name} sub={doc.location.code} />
          <Meta label="Səbəb kodu" value={doc.reasonCodeName} sub={`#${doc.reasonCodeId}`} />
          {canViewCost ? (
            <Meta
              label="Ümumi dəyər"
              value={
                <span className="wms-num">
                  {doc.totalValue ? `${formatNumber(doc.totalValue, 4)} AZN` : '—'}
                </span>
              }
            />
          ) : (
            <Meta label="Sətir sayı" value={<span className="wms-num">{doc.lines.length}</span>} />
          )}
          <Meta
            label="Foto"
            value={
              doc.attachmentIds.length > 0 ? (
                <span className="wms-num">{doc.attachmentIds.length}</span>
              ) : (
                <span className="wms-muted">yoxdur</span>
              )
            }
            sub="requiresPhoto olduqda ən azı bir foto"
          />
          <Meta label="Qeyd" value={doc.note ?? '—'} />
        </MetaGrid>
      </Card>

      <Card title="Tullantı sətirləri" flush>
        <DataTable<WasteLine>
          columns={columns}
          rows={doc.lines}
          permissions={session?.permissions ?? []}
          rowKey={(row) => row.id}
          label="Tullantı sətirləri"
          empty="Bu sənəddə sətir yoxdur. Sətir mobil tətbiqdə foto ilə əlavə edilir."
        />
      </Card>

      <Card title="Sənəd izi" subtitle="Audit jurnalı bu sahələri saxlayır">
        <MetaGrid columns={4}>
          <Meta
            label="Təsdiq"
            value={
              <span className="wms-num">
                {doc.approvedAt ? formatDateTime(doc.approvedAt) : '—'}
              </span>
            }
            sub={doc.approvalComment ?? undefined}
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
          <Meta
            label="Yaradılıb"
            value={
              <span className="wms-num">
                {doc.audit?.createdAt ? formatDateTime(doc.audit.createdAt) : '—'}
              </span>
            }
          />
          <Meta label="rowVersion" value={<span className="wms-num">{doc.rowVersion}</span>} />
        </MetaGrid>
      </Card>

      <Dialog
        open={action !== null}
        title={DIALOG_TITLES[action ?? 'submit']}
        subtitle={DIALOG_SUBTITLES[action ?? 'submit']}
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
              variant={action === 'reject' ? 'danger' : 'primary'}
              loading={run.isPending}
              disabled={action === 'reject' && comment.trim().length === 0}
              title={
                action === 'reject' && comment.trim().length === 0
                  ? 'Rəddə şərh məcburidir'
                  : undefined
              }
              onClick={() => run.mutate()}
            >
              {DIALOG_CONFIRM[action ?? 'submit']}
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          <span>
            <span className="wms-doc-no">{doc.docNo}</span> — {doc.lines.length} sətir,{' '}
            {doc.location.name}.
          </span>
          {action === 'approve' || action === 'reject' ? (
            <TextField
              label="Şərh"
              required={action === 'reject'}
              value={comment}
              hint="Şərh audit jurnalına yazılır və sənədin üzərində görünür."
              error={
                action === 'reject' && comment.trim().length === 0
                  ? 'Rəddə şərh məcburidir.'
                  : undefined
              }
              onChange={(e) => setComment(e.target.value)}
            />
          ) : null}
          {action === 'post' ? (
            <Alert tone="info" title="Post geri alınmır">
              `WASTE` qrupu yazılacaq: lokasiyadan −miqdar, `V_WASTE` üzərinə +miqdar. Düzəliş
              yalnız storno ilə mümkündür (SPEC §9.4).
            </Alert>
          ) : null}
        </div>
      </Dialog>
    </DocumentPage>
  );
}

const DIALOG_TITLES: Record<'submit' | 'approve' | 'reject' | 'post', string> = {
  submit: 'Təsdiqə göndərim?',
  approve: 'Tullantını təsdiqləyim?',
  reject: 'Tullantını rədd edim?',
  post: 'Tullantını post edim?',
};

const DIALOG_SUBTITLES: Record<'submit' | 'approve' | 'reject' | 'post', string> = {
  submit: 'Sənəd `PENDING_APPROVAL` statusuna keçir; bundan sonra sətirlər dəyişmir.',
  approve: 'Təsdiqdən sonra sənəd post edilə bilər.',
  reject: 'Rədd edilmiş sənəd balansa düşmür; şərh tələbçiyə görünür.',
  post: 'Post edildikdən sonra sənəd redaktə olunmur — yalnız storno mümkündür.',
};

const DIALOG_CONFIRM: Record<'submit' | 'approve' | 'reject' | 'post', string> = {
  submit: 'Təsdiqə göndər',
  approve: 'Təsdiqlə',
  reject: 'Rədd et',
  post: 'Post et',
};
