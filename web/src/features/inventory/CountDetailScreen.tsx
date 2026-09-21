import { useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Alert,
  Badge,
  Button,
  DataTable,
  Dialog,
  KpiCard,
  TextField,
  VarianceIndicator,
  computeVariance,
  type Column,
} from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  decideCount,
  freezeCount,
  getCount,
  listInventorySettings,
  postCount,
  submitCount,
  type Count,
  type CountLine,
  type InventorySetting,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { Decimal } from '@core/decimal';
import { formatDateTime, formatNumber } from '@core/format';
import { Card, DocumentPage, ErrorState, LoadingState, ProductCell } from '@/components/Page';

/**
 * Stock count and its variances — docs/design-system/screens/Sayim.dc.html.
 *
 * The artboard's three load-bearing details:
 *   · the `LOCATION_FROZEN` alert with its code visible — support works with that string, so it
 *     is printed exactly as the server sends it (design-system README «Vəziyyətlər»);
 *   · a four-up KPI row;
 *   · the variance table with the danger badge in the card head counting the lines that still
 *     have no reason code, because a count cannot be sent for approval while any variance is
 *     unexplained (`422 REASON_CODE_REQUIRED`, SPEC §12.6).
 *
 * The state machine decides which button is primary, and only ever one:
 * `DRAFT → freeze`, `FROZEN/COUNTING → submit`, `REVIEW → approve`, `APPROVED → post`.
 */
const COUNT_TYPE_LABELS: Record<string, string> = {
  FULL: 'Tam sayım',
  CYCLE: 'Dövri sayım',
  SPOT: 'Nöqtəvi sayım',
};

const DEFAULT_VARIANCE_THRESHOLD_PCT = 2;

export function CountDetailScreen() {
  const { id } = useParams();
  const countId = Number(id);
  const { session, can } = useAuth();
  const queryClient = useQueryClient();
  const [decisionOpen, setDecisionOpen] = useState<'APPROVED' | 'REJECTED' | null>(null);
  const [comment, setComment] = useState('');
  const [confirmOpen, setConfirmOpen] = useState<'freeze' | 'submit' | 'post' | null>(null);

  const count = useApiQuery<Count>(['count', countId], () => getCount(countId));
  const settings = useApiPage<InventorySetting>(['settings', 'count'], listInventorySettings, 50, {
    retry: false,
  });

  const doc = count.data ?? null;

  const thresholdPct = useMemo(() => {
    const raw = (settings.data?.items ?? []).find(
      (s) => s.key === 'count_variance_approval_threshold_pct',
    )?.value;
    const parsed = raw === undefined ? Number.NaN : Number(raw);
    return Number.isFinite(parsed) ? parsed : DEFAULT_VARIANCE_THRESHOLD_PCT;
  }, [settings.data]);

  const invalidate = () => {
    setConfirmOpen(null);
    setDecisionOpen(null);
    void queryClient.invalidateQueries({ queryKey: ['count', countId] });
  };

  const freeze = useMutation({
    mutationFn: () => freezeCount(countId, doc?.rowVersion ?? 1),
    onSuccess: invalidate,
  });
  const submit = useMutation({
    mutationFn: () => submitCount(countId, doc?.rowVersion ?? 1),
    onSuccess: invalidate,
  });
  const decide = useMutation({
    mutationFn: () =>
      decideCount(
        countId,
        doc?.rowVersion ?? 1,
        decisionOpen ?? 'APPROVED',
        comment.trim() || undefined,
      ),
    onSuccess: invalidate,
  });
  const post = useMutation({
    mutationFn: () => postCount(countId, doc?.rowVersion ?? 1),
    onSuccess: invalidate,
  });

  const varianceLines = useMemo(
    () => (doc?.lines ?? []).filter((line) => !isZero(line.varianceQty)),
    [doc],
  );
  const missingReason = varianceLines.filter((line) => !line.reasonCodeId).length;
  const overThreshold = varianceLines.filter(
    (line) => line.exceedsThreshold || exceeds(line.variancePct, thresholdPct),
  ).length;
  const loadedCounted = (doc?.lines ?? []).filter(
    (line) => line.countedQty !== null && line.countedQty !== undefined,
  ).length;
  // `CountSummary` counts the whole document; the lines in hand may be one page of it.
  const countedLines = doc?.countedLineCount ?? loadedCounted;
  const varianceCount = doc?.varianceLineCount ?? varianceLines.length;
  const totalLines = doc?.lineCount ?? doc?.lines.length ?? 0;

  if (count.isLoading) return <LoadingState />;
  if (count.isError)
    return (
      <DocumentPage breadcrumb="Anbar · Sayım" docNo={`#${countId}`}>
        <ErrorState error={count.error} onRetry={() => void count.refetch()} />
      </DocumentPage>
    );
  if (!doc) return null;

  const frozen = ['FROZEN', 'COUNTING', 'REVIEW', 'APPROVED'].includes(doc.status);
  const canViewCost = can('master.product.view_cost');

  const columns: Column<CountLine>[] = [
    {
      key: 'product',
      header: 'Məhsul',
      render: (row) => <ProductCell name={row.product.name} sku={row.product.sku} />,
    },
    {
      key: 'batch',
      header: 'Partiya',
      width: '130px',
      render: (row) =>
        row.batch ? (
          <span className="wms-num wms-small">{row.batch.batchNo}</span>
        ) : (
          <span className="wms-muted wms-small">partiyasız</span>
        ),
    },
    {
      key: 'bookQty',
      header: 'Kitab qalığı',
      width: '140px',
      numeric: true,
      render: (row) => formatNumber(row.bookQty, 3),
    },
    {
      key: 'countedQty',
      header: 'Sayılan',
      width: '140px',
      numeric: true,
      render: (row) =>
        row.countedQty === null || row.countedQty === undefined ? (
          <span className="wms-muted">sayılmayıb</span>
        ) : (
          formatNumber(row.countedQty, 3)
        ),
    },
    {
      key: 'variance',
      header: 'Fərq',
      width: '330px',
      render: (row) =>
        row.countedQty === null || row.countedQty === undefined ? (
          <span className="wms-muted wms-small">—</span>
        ) : (
          <VarianceIndicator
            book={row.bookQty}
            counted={row.countedQty}
            uom={row.baseUomCode}
            decimals={3}
            thresholdPct={thresholdPct}
            reasonCode={row.reasonCodeId ? String(row.reasonCodeId) : undefined}
          />
        ),
    },
    {
      key: 'varianceValue',
      header: 'Dəyər, AZN',
      width: '120px',
      numeric: true,
      decimals: 2,
      permission: 'master.product.view_cost',
    },
  ];

  /** Exactly one primary, chosen by the state machine. */
  const primaryAction = (() => {
    if (doc.status === 'DRAFT') {
      return can('inv.count.freeze') ? (
        <Button variant="primary" onClick={() => setConfirmOpen('freeze')}>
          Lokasiyanı dondur
        </Button>
      ) : (
        <Button disabled title="`inv.count.freeze` icazəniz yoxdur">
          Lokasiyanı dondur
        </Button>
      );
    }
    if (doc.status === 'FROZEN' || doc.status === 'COUNTING') {
      const blocked = missingReason > 0 || loadedCounted === 0;
      return can('inv.count.enter') ? (
        <Button
          variant="primary"
          disabled={blocked}
          title={
            loadedCounted === 0
              ? 'Heç bir sətir sayılmayıb — sayım mobil tətbiqdə aparılır'
              : missingReason > 0
                ? `${missingReason} sətirdə səbəb kodu yoxdur`
                : undefined
          }
          onClick={() => setConfirmOpen('submit')}
        >
          Fərqləri təsdiqə göndər
        </Button>
      ) : (
        <Button disabled title="`inv.count.enter` icazəniz yoxdur">
          Fərqləri təsdiqə göndər
        </Button>
      );
    }
    if (doc.status === 'REVIEW') {
      return can('inv.adjustment.approve') ? (
        <Button
          variant="primary"
          onClick={() => {
            setComment('');
            setDecisionOpen('APPROVED');
          }}
        >
          Təsdiqlə
        </Button>
      ) : (
        <Button disabled title="`inv.adjustment.approve` icazəniz yoxdur (SoD, SPEC §7.1)">
          Təsdiqlə
        </Button>
      );
    }
    if (doc.status === 'APPROVED') {
      return can('inv.count.post') ? (
        <Button variant="primary" onClick={() => setConfirmOpen('post')}>
          Post et
        </Button>
      ) : (
        <Button disabled title="`inv.count.post` icazəniz yoxdur">
          Post et
        </Button>
      );
    }
    return (
      <Badge tone="neutral" title="SPEC §9.4">
        Sənəd bağlanıb — düzəliş storno ilə olur
      </Badge>
    );
  })();

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/inventory/balances">Anbar</Link> · <Link to="/inventory/counts">Sayım</Link>
        </>
      }
      docNo={doc.docNo}
      status={doc.status}
      badges={
        <Badge tone="neutral" variant="outline" title={doc.countType}>
          {COUNT_TYPE_LABELS[doc.countType] ?? doc.countType}
        </Badge>
      }
      context={`${doc.location.name}${doc.frozenAt ? ` · dondurulub ${formatDateTime(doc.frozenAt)}` : ''}`}
      actions={
        <>
          <Button variant="ghost" disabled title="Export `POST /reporting/exports` ilə işləyir">
            Excel-ə çıxar
          </Button>
          {doc.status === 'REVIEW' && can('inv.adjustment.approve') ? (
            <Button
              variant="danger"
              onClick={() => {
                setComment('');
                setDecisionOpen('REJECTED');
              }}
            >
              Yenidən say
            </Button>
          ) : null}
          {primaryAction}
        </>
      }
    >
      {[freeze, submit, decide, post].map((m, i) =>
        m.isError ? <ErrorState key={i} error={m.error} /> : null,
      )}

      {frozen ? (
        <Alert
          tone="warning"
          title={`${doc.location.name} lokasiyası dondurulub`}
          code="LOCATION_FROZEN"
        >
          Sayım tamamlanana qədər bu lokasiyada qəbul, məxaric, transfer, tullantı və nümunə
          əməliyyatları rədd edilir. Kitab qalığı dondurulma anında yazılıb
          {doc.frozenAt ? ` (${formatDateTime(doc.frozenAt)})` : ''}.
        </Alert>
      ) : null}

      <div className="wms-grid wms-grid--kpi">
        <KpiCard label="Sayılan sətir" value={countedLines} hint={`${totalLines} sətirdən`} />
        <KpiCard label="Fərqi olan sətir" value={varianceCount} />
        <KpiCard
          label="Həddi aşan fərq"
          value={overThreshold}
          hint={`count_variance_approval_threshold_pct = ${thresholdPct}`}
        />
        {canViewCost ? (
          <KpiCard
            label="Fərqin dəyəri"
            value={doc.totalVarianceValue ? formatNumber(doc.totalVarianceValue, 2) : '0,00'}
            unit="AZN"
            hint="anbar dəyərinə nisbətən"
          />
        ) : (
          <KpiCard
            label="Səbəbsiz fərq"
            value={missingReason}
            hint="səbəb kodu olmadan təsdiqə göndərilmir"
          />
        )}
      </div>

      <Card
        className="wms-card--fill"
        title="Fərqi olan sətirlər"
        subtitle="Fərq sıfırdan fərqlidirsə səbəb kodu məcburidir — onsuz sənəd təsdiqə göndərilmir"
        actions={
          missingReason > 0 ? (
            <Badge tone="danger" dot>
              {missingReason} sətirdə səbəb yoxdur
            </Badge>
          ) : varianceLines.length > 0 ? (
            <Badge tone="success" dot>
              Bütün fərqlərin səbəbi var
            </Badge>
          ) : undefined
        }
        flush
      >
        <DataTable<CountLine>
          columns={columns}
          rows={doc.lines}
          permissions={session?.permissions ?? []}
          rowKey={(row) => row.id}
          label="Sayım fərqləri"
          empty={
            doc.status === 'DRAFT'
              ? 'Sətirlər dondurma anında yaradılır. «Lokasiyanı dondur» ilə başlayın.'
              : 'Fərq yoxdur — sayılan miqdarlar kitab qalığı ilə üst-üstə düşür.'
          }
          footer={{
            product: `${doc.lines.length} sətir göstərilir`,
            ...(canViewCost && doc.totalVarianceValue
              ? { varianceValue: formatNumber(doc.totalVarianceValue, 2) }
              : {}),
          }}
        />
      </Card>

      <Dialog
        open={confirmOpen !== null}
        title={
          confirmOpen === 'freeze'
            ? 'Lokasiyanı dondurum?'
            : confirmOpen === 'submit'
              ? 'Fərqləri təsdiqə göndərim?'
              : 'Sayımı post edim?'
        }
        subtitle={
          confirmOpen === 'freeze'
            ? 'Dondurma anından bu lokasiyada bütün hərəkətlər 409 LOCATION_FROZEN alır.'
            : confirmOpen === 'submit'
              ? 'Həddi aşan fərqlər üçün approval instansı yaradılır.'
              : 'COUNT_ADJUST qrupu yazılır və lokasiya açılır. Post edilmiş sayım redaktə olunmur.'
        }
        onClose={() => setConfirmOpen(null)}
        footer={
          <>
            <Button onClick={() => setConfirmOpen(null)}>İmtina</Button>
            <Button
              variant="primary"
              loading={freeze.isPending || submit.isPending || post.isPending}
              onClick={() => {
                if (confirmOpen === 'freeze') freeze.mutate();
                else if (confirmOpen === 'submit') submit.mutate();
                else post.mutate();
              }}
            >
              {confirmOpen === 'freeze'
                ? 'Dondur'
                : confirmOpen === 'submit'
                  ? 'Göndər'
                  : 'Post et'}
            </Button>
          </>
        }
      >
        <span>
          <span className="wms-doc-no">{doc.docNo}</span> — {doc.location.name}, {doc.lines.length}{' '}
          sətir, {varianceLines.length} fərq.
        </span>
      </Dialog>

      <Dialog
        open={decisionOpen !== null}
        title={decisionOpen === 'APPROVED' ? 'Fərqləri təsdiqləyim?' : 'Yenidən sayılsın?'}
        subtitle={
          decisionOpen === 'REJECTED'
            ? 'Rədd sənədi COUNTING statusuna qaytarır; şərh məcburidir.'
            : 'Təsdiqdən sonra sənəd post edilə bilər.'
        }
        onClose={decide.isPending ? undefined : () => setDecisionOpen(null)}
        footer={
          <>
            <Button
              disabled={decide.isPending}
              title={decide.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setDecisionOpen(null)}
            >
              İmtina
            </Button>
            <Button
              variant={decisionOpen === 'REJECTED' ? 'danger' : 'primary'}
              loading={decide.isPending}
              disabled={decisionOpen === 'REJECTED' && comment.trim().length === 0}
              title={
                decisionOpen === 'REJECTED' && comment.trim().length === 0
                  ? 'Rəddə şərh məcburidir'
                  : undefined
              }
              onClick={() => decide.mutate()}
            >
              {decisionOpen === 'REJECTED' ? 'Yenidən say' : 'Təsdiqlə'}
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          <span>
            Sayımı aparan özü təsdiqləyə bilməz — server bunu `403` ilə rədd edir (SoD, SPEC §7.1).
          </span>
          <TextField
            label="Şərh"
            required={decisionOpen === 'REJECTED'}
            value={comment}
            hint="Şərh audit jurnalına düşür."
            error={
              decisionOpen === 'REJECTED' && comment.trim().length === 0
                ? 'Rəddə şərh məcburidir.'
                : undefined
            }
            onChange={(e) => setComment(e.target.value)}
          />
        </div>
      </Dialog>
    </DocumentPage>
  );
}

function isZero(value: string | null | undefined): boolean {
  if (value === null || value === undefined) return true;
  try {
    return new Decimal(value).isZero();
  } catch {
    return true;
  }
}

/** `|variancePct| > threshold` — the same comparison `VarianceIndicator` makes. */
export function exceeds(pct: string | null | undefined, thresholdPct: number): boolean {
  if (pct === null || pct === undefined) return false;
  try {
    return new Decimal(pct).abs().greaterThan(thresholdPct);
  } catch {
    return false;
  }
}

/** Re-exported for the count test. */
export { computeVariance };
