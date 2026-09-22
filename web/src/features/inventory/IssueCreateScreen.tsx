import { useMemo, useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import {
  Alert,
  Badge,
  BatchPicker,
  Button,
  LedgerTable,
  QtyUomInput,
  Select,
  TextField,
  suggestedBatchId,
  type Batch,
  type LedgerLine,
} from '@ds/index';
import { useApiPage } from '@api/hooks';
import {
  createIssue,
  listBalances,
  listLocations,
  listProducts,
  listReasonCodes,
  type Balance,
  type Location,
  type ProductSummary,
  type ReasonCode,
} from '@api/endpoints';
import { normalizeBalance } from '@api/adapters';
import { useProductUoms } from '@api/productUoms';
import { Decimal } from '@core/decimal';
import { formatDate } from '@core/format';
import { Card, DocumentPage, ErrorState, Meta, MetaGrid } from '@/components/Page';
import { RefPicker } from '@/components/RefPicker';

/**
 * Issue to a branch — docs/design-system/screens/Mexaric.dc.html.
 *
 * The artboard splits the screen `minmax(0, 1fr) / minmax(0, 1.05fr)`: the line being written and
 * the ledger preview on the left, the FEFO warning and the `BatchPicker` on the right. Three
 * rules from the spec are visible in that layout and are enforced here:
 *
 *   · the FEFO/FIFO suggestion is always shown — `BatchPicker` flags it (SPEC §12.4);
 *   · choosing a different batch opens the reason code and the note, both mandatory
 *     (`422 REASON_CODE_REQUIRED`, design-system README «Düzəlişin səbəbi məcburidir»);
 *   · the movements are a **preview**. Nothing reaches the ledger until the document is
 *     dispatched, which is why the card says so above the table.
 *
 * Available batches are read from `GET /inventory/balances` for the source location: that is the
 * quantity actually available per batch, which is what the picker must show. When
 * `GET /inventory/batches` starts answering it can replace this without touching the layout.
 */

interface DraftLine {
  key: string;
  /** Set as soon as the user edits the line: a pristine line shows no validation red. */
  dirty: boolean;
  productId: string;
  qty: string;
  uomId: string;
  batchId: string;
  reasonCodeId: string;
  note: string;
}

const emptyLine = (): DraftLine => ({
  key: crypto.randomUUID(),
  dirty: false,
  productId: '',
  qty: '',
  uomId: '',
  batchId: '',
  reasonCodeId: '',
  note: '',
});

const today = () => new Date().toISOString().slice(0, 10);

const ISSUE_TYPES = [
  { value: 'BRANCH_ISSUE', label: 'Filiala məxaric' },
  { value: 'WH_TRANSFER', label: 'Anbarlararası transfer' },
  { value: 'BRANCH_TRANSFER', label: 'Filiallararası transfer' },
];

export function IssueCreateScreen() {
  const navigate = useNavigate();
  const [params] = useSearchParams();

  const [docDate, setDocDate] = useState(today);
  const [issueType, setIssueType] = useState<'BRANCH_ISSUE' | 'WH_TRANSFER' | 'BRANCH_TRANSFER'>(
    'BRANCH_ISSUE',
  );
  const [fromLocationId, setFromLocationId] = useState(params.get('fromLocationId') ?? '');
  const [toLocationId, setToLocationId] = useState(params.get('toLocationId') ?? '');
  const [note, setNote] = useState('');
  const [lines, setLines] = useState<DraftLine[]>([emptyLine()]);
  const [activeKey, setActiveKey] = useState<string>(() => '');

  const products = useApiPage<ProductSummary>(
    ['products', 'issue'],
    () => listProducts({ page: 1, size: 200, isActive: true }),
    200,
    { retry: false },
  );
  const locations = useApiPage<Location>(['locations', 'issue'], () => listLocations({}), 200, {
    retry: false,
  });
  const reasons = useApiPage<ReasonCode>(
    ['reason-codes', 'issue'],
    () => listReasonCodes({}),
    200,
    {
      retry: false,
    },
  );

  const active = lines.find((l) => l.key === activeKey) ?? lines[0];
  const activeIndex = lines.findIndex((l) => l.key === active?.key);

  const product = (products.data?.items ?? []).find((p) => String(p.id) === active?.productId);
  // The alternative units the issue may be entered in (`master_product_uom`), from the server.
  const productUoms = useProductUoms(
    lines.map((l) => Number(l.productId)).filter((id) => Number.isFinite(id) && id > 0),
    'issue',
  );
  const activeUoms = productUoms.uomsFor(product);
  const fromLocation = (locations.data?.items ?? []).find((l) => String(l.id) === fromLocationId);
  const toLocation = (locations.data?.items ?? []).find((l) => String(l.id) === toLocationId);

  // Batch availability for the source location, straight off the balance projection.
  const stock = useApiPage<Balance>(
    ['balances', 'issue', fromLocationId, active?.productId ?? ''],
    () =>
      listBalances({
        page: 1,
        size: 200,
        ...(fromLocationId ? { locationId: Number(fromLocationId) } : {}),
        ...(active?.productId ? { productId: Number(active.productId) } : {}),
      }),
    200,
    { enabled: Boolean(fromLocationId), retry: false },
  );

  const batches: Batch[] = useMemo(() => {
    const rows = (stock.data?.items ?? []).map((row) => normalizeBalance(row));
    return rows
      .filter((row) => row.batch)
      .map((row) => ({
        id: row.batch?.id ?? 0,
        batchNo: row.batch?.batchNo ?? '—',
        expiryDate: row.batch?.expiryDate ?? undefined,
        status: row.batch?.status ?? 'ACTIVE',
        available: row.qtyAvailable,
      }));
  }, [stock.data]);

  const suggested = suggestedBatchId(batches, 'FEFO');
  const suggestedBatch = batches.find((b) => String(b.id) === String(suggested));
  const chosenBatch = batches.find((b) => String(b.id) === String(active?.batchId));
  const offFefo =
    Boolean(active?.batchId) && suggested !== undefined && String(suggested) !== active?.batchId;

  const update = (key: string, patch: Partial<DraftLine>) =>
    setLines((prev) => prev.map((l) => (l.key === key ? { ...l, ...patch, dirty: true } : l)));

  function lineErrors(line: DraftLine): Record<string, string> {
    const errors: Record<string, string> = {};
    if (!line.productId) errors.productId = 'Məhsul seçin.';
    if (!line.qty) errors.qty = 'Veriləcək miqdarı yazın.';
    else {
      try {
        if (new Decimal(line.qty).lessThanOrEqualTo(0))
          errors.qty = 'Miqdar sıfırdan böyük olmalıdır.';
      } catch {
        errors.qty = 'Miqdar onluq ədəd olmalıdır.';
      }
    }
    const lineSuggested = suggestedBatchId(batches, 'FEFO');
    const lineOffFefo =
      Boolean(line.batchId) &&
      lineSuggested !== undefined &&
      String(lineSuggested) !== line.batchId;
    if (lineOffFefo && !line.reasonCodeId) {
      errors.reasonCodeId = 'FEFO təklifindən kənar seçim üçün səbəb kodu məcburidir.';
    }
    if (lineOffFefo && !line.note.trim()) {
      errors.note = 'Səbəbi qeyd sahəsində yazın — audit jurnalına düşür.';
    }
    return errors;
  }

  const allErrors = active ? lineErrors(active) : {};
  /** A line the user has not touched yet stays quiet; the disabled primary says what is missing. */
  const errors: Record<string, string> = active?.dirty ? allErrors : {};
  const allValid = lines.every((l) => Object.keys(lineErrors(l)).length === 0);
  const headerValid = Boolean(
    docDate && fromLocationId && toLocationId && fromLocationId !== toLocationId,
  );

  const preview: LedgerLine[] = useMemo(() => {
    const out: LedgerLine[] = [];
    let lineNo = 0;
    for (const line of lines) {
      const p = (products.data?.items ?? []).find((x) => String(x.id) === line.productId);
      if (!p || !line.qty) continue;
      const batch = batches.find((b) => String(b.id) === line.batchId);
      let signed: string;
      try {
        signed = new Decimal(line.qty).negated().toString();
      } catch {
        continue;
      }
      out.push({
        lineNo: ++lineNo,
        product: p.name,
        sku: p.sku,
        batchNo: batch?.batchNo,
        location: fromLocation?.name ?? `#${fromLocationId}`,
        locationType: 'CENTRAL_WAREHOUSE',
        qtyBase: signed,
        uom: p.baseUomCode,
      });
      out.push({
        lineNo: ++lineNo,
        product: p.name,
        sku: p.sku,
        batchNo: batch?.batchNo,
        location: 'Yolda',
        locationType: 'IN_TRANSIT',
        qtyBase: line.qty,
        uom: p.baseUomCode,
      });
    }
    return out;
  }, [lines, products.data, batches, fromLocation, fromLocationId]);

  const create = useMutation({
    mutationFn: () =>
      createIssue({
        docDate,
        issueType,
        fromLocationId: Number(fromLocationId),
        toLocationId: Number(toLocationId),
        ...(note ? { note } : {}),
        lines: lines.map((l) => ({
          productId: Number(l.productId),
          qty: l.qty,
          uomId: Number(
            l.uomId ||
              productUoms.uomsFor(
                (products.data?.items ?? []).find((p) => String(p.id) === l.productId),
              ).defaultUomId ||
              1,
          ),
          ...(l.batchId ? { batchId: Number(l.batchId) } : {}),
          ...(l.reasonCodeId ? { batchOverrideReasonCodeId: Number(l.reasonCodeId) } : {}),
          ...(l.note ? { batchOverrideNote: l.note } : {}),
        })),
      }),
    onSuccess: (created) => navigate(`/inventory/issues/${created.id}`),
  });

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/inventory/balances">Anbar</Link> · <Link to="/inventory/issues">Məxaric</Link>{' '}
          · yeni sənəd
        </>
      }
      docNo="Yeni məxaric"
      mono={false}
      status="DRAFT"
      context={
        fromLocation || toLocation
          ? `${fromLocation?.name ?? '—'} → ${toLocation?.name ?? '—'}`
          : undefined
      }
      actions={
        <>
          <Button variant="ghost" onClick={() => navigate('/inventory/issues')}>
            İmtina
          </Button>
          <Button
            variant="secondary"
            onClick={() => {
              const line = emptyLine();
              setLines((prev) => [...prev, line]);
              setActiveKey(line.key);
            }}
          >
            Sətir əlavə et
          </Button>
          <Button
            variant="primary"
            loading={create.isPending}
            disabled={!headerValid || !allValid}
            title={
              !headerValid
                ? 'Tarix, mənbə və hədəf lokasiya məcburidir və eyni ola bilməz'
                : !allValid
                  ? 'Sətirlərdə həll olunmamış xəta var'
                  : undefined
            }
            onClick={() => create.mutate()}
          >
            Qaralama yarat
          </Button>
        </>
      }
      contentClassName="wms-content--split"
    >
      {create.isError ? (
        <div style={{ gridColumn: '1 / -1' }}>
          <ErrorState error={create.error} />
        </div>
      ) : null}

      <div className="wms-col">
        <Card title="Sənəd başlığı">
          <MetaGrid columns={2}>
            <TextField
              label="Sənəd tarixi"
              type="date"
              required
              mono
              value={docDate}
              onChange={(e) => setDocDate(e.target.value)}
            />
            <Select
              label="Məxaric tipi"
              required
              value={issueType}
              options={ISSUE_TYPES}
              onChange={(e) => setIssueType(e.target.value as typeof issueType)}
            />
            <RefPicker
              label="Mənbə lokasiya"
              required
              value={fromLocationId}
              operation="GET /masterdata/locations"
              listError={locations.error ?? null}
              placeholder="Lokasiya seçin"
              options={(locations.data?.items ?? [])
                .filter((l) => !l.isVirtual)
                .map((l) => ({ value: String(l.id), label: `${l.name} (${l.code})` }))}
              onChange={setFromLocationId}
            />
            <RefPicker
              label="Hədəf lokasiya"
              required
              value={toLocationId}
              operation="GET /masterdata/locations"
              listError={locations.error ?? null}
              placeholder="Lokasiya seçin"
              error={
                fromLocationId && fromLocationId === toLocationId
                  ? 'Mənbə və hədəf eyni ola bilməz.'
                  : undefined
              }
              options={(locations.data?.items ?? [])
                .filter((l) => !l.isVirtual)
                .map((l) => ({ value: String(l.id), label: `${l.name} (${l.code})` }))}
              onChange={setToLocationId}
            />
          </MetaGrid>
        </Card>

        {lines.length > 1 ? (
          <Card title="Sətirlər" rows>
            <div className="wms-doclist">
              {lines.map((line, i) => {
                const p = (products.data?.items ?? []).find((x) => String(x.id) === line.productId);
                return (
                  <div className="wms-doclist__row" key={line.key}>
                    <div className="wms-doclist__main">
                      <div className="wms-doclist__title">
                        <span className="wms-num wms-doclist__no">Sətir {i + 1}</span>
                        {p ? (
                          <span>{p.name}</span>
                        ) : (
                          <span className="wms-muted">məhsul seçilməyib</span>
                        )}
                      </div>
                      <div className="wms-doclist__meta">
                        {line.qty ? `${line.qty} ${p?.baseUomCode ?? ''}` : 'miqdar yazılmayıb'}
                      </div>
                    </div>
                    <Button
                      size="sm"
                      variant={line.key === active?.key ? 'primary' : 'secondary'}
                      onClick={() => setActiveKey(line.key)}
                    >
                      Aç
                    </Button>
                  </div>
                );
              })}
            </div>
          </Card>
        ) : null}

        {active ? (
          <Card
            title={`Sətir ${activeIndex + 1}${product ? ` — ${product.name}` : ''}`}
            actions={
              <Badge tone="neutral" variant="outline" title="master_product.issue_strategy">
                FEFO
              </Badge>
            }
          >
            <MetaGrid columns={2}>
              <div>
                <div className="wms-meta__k">Məhsul</div>
                <RefPicker
                  label=""
                  required
                  value={active.productId}
                  operation="GET /masterdata/products"
                  listError={products.error ?? null}
                  placeholder="Məhsul seçin"
                  error={errors.productId}
                  options={(products.data?.items ?? []).map((p) => ({
                    value: String(p.id),
                    label: `${p.sku} · ${p.name}`,
                  }))}
                  onChange={(value) => {
                    // The unit comes from the new product's own rows, not from the old line.
                    update(active.key, { productId: value, uomId: '', batchId: '' });
                  }}
                />
                {product ? (
                  <div className="wms-meta__sub wms-num">
                    {product.sku} · base UoM: {product.baseUomCode}
                  </div>
                ) : null}
              </div>
              <Meta
                label="Mövcud qalıq"
                value={
                  <span className="wms-num">
                    {chosenBatch
                      ? `${chosenBatch.available} ${product?.baseUomCode ?? ''}`
                      : batches.length > 0
                        ? `${batches.length} partiya`
                        : '—'}
                  </span>
                }
                sub={
                  chosenBatch?.expiryDate
                    ? `son istifadə ${formatDate(chosenBatch.expiryDate)}`
                    : 'partiya seçilməyib'
                }
              />
              <QtyUomInput
                label="Veriləcək miqdar"
                required
                qty={active.qty}
                uomId={active.uomId || String(activeUoms.defaultUomId ?? '')}
                error={errors.qty}
                baseUomCode={product?.baseUomCode}
                decimals={4}
                uoms={
                  activeUoms.options.length > 0
                    ? activeUoms.options
                    : [{ id: '', code: '—', factorToBase: '1' }]
                }
                onQtyChange={(value) => update(active.key, { qty: value })}
                onUomChange={(value) => update(active.key, { uomId: value })}
              />
              <Select
                label="Səbəb kodu"
                required={offFefo}
                disabled={!offFefo}
                value={active.reasonCodeId}
                placeholder={offFefo ? 'Səbəb seçin' : 'FEFO təklifi seçilib — səbəb lazım deyil'}
                hint="FEFO təklifindən kənar seçim üçün məcburidir"
                error={errors.reasonCodeId}
                options={(reasons.data?.items ?? []).map((r) => ({
                  value: String(r.id),
                  label: `${r.code} · ${r.name}`,
                }))}
                onChange={(e) => update(active.key, { reasonCodeId: e.target.value })}
              />
              <div style={{ gridColumn: 'span 2' }}>
                <TextField
                  label="Qeyd"
                  required={offFefo}
                  value={active.note}
                  hint="Audit jurnalına yazılır"
                  error={errors.note}
                  onChange={(e) => update(active.key, { note: e.target.value })}
                />
              </div>
            </MetaGrid>
          </Card>
        ) : null}

        <Card
          title="Post ediləcək hərəkətlər"
          subtitle="Ön baxış — sənəd yola salınana qədər ledger-ə yazılmır"
          className="wms-card--fill"
        >
          {preview.length === 0 ? (
            <div className="wms-muted">
              Sətirdə məhsul və miqdar olduqda hərəkətlər burada görünəcək. Mənbə lokasiyadan çıxış,
              «Yolda» lokasiyasına giriş — cəmi sıfır olmalıdır.
            </div>
          ) : (
            <LedgerTable lines={preview} decimals={4} showBalanceCheck label="Ledger ön baxışı" />
          )}
        </Card>
      </div>

      <div className="wms-col">
        {offFefo ? (
          <Alert tone="warning" title="FEFO təklifindən kənar partiya seçildi">
            Sistem <span className="wms-num">{suggestedBatch?.batchNo ?? '—'}</span> partiyasını
            təklif edir
            {suggestedBatch?.expiryDate
              ? ` — onun son istifadə tarixi ${formatDate(suggestedBatch.expiryDate)}`
              : ''}
            . Başqa partiya seçildiyi üçün səbəb kodu və qeyd məcburidir.
          </Alert>
        ) : null}

        <Card
          title="Partiya seçimi"
          className="wms-card--fill"
          actions={
            <span className="wms-num wms-small wms-muted">
              {fromLocation?.name ?? 'lokasiya seçilməyib'} · {batches.length} partiya
            </span>
          }
        >
          {!fromLocationId ? (
            <div className="wms-muted">
              Əvvəlcə mənbə lokasiyanı seçin — partiyalar həmin lokasiyanın qalığından gəlir.
            </div>
          ) : stock.isError ? (
            <ErrorState error={stock.error} onRetry={() => void stock.refetch()} />
          ) : batches.length === 0 ? (
            <div className="wms-muted">
              Bu lokasiyada partiyalı qalıq yoxdur. Qəbul sənədi ilə partiya yaradın.
            </div>
          ) : (
            <BatchPicker
              batches={batches}
              strategy="FEFO"
              value={active?.batchId}
              requiredQty={active?.qty || undefined}
              uom={product?.baseUomCode}
              decimals={4}
              onChange={(id) => active && update(active.key, { batchId: String(id) })}
            />
          )}
        </Card>

        <Card title="Sənəd qeydi">
          <TextField
            label="Qeyd"
            value={note}
            placeholder="Sənəd səviyyəsində qeyd"
            onChange={(e) => setNote(e.target.value)}
          />
        </Card>
      </div>
    </DocumentPage>
  );
}
