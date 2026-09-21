import { Link, useNavigate, useParams } from 'react-router-dom';
import { Alert, Badge, Button, Dialog, LedgerTable, TextField, type LedgerLine } from '@ds/index';
import { useMemo, useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  getMovementGroup,
  listLocations,
  listProducts,
  reverseMovementGroup,
  type Location,
  type MovementGroup,
  type ProductSummary,
} from '@api/endpoints';
import { indexById, normalizeMovement } from '@api/adapters';
import { useAuth } from '@auth/index';
import { isApiError } from '@api/problem';
import { formatDate, formatDateTime } from '@core/format';
import { Card, DocumentPage, ErrorState, LoadingState, Meta, MetaGrid } from '@/components/Page';
import { ReasonCodePicker } from '@/components/ReasonCodePicker';

/**
 * One movement group, rendered with `LedgerTable` — docs/ux/screen-map.md §3.12.
 *
 * The group header (document number, type, who posted it, when) sits above the table because the
 * component only renders lines. The zero-sum check row is always on: it is the interface twin of
 * the nightly `DoubleEntryCheck` job.
 *
 * **Storno** is the only correction the spec permits on a posted document (SPEC §9.4): the group
 * is never edited or deleted, a new opposite group is written against it and both stay in the
 * ledger. `inv.movement.reverse` is the manager's permission — a keeper posts, a manager
 * reverses.
 *
 * A reversal cannot itself be reversed, and a group can be reversed only once. The first the
 * interface can see: `reversesGroupId` is populated. The second it cannot always see — the
 * service leaves `reversedByGroupId` null even on a group that has been reversed (verified on
 * the live gateway: group 30 carries `reversesGroupId: 28`, but group 28 reports
 * `reversedByGroupId: null`). So the badge is shown when the field **is** populated, and the
 * server's `INVALID_STATE_TRANSITION` is treated as the real answer when it is not — with the
 * code visible, rather than a silent failure.
 */
export function MovementGroupScreen() {
  const { id } = useParams();
  const navigate = useNavigate();
  const groupId = Number(id);
  const { can } = useAuth();
  const queryClient = useQueryClient();
  const [reverseOpen, setReverseOpen] = useState(false);
  const [reasonCodeId, setReasonCodeId] = useState('');
  const [note, setNote] = useState('');

  const products = useApiPage<ProductSummary>(
    ['products', 'group'],
    () => listProducts({ page: 1, size: 200 }),
    200,
  );
  const locations = useApiPage<Location>(['locations', 'group'], () => listLocations({}), 200);

  const group = useApiQuery<MovementGroup>(['movement-group', groupId], () =>
    getMovementGroup(groupId),
  );

  const reverse = useMutation({
    mutationFn: () => reverseMovementGroup(groupId, Number(reasonCodeId), note.trim() || undefined),
    onSuccess: (created) => {
      setReverseOpen(false);
      setReasonCodeId('');
      setNote('');
      void queryClient.invalidateQueries({ queryKey: ['movement-group', groupId] });
      void queryClient.invalidateQueries({ queryKey: ['movements'] });
      if (created?.id) navigate(`/inventory/movement-groups/${created.id}`);
    },
  });

  const normalizedLines = useMemo(() => {
    const productIndex = indexById(products.data?.items ?? []);
    const locationIndex = indexById(locations.data?.items ?? []);
    return (group.data?.lines ?? []).map((line) =>
      normalizeMovement(line, productIndex, locationIndex),
    );
  }, [group.data, products.data, locations.data]);

  if (group.isLoading) return <LoadingState />;
  if (group.isError)
    return (
      <DocumentPage breadcrumb="Anbar · Ledger" docNo={`#${groupId}`}>
        <ErrorState error={group.error} onRetry={() => void group.refetch()} />
      </DocumentPage>
    );
  const doc = group.data;
  if (!doc) return null;

  const alreadyReversed = doc.reversedByGroupId != null;
  const isReversal = doc.reversesGroupId != null;

  const lines: LedgerLine[] = normalizedLines.map((line) => ({
    lineNo: line.lineNo,
    product: line.product.name,
    sku: line.product.sku,
    batchNo: line.batch?.batchNo,
    location: line.location.name,
    locationType: line.location.isVirtual ? line.location.code : undefined,
    qtyBase: line.qtyBase,
    uom: line.product.baseUomCode,
    unitCost: line.unitCost ?? undefined,
  }));

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/inventory/balances">Anbar</Link> ·{' '}
          <Link to="/inventory/movements">Ledger</Link>
        </>
      }
      docNo={doc.docNo}
      badges={
        <Badge tone="neutral" variant="outline" title="movement group doc_type">
          {doc.docType}
        </Badge>
      }
      context={`${lines.length} sətir · ikili yazılış`}
      actions={
        <>
          <Button variant="ghost" onClick={() => window.print()}>
            Çap et
          </Button>
          {alreadyReversed ? (
            <Badge tone="danger" title={`reversedByGroupId = ${doc.reversedByGroupId}`}>
              Storno edilib
            </Badge>
          ) : isReversal ? (
            <Badge tone="neutral" title={`reversesGroupId = ${doc.reversesGroupId}`}>
              Storno sənədi
            </Badge>
          ) : can('inv.movement.reverse') ? (
            <Button variant="danger" onClick={() => setReverseOpen(true)}>
              Storno et
            </Button>
          ) : (
            <Button disabled title="`inv.movement.reverse` icazəniz yoxdur">
              Storno et
            </Button>
          )}
        </>
      }
    >
      {reverse.isError ? (
        <>
          <ErrorState error={reverse.error} />
          {isApiError(reverse.error) && reverse.error.is('INVALID_STATE_TRANSITION') ? (
            <Alert tone="info" title="Bu qrup artıq storno edilmiş ola bilər">
              Server bu qrupu ikinci dəfə storno etməyə imkan vermir. Mövcud storno sənədini tapmaq
              üçün <Link to="/inventory/movements">ledger</Link> siyahısında{' '}
              <span className="wms-num">REVERSAL</span> tipini süzün — sənəd nömrəsi{' '}
              <span className="wms-num">REV-</span> ilə başlayır.
            </Alert>
          ) : null}
        </>
      ) : null}
      {alreadyReversed ? (
        <Alert tone="warning" title="Bu qrup artıq storno edilib" code="INVALID_STATE_TRANSITION">
          Storno sənədi:{' '}
          <Link to={`/inventory/movement-groups/${doc.reversedByGroupId}`} className="wms-num">
            #{doc.reversedByGroupId}
          </Link>
          . Bir qrup yalnız bir dəfə storno edilir.
        </Alert>
      ) : null}
      <Card title="Qrup başlığı">
        <MetaGrid columns={4}>
          <Meta
            label="Sənəd tarixi"
            value={<span className="wms-num">{formatDate(doc.docDate)}</span>}
          />
          <Meta
            label="Post vaxtı"
            value={<span className="wms-num">{formatDateTime(doc.postedAt)}</span>}
            sub={`post edən #${doc.postedBy}`}
          />
          <Meta
            label="Mənbə sənəd"
            value={doc.sourceDocType ? `${doc.sourceDocType} #${doc.sourceDocId}` : '—'}
          />
          <Meta
            label="Storno"
            value={
              doc.reversesGroupId
                ? `#${doc.reversesGroupId} qrupunu storno edir`
                : doc.reversedByGroupId
                  ? `#${doc.reversedByGroupId} ilə storno edilib`
                  : '—'
            }
            sub={doc.note ?? undefined}
          />
        </MetaGrid>
      </Card>

      <Card
        title="Sətirlər"
        subtitle="Qrupun cəmi sıfır olmalıdır — bu, gecə işləyən DoubleEntryCheck-in interfeys tərəfidir"
      >
        {/* showCost only with the permission — the component never decides that itself. */}
        <LedgerTable
          lines={lines}
          decimals={4}
          showCost={can('master.product.view_cost')}
          showBalanceCheck
          label={`${doc.docNo} hərəkət sətirləri`}
        />
      </Card>

      <Dialog
        open={reverseOpen}
        title="Bu qrupu storno edim?"
        subtitle="Qrup silinmir və dəyişmir — əks işarəli yeni qrup yazılır və hər ikisi ledger-də qalır."
        onClose={reverse.isPending ? undefined : () => setReverseOpen(false)}
        footer={
          <>
            <Button
              disabled={reverse.isPending}
              title={reverse.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setReverseOpen(false)}
            >
              İmtina
            </Button>
            <Button
              variant="danger"
              loading={reverse.isPending}
              disabled={!reasonCodeId}
              title={!reasonCodeId ? 'Səbəb kodu məcburidir' : undefined}
              onClick={() => reverse.mutate()}
            >
              Storno et
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          <span>
            <span className="wms-doc-no">{doc.docNo}</span> — {lines.length} sətir,{' '}
            <span className="wms-num">{doc.docType}</span>. Storno qrupu balansı əvvəlki vəziyyətinə
            qaytarır.
          </span>
          <ReasonCodePicker
            reasonGroup="ADJUSTMENT"
            cacheKey="reverse"
            value={reasonCodeId}
            hint="Storno səbəbi audit jurnalına yazılır (SPEC §9.4)."
            onChange={setReasonCodeId}
          />
          <TextField
            label="Qeyd"
            value={note}
            hint="Nə üçün storno edilir — audit jurnalında görünür."
            onChange={(e) => setNote(e.target.value)}
          />
        </div>
      </Dialog>
    </DocumentPage>
  );
}
