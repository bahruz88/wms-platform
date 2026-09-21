import { useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Alert,
  Badge,
  Button,
  DataTable,
  Dialog,
  LedgerTable,
  Select,
  TextField,
  VarianceIndicator,
  type Column,
  type LedgerLine,
} from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  cancelIssue,
  confirmIssueReceipt,
  dispatchIssue,
  getIssue,
  listReasonCodes,
  type Issue,
  type IssueConfirmLine,
  type ReasonCode,
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

type Line = Issue['lines'][number];

/**
 * Issue document — docs/design-system/screens/Mexaric.dc.html, after the draft has a number.
 *
 * Two operations live here and they belong to two different people:
 *   · `dispatchIssue` (`inv.issue.dispatch`) writes source → `IN_TRANSIT`;
 *   · `confirmIssueReceipt` (`inv.issue.confirm`) is the receiving location saying what actually
 *     arrived. A line that differs from what was sent needs a reason code and a note before the
 *     button releases — the server answers `422` otherwise (SPEC §12.4).
 *
 * The ledger block is the document's own movements once it is dispatched, and a preview before
 * that; the card title says which, so a preview is never mistaken for a posted fact.
 */
const ISSUE_TYPE_LABELS: Record<string, string> = {
  BRANCH_ISSUE: 'Filiala məxaric',
  WH_TRANSFER: 'Anbarlararası transfer',
  BRANCH_TRANSFER: 'Filiallararası transfer',
};

export function IssueDetailScreen() {
  const { id } = useParams();
  const issueId = Number(id);
  const { can } = useAuth();
  const queryClient = useQueryClient();
  const [dispatchOpen, setDispatchOpen] = useState(false);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [confirmDraft, setConfirmDraft] = useState<
    Record<number, { receivedQty: string; reasonCodeId: string; note: string }>
  >({});

  const issue = useApiQuery<Issue>(['issue', issueId], () => getIssue(issueId));
  const reasons = useApiPage<ReasonCode>(
    ['reason-codes', 'issue'],
    () => listReasonCodes({}),
    200,
    {
      retry: false,
    },
  );

  const doc = issue.data ?? null;

  const dispatch = useMutation({
    mutationFn: () => dispatchIssue(issueId, doc?.rowVersion ?? 1),
    onSuccess: () => {
      setDispatchOpen(false);
      void queryClient.invalidateQueries({ queryKey: ['issue', issueId] });
    },
  });

  const confirm = useMutation({
    mutationFn: () => {
      const lines: IssueConfirmLine[] = (doc?.lines ?? []).map((line) => {
        const draft = confirmDraft[line.id];
        const receivedQty = draft?.receivedQty ?? line.qty;
        const differs = !safeEquals(receivedQty, line.qty);
        return {
          lineId: line.id,
          receivedQty,
          ...(differs && draft?.reasonCodeId ? { reasonCodeId: Number(draft.reasonCodeId) } : {}),
          ...(differs && draft?.note ? { note: draft.note } : {}),
        };
      });
      return confirmIssueReceipt(issueId, doc?.rowVersion ?? 1, lines);
    },
    onSuccess: () => {
      setConfirmOpen(false);
      void queryClient.invalidateQueries({ queryKey: ['issue', issueId] });
    },
  });

  const cancel = useMutation({
    mutationFn: () => cancelIssue(issueId, doc?.rowVersion ?? 1),
    onSuccess: () => void queryClient.invalidateQueries({ queryKey: ['issue', issueId] }),
  });

  const ledger: LedgerLine[] = useMemo(() => {
    if (!doc) return [];
    const out: LedgerLine[] = [];
    let lineNo = 0;
    for (const line of doc.lines) {
      let negated: string;
      try {
        negated = new Decimal(line.qtyBase).negated().toString();
      } catch {
        continue;
      }
      out.push({
        lineNo: ++lineNo,
        product: line.product.name,
        sku: line.product.sku,
        batchNo: line.batch?.batchNo,
        location: doc.fromLocation.name,
        locationType: 'CENTRAL_WAREHOUSE',
        qtyBase: negated,
        uom: line.product.baseUomCode,
      });
      out.push({
        lineNo: ++lineNo,
        product: line.product.name,
        sku: line.product.sku,
        batchNo: line.batch?.batchNo,
        location: doc.status === 'RECEIVED' ? doc.toLocation.name : 'Yolda',
        locationType: doc.status === 'RECEIVED' ? 'RESTAURANT' : 'IN_TRANSIT',
        qtyBase: line.qtyBase,
        uom: line.product.baseUomCode,
      });
    }
    return out;
  }, [doc]);

  if (issue.isLoading) return <LoadingState />;
  if (issue.isError)
    return (
      <DocumentPage breadcrumb="Anbar · Məxaric" docNo={`#${issueId}`}>
        <ErrorState error={issue.error} onRetry={() => void issue.refetch()} />
      </DocumentPage>
    );
  if (!doc) return null;

  const isDraft = doc.status === 'DRAFT';
  const isDispatched = doc.status === 'DISPATCHED';

  /** A line whose chosen batch differs from the server's FEFO suggestion. */
  const offFefoLines = doc.lines.filter(
    (line) => line.suggestedBatch && line.batch && line.suggestedBatch.id !== line.batch.id,
  );

  const columns: Column<Line>[] = [
    { key: 'lineNo', header: '#', width: '44px', numeric: true, decimals: 0 },
    {
      key: 'product',
      header: 'Məhsul',
      render: (row) => <ProductCell name={row.product.name} sku={row.product.sku} />,
    },
    {
      key: 'batch',
      header: 'Partiya',
      width: '150px',
      render: (row) => (
        <div>
          <div className="wms-num wms-small">{row.batch?.batchNo ?? 'partiyasız'}</div>
          {row.suggestedBatch && row.batch && row.suggestedBatch.id !== row.batch.id ? (
            <Badge tone="warning" dot title="FEFO təklifi">
              təklif: {row.suggestedBatch.batchNo}
            </Badge>
          ) : null}
        </div>
      ),
    },
    {
      key: 'qty',
      header: 'Göndərilən',
      width: '140px',
      numeric: true,
      render: (row) => `${formatNumber(row.qty, 3)} ${row.uomCode}`,
    },
    {
      key: 'receivedQty',
      header: 'Qəbul edilən',
      width: '140px',
      numeric: true,
      render: (row) =>
        row.receivedQty === null || row.receivedQty === undefined ? (
          <span className="wms-muted">təsdiq gözləyir</span>
        ) : (
          `${formatNumber(row.receivedQty, 3)} ${row.uomCode}`
        ),
    },
    {
      key: 'discrepancy',
      header: 'Fərq',
      width: '230px',
      render: (row) =>
        row.receivedQty === null || row.receivedQty === undefined ? (
          <span className="wms-muted wms-small">—</span>
        ) : (
          <VarianceIndicator
            book={row.qty}
            counted={row.receivedQty}
            uom={row.uomCode}
            decimals={3}
            thresholdPct={0}
            reasonCode={row.discrepancyNote ?? undefined}
          />
        ),
    },
    {
      key: 'unitCost',
      header: 'Vahid maya',
      width: '120px',
      numeric: true,
      decimals: 4,
      permission: 'master.product.view_cost',
    },
  ];

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/inventory/balances">Anbar</Link> · <Link to="/inventory/issues">Məxaric</Link>
          {doc.requestDocNo ? <> · {doc.requestDocNo} tələbi üzrə</> : null}
        </>
      }
      docNo={doc.docNo}
      status={doc.status}
      badges={
        <Badge tone="neutral" variant="outline" title={doc.issueType}>
          {ISSUE_TYPE_LABELS[doc.issueType] ?? doc.issueType}
        </Badge>
      }
      context={`${doc.fromLocation.name} → ${doc.toLocation.name}`}
      actions={
        <>
          <Button variant="ghost" onClick={() => window.print()}>
            Çap et
          </Button>
          {isDraft && can('inv.issue.create') ? (
            <Button variant="secondary" loading={cancel.isPending} onClick={() => cancel.mutate()}>
              Ləğv et
            </Button>
          ) : null}
          {isDraft ? (
            can('inv.issue.dispatch') ? (
              <Button variant="primary" onClick={() => setDispatchOpen(true)}>
                Yola sal
              </Button>
            ) : (
              <Button disabled title="`inv.issue.dispatch` icazəniz yoxdur">
                Yola sal
              </Button>
            )
          ) : isDispatched ? (
            can('inv.issue.confirm') ? (
              <Button
                variant="primary"
                onClick={() => {
                  setConfirmDraft(
                    Object.fromEntries(
                      doc.lines.map((line) => [
                        line.id,
                        { receivedQty: line.qty, reasonCodeId: '', note: '' },
                      ]),
                    ),
                  );
                  setConfirmOpen(true);
                }}
              >
                Qəbulu təsdiqlə
              </Button>
            ) : (
              <Button disabled title="`inv.issue.confirm` icazəniz yoxdur">
                Qəbulu təsdiqlə
              </Button>
            )
          ) : (
            <Badge tone="neutral" title="SPEC §9.4">
              Sənəd bağlanıb — düzəliş storno ilə olur
            </Badge>
          )}
        </>
      }
      contentClassName="wms-content--split"
    >
      {dispatch.isError ? (
        <div style={{ gridColumn: '1 / -1' }}>
          <ErrorState error={dispatch.error} />
        </div>
      ) : null}
      {confirm.isError ? (
        <div style={{ gridColumn: '1 / -1' }}>
          <ErrorState error={confirm.error} />
        </div>
      ) : null}
      {cancel.isError ? (
        <div style={{ gridColumn: '1 / -1' }}>
          <ErrorState error={cancel.error} />
        </div>
      ) : null}

      <div className="wms-col">
        <Card title="Sənəd başlığı">
          <MetaGrid columns={4}>
            <Meta
              label="Sənəd tarixi"
              value={<span className="wms-num">{formatDate(doc.docDate)}</span>}
            />
            <Meta label="Mənbə" value={doc.fromLocation.name} sub={doc.fromLocation.code} />
            <Meta label="Hədəf" value={doc.toLocation.name} sub={doc.toLocation.code} />
            <Meta
              label="Yola salınıb"
              value={
                <span className="wms-num">
                  {doc.dispatchedAt ? formatDateTime(doc.dispatchedAt) : '—'}
                </span>
              }
              sub={doc.receivedAt ? `qəbul: ${formatDateTime(doc.receivedAt)}` : undefined}
            />
          </MetaGrid>
        </Card>

        <Card title="Sətirlər" flush>
          <DataTable<Line>
            columns={columns}
            rows={doc.lines}
            permissions={can('master.product.view_cost') ? ['master.product.view_cost'] : []}
            rowKey={(row) => row.id}
            label="Məxaric sətirləri"
            empty="Bu sənəddə sətir yoxdur."
            footer={{ product: `${doc.lines.length} sətir` }}
          />
        </Card>

        <Card
          className="wms-card--fill"
          title={isDraft ? 'Post ediləcək hərəkətlər' : 'Sənədin hərəkətləri'}
          subtitle={
            isDraft
              ? 'Ön baxış — sənəd yola salınana qədər ledger-ə yazılmır'
              : `Hərəkət qrupu #${doc.dispatchGroupId ?? '—'}`
          }
        >
          {ledger.length === 0 ? (
            <div className="wms-muted">Sətir olmadığı üçün hərəkət yoxdur.</div>
          ) : (
            <LedgerTable
              lines={ledger}
              decimals={4}
              showBalanceCheck
              label={isDraft ? 'Ledger ön baxışı' : 'Ledger'}
            />
          )}
        </Card>
      </div>

      <div className="wms-col">
        {offFefoLines.length > 0 ? (
          <Alert
            tone="warning"
            title={`${offFefoLines.length} sətirdə FEFO təklifindən kənar partiya seçilib`}
          >
            Sistem{' '}
            <span className="wms-num">{offFefoLines[0]?.suggestedBatch?.batchNo ?? '—'}</span>{' '}
            partiyasını təklif edirdi. Başqa partiya seçildiyi üçün səbəb kodu və qeyd sənəddə
            saxlanılır.
          </Alert>
        ) : null}

        {isDispatched ? (
          <Alert tone="info" title="Mal yoldadır">
            Miqdar <span className="wms-num">IN_TRANSIT</span> lokasiyasındadır. Hədəf lokasiya
            qəbulu təsdiqləyənə qədər nə mənbədə, nə hədəfdə görünür — itki burada gizlənə bilmir.
          </Alert>
        ) : null}

        <Card title="Sənəd qeydi">
          <div className="wms-stack">
            <Meta label="Qeyd" value={doc.note ?? '—'} />
            <Meta
              label="Tələb sənədi"
              value={
                doc.requestId ? (
                  <Link to={`/inventory/stock-requests/${doc.requestId}`} className="wms-doc-no">
                    {doc.requestDocNo ?? `#${doc.requestId}`}
                  </Link>
                ) : (
                  'tələbsiz'
                )
              }
            />
            <Meta label="rowVersion" value={<span className="wms-num">{doc.rowVersion}</span>} />
          </div>
        </Card>
      </div>

      <Dialog
        open={dispatchOpen}
        title="Sənədi yola salım?"
        subtitle="Miqdar mənbə lokasiyadan çıxır və IN_TRANSIT-ə düşür."
        onClose={dispatch.isPending ? undefined : () => setDispatchOpen(false)}
        footer={
          <>
            <Button
              disabled={dispatch.isPending}
              title={dispatch.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setDispatchOpen(false)}
            >
              İmtina
            </Button>
            <Button
              variant="primary"
              loading={dispatch.isPending}
              onClick={() => dispatch.mutate()}
            >
              Yola sal
            </Button>
          </>
        }
      >
        <span>
          <span className="wms-doc-no">{doc.docNo}</span> — {doc.lines.length} sətir,{' '}
          {doc.fromLocation.name} → {doc.toLocation.name}.
        </span>
      </Dialog>

      <Dialog
        open={confirmOpen}
        size="lg"
        title="Qəbulu təsdiqləyim?"
        subtitle="Göndərilənlə fərqli miqdar yazsanız, səbəb kodu və qeyd məcburidir."
        onClose={confirm.isPending ? undefined : () => setConfirmOpen(false)}
        footer={
          <>
            <Button
              disabled={confirm.isPending}
              title={confirm.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setConfirmOpen(false)}
            >
              İmtina
            </Button>
            <Button
              variant="primary"
              loading={confirm.isPending}
              disabled={!confirmValid(doc, confirmDraft)}
              title={
                !confirmValid(doc, confirmDraft)
                  ? 'Fərqli sətirdə səbəb kodu və qeyd məcburidir'
                  : undefined
              }
              onClick={() => confirm.mutate()}
            >
              Təsdiqlə
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          {doc.lines.map((line) => {
            const draft = confirmDraft[line.id] ?? {
              receivedQty: line.qty,
              reasonCodeId: '',
              note: '',
            };
            const differs = !safeEquals(draft.receivedQty, line.qty);
            return (
              <div className="wms-card" key={line.id}>
                <div className="wms-card__body">
                  <div className="wms-row">
                    <strong>{line.product.name}</strong>
                    <span className="wms-num wms-small wms-muted">{line.product.sku}</span>
                    <span className="wms-num wms-small">
                      göndərilib {formatNumber(line.qty, 3)} {line.uomCode}
                    </span>
                  </div>
                  <MetaGrid columns={2}>
                    <TextField
                      label="Qəbul edilən miqdar"
                      required
                      mono
                      align="right"
                      value={draft.receivedQty}
                      onChange={(e) =>
                        setConfirmDraft((prev) => ({
                          ...prev,
                          [line.id]: { ...draft, receivedQty: e.target.value },
                        }))
                      }
                    />
                    <Select
                      label="Fərqin səbəbi"
                      required={differs}
                      disabled={!differs}
                      value={draft.reasonCodeId}
                      placeholder={differs ? 'Səbəb seçin' : 'Fərq yoxdur'}
                      options={(reasons.data?.items ?? []).map((r) => ({
                        value: String(r.id),
                        label: `${r.code} · ${r.name}`,
                      }))}
                      onChange={(e) =>
                        setConfirmDraft((prev) => ({
                          ...prev,
                          [line.id]: { ...draft, reasonCodeId: e.target.value },
                        }))
                      }
                    />
                    <div style={{ gridColumn: 'span 2' }}>
                      <TextField
                        label="Qeyd"
                        required={differs}
                        disabled={!differs}
                        value={draft.note}
                        placeholder={differs ? 'Fərqi izah edin' : 'Fərq yoxdur'}
                        onChange={(e) =>
                          setConfirmDraft((prev) => ({
                            ...prev,
                            [line.id]: { ...draft, note: e.target.value },
                          }))
                        }
                      />
                    </div>
                  </MetaGrid>
                </div>
              </div>
            );
          })}
        </div>
      </Dialog>
    </DocumentPage>
  );
}

/** Decimal-safe equality; an unparsable value counts as different so the reason is demanded. */
export function safeEquals(a: string, b: string): boolean {
  try {
    return new Decimal(a).equals(new Decimal(b));
  } catch {
    return false;
  }
}

/** Every line that differs from what was sent must carry a reason code and a note. */
export function confirmValid(
  doc: Pick<Issue, 'lines'>,
  draft: Record<number, { receivedQty: string; reasonCodeId: string; note: string }>,
): boolean {
  return doc.lines.every((line) => {
    const row = draft[line.id];
    if (!row) return true;
    if (!row.receivedQty.trim()) return false;
    if (safeEquals(row.receivedQty, line.qty)) return true;
    return Boolean(row.reasonCodeId) && row.note.trim().length > 0;
  });
}
