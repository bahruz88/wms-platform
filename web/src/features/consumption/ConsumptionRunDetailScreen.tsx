import { useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Alert,
  Badge,
  Button,
  DataTable,
  Dialog,
  DocStatusBadge,
  Select,
  TextField,
  type Column,
} from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  calculateConsumptionRun,
  getConsumptionRun,
  listReasonCodes,
  postConsumptionRun,
  reverseConsumptionRun,
  type ConsumptionRunDetail,
  type ConsumptionRunLine,
  type ReasonCode,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate, formatDateTime, formatMoney } from '@core/format';
import { Money } from '@core/decimal';
import { DocNo, ErrorState, KeyValue, LoadingState, Page, Section } from '@/components/Page';

/**
 * One consumption document — calculate / post / reverse.
 *
 * Three rules from ADR-012 and the spec drive the buttons:
 *   · calculate is idempotent and changes no stock; post writes the `CONSUMPTION` movement group;
 *   · a posted document is never edited — the only correction is a reversal, which creates a new
 *     group and requires a reason code (SPEC §9.4, §12.6);
 *   · `unitCost` and `costAmount` are left out of the JSON entirely for a user without
 *     `master.product.view_cost`, so the columns are permission-bound here too.
 */
export function ConsumptionRunDetailScreen() {
  const { id } = useParams();
  const runId = Number(id);
  const { session, can } = useAuth();
  const queryClient = useQueryClient();
  const [action, setAction] = useState<'calculate' | 'post' | 'reverse' | null>(null);
  const [reasonCodeId, setReasonCodeId] = useState('');
  const [note, setNote] = useState('');

  const run = useApiQuery<ConsumptionRunDetail>(['run', runId], () => getConsumptionRun(runId));
  const reasons = useApiPage<ReasonCode>(
    ['reason-codes', 'adjustment'],
    () => listReasonCodes({ reasonGroup: 'ADJUSTMENT' }),
    200,
    { enabled: action === 'reverse' },
  );

  const invalidate = () => {
    setAction(null);
    void queryClient.invalidateQueries({ queryKey: ['run', runId] });
  };

  const calculate = useMutation({
    mutationFn: () => calculateConsumptionRun(runId, run.data?.rowVersion ?? 1),
    onSuccess: invalidate,
  });
  const post = useMutation({
    mutationFn: () => postConsumptionRun(runId, run.data?.rowVersion ?? 1),
    onSuccess: invalidate,
  });
  const reverse = useMutation({
    mutationFn: () =>
      reverseConsumptionRun(
        runId,
        run.data?.rowVersion ?? 1,
        Number(reasonCodeId),
        note.trim() || undefined,
      ),
    onSuccess: invalidate,
  });

  if (run.isLoading) return <LoadingState />;
  if (run.isError) return <ErrorState error={run.error} onRetry={() => void run.refetch()} />;
  const doc = run.data;
  if (!doc) return null;

  const pending = calculate.isPending || post.isPending || reverse.isPending;
  const mutationError = calculate.error ?? post.error ?? reverse.error;

  const columns: Column<ConsumptionRunLine>[] = [
    {
      key: 'productSku',
      header: 'SKU',
      render: (row) => <span className="wms-doc-no">{row.productSku}</span>,
    },
    { key: 'productName', header: 'Məhsul' },
    { key: 'theoreticalQtyBase', header: 'Nəzəri (base)', numeric: true, decimals: 4 },
    { key: 'postedQtyBase', header: 'Çıxarılan', numeric: true, decimals: 4 },
    {
      key: 'shortfallQtyBase',
      header: 'Çatışmazlıq',
      numeric: true,
      decimals: 4,
      render: (row) =>
        row.shortfallQtyBase &&
        row.shortfallQtyBase !== '0.0000' &&
        row.shortfallQtyBase !== '0' ? (
          <Badge tone="danger" title="Qalıq çatmadı — qəbul qeyd olunmayıb">
            {row.shortfallQtyBase}
          </Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    { key: 'baseUomCode', header: 'Vahid', width: '70px' },
    {
      key: 'unitCost',
      header: 'Vahid dəyəri',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
    {
      key: 'costAmount',
      header: 'Dəyər (AZN)',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
  ];

  const canCalculate =
    can('cons.run.calculate') && (doc.status === 'DRAFT' || doc.status === 'CALCULATED');
  const canPost = can('cons.run.post') && doc.status === 'CALCULATED';
  const canReverse = can('inv.movement.reverse') && doc.status === 'POSTED';

  return (
    <Page
      title={<DocNo value={doc.docNo} />}
      subtitle="İstehlak sənədi"
      actions={
        <>
          <DocStatusBadge status={doc.status} />
          <Button
            disabled={!canCalculate}
            title={
              !can('cons.run.calculate')
                ? '`cons.run.calculate` icazəniz yoxdur'
                : !canCalculate
                  ? `Bu statusda hesablama mümkün deyil (${doc.status})`
                  : undefined
            }
            onClick={() => setAction('calculate')}
          >
            Hesabla
          </Button>
          <Button
            variant="primary"
            disabled={!canPost}
            title={
              !can('cons.run.post')
                ? '`cons.run.post` icazəniz yoxdur'
                : !canPost
                  ? 'Yalnız hesablanmış sənəd post edilir'
                  : undefined
            }
            onClick={() => setAction('post')}
          >
            Post et
          </Button>
          <Button
            variant="danger"
            disabled={!canReverse}
            title={
              !can('inv.movement.reverse')
                ? '`inv.movement.reverse` icazəniz yoxdur'
                : !canReverse
                  ? 'Yalnız post edilmiş sənəd storno edilir'
                  : undefined
            }
            onClick={() => {
              setReasonCodeId('');
              setNote('');
              setAction('reverse');
            }}
          >
            Storno et
          </Button>
        </>
      }
    >
      {mutationError ? <ErrorState error={mutationError} /> : null}
      {doc.failureReason ? (
        <Alert tone="danger" title="Hesablama uğursuz oldu" code="CALCULATION_FAILED">
          {doc.failureReason}
        </Alert>
      ) : null}
      {doc.shortfallCount > 0 ? (
        <Alert tone="warning" title={`${doc.shortfallCount} sətirdə qalıq çatmadı`}>
          Nəzəri istehlakın bir hissəsi stokdan çıxarıla bilmədi. Ən çox rast gəlinən səbəb qeyd
          olunmayan qəbuldur — qəbul sənədlərini yoxlayın.
        </Alert>
      ) : null}
      {doc.unmappedCount > 0 ? (
        <Alert tone="warning" title={`${doc.unmappedCount} satış sətri istehlaka düşmədi`}>
          POS kodu bağlanmayıb və ya menyu maddəsinin aktiv resepti yoxdur.
        </Alert>
      ) : null}
      {doc.status === 'POSTED' ? (
        <Alert tone="info" title="Post edilmiş sənəd redaktə olunmur">
          Düzəliş yalnız «Storno et» ilə olur və o, yeni hərəkət qrupu yaradır (SPEC §9.4).
        </Alert>
      ) : null}

      <Section title="Başlıq">
        <div className="wms-card">
          <KeyValue
            items={[
              ['Sənəd nömrəsi', <DocNo key="d" value={doc.docNo} />],
              ['İş günü', formatDate(doc.businessDate)],
              ['Lokasiya', doc.locationName ?? `#${doc.locationId}`],
              [
                'Satış importu',
                doc.salesImportId ? (
                  <Link key="s" to={`/consumption/sales-imports/${doc.salesImportId}`}>
                    {`#${doc.salesImportId}`}
                  </Link>
                ) : (
                  '—'
                ),
              ],
              ['Hesablanıb', formatDateTime(doc.calculatedAt)],
              ['Post edilib', formatDateTime(doc.postedAt)],
              [
                'Hərəkət qrupu',
                doc.movementGroupId ? (
                  <Link key="m" to={`/inventory/movement-groups/${doc.movementGroupId}`}>
                    {`#${doc.movementGroupId}`}
                  </Link>
                ) : (
                  '—'
                ),
              ],
              ...(can('master.product.view_cost') && doc.totalCostAmount
                ? ([
                    [
                      'Ümumi dəyər',
                      <span key="t" className="wms-num">
                        {formatMoney(Money.parse(doc.totalCostAmount, 'AZN'), 4)}
                      </span>,
                    ],
                  ] as Array<[React.ReactNode, React.ReactNode]>)
                : []),
              [
                'rowVersion',
                <span key="rv" className="wms-num">
                  {doc.rowVersion}
                </span>,
              ],
            ]}
          />
        </div>
      </Section>

      <Section title="Sətirlər">
        <DataTable<ConsumptionRunLine>
          columns={columns}
          rows={doc.lines ?? []}
          permissions={session?.permissions ?? []}
          rowKey={(row) => row.productId}
          label="İstehlak sətirləri"
          empty="Sətir yoxdur. Sənədi hesablayın — reseptlərdən nəzəri istehlak yaranacaq."
        />
      </Section>

      <Dialog
        open={action !== null}
        title={
          action === 'calculate'
            ? 'Sənədi hesablayım?'
            : action === 'post'
              ? 'Sənədi post edim?'
              : 'Sənədi storno edim?'
        }
        subtitle={
          action === 'calculate'
            ? 'Hesablama stokdan heç nə çıxarmır — yalnız nəzəri tələbi yazır.'
            : action === 'post'
              ? 'Post `CONSUMPTION` hərəkət qrupu yaradır və balansı azaldır.'
              : 'Storno yeni hərəkət qrupu yaradır; səbəb kodu məcburidir.'
        }
        onClose={pending ? undefined : () => setAction(null)}
        footer={
          <>
            <Button
              disabled={pending}
              title={pending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setAction(null)}
            >
              İmtina
            </Button>
            {action === 'calculate' ? (
              <Button
                variant="primary"
                loading={calculate.isPending}
                onClick={() => calculate.mutate()}
              >
                Hesabla
              </Button>
            ) : action === 'post' ? (
              <Button variant="primary" loading={post.isPending} onClick={() => post.mutate()}>
                Post et
              </Button>
            ) : (
              <Button
                variant="danger"
                loading={reverse.isPending}
                disabled={!reasonCodeId}
                title={!reasonCodeId ? 'Səbəb kodu məcburidir' : undefined}
                onClick={() => reverse.mutate()}
              >
                Storno et
              </Button>
            )}
          </>
        }
      >
        <div className="wms-stack">
          <span>
            <DocNo value={doc.docNo} /> — {doc.locationName}, {formatDate(doc.businessDate)}.
          </span>
          {action === 'reverse' ? (
            <>
              <Select
                label="Səbəb kodu"
                required
                value={reasonCodeId}
                placeholder="Səbəb seçin"
                hint="Siyahı `ADJUSTMENT` qrupu ilə filtrlənir."
                error={reasonCodeId ? undefined : 'Storno üçün səbəb kodu məcburidir (SPEC §12.6).'}
                options={(reasons.data?.items ?? []).map((r) => ({
                  value: String(r.id),
                  label: `${r.code} · ${r.name}`,
                }))}
                onChange={(e) => setReasonCodeId(e.target.value)}
              />
              <TextField
                label="Qeyd"
                value={note}
                hint="Audit jurnalında saxlanılır."
                onChange={(e) => setNote(e.target.value)}
              />
            </>
          ) : null}
        </div>
      </Dialog>
    </Page>
  );
}
