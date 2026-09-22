import { useMemo, useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import {
  Alert,
  Badge,
  Button,
  DataTable,
  QtyUomInput,
  Select,
  TextField,
  VarianceIndicator,
  computeVariance,
  type Column,
} from '@ds/index';
import { useApiPage } from '@api/hooks';
import {
  createGoodsReceipt,
  listLocations,
  listProducts,
  listSuppliers,
  type Location,
  type ProductSummary,
  type SupplierSummary,
} from '@api/endpoints';
import { useProductUoms } from '@api/productUoms';
import { useAuth } from '@auth/index';
import { Decimal } from '@core/decimal';
import { formatDate, formatNumber } from '@core/format';
import { Card, DocumentPage, ErrorState, MetaGrid, ProductCell } from '@/components/Page';
import { RefPicker } from '@/components/RefPicker';

/**
 * Goods receipt — docs/design-system/screens/Qebul.dc.html.
 *
 * The artboard is a draft being written: an 84px document header (breadcrumb, number, status,
 * the PO it was raised against) with ghost → secondary → primary actions, a six-column meta card,
 * then one dense line table. The row under the cursor is highlighted on `accent-soft` and carries
 * the inline `TextField` / `QtyUomInput` controls; every other row shows the value it holds. That
 * is what keeps forty lines legible on one screen (design-system README, «Sıxlıq»).
 *
 * The invariants the interface enforces here are the spec's:
 *   · `requiresBatch` → `batchNo` is mandatory (SPEC §9.2);
 *   · `requiresExpiry` → `expiryDate` is mandatory and may not be in the past;
 *   · a `receivedQty` that differs from the ordered quantity makes `varianceNote` mandatory —
 *     the server answers `422 VARIANCE_NOTE_REQUIRED` otherwise (SPEC §12.8);
 *   · `unitPrice` is only collected from a user who holds `master.product.view_cost`.
 *
 * `POST /inventory/goods-receipts` carries an `Idempotency-Key`, so a double submit cannot create
 * two documents.
 */

interface DraftLine {
  key: string;
  /** Set as soon as the user edits the line: a pristine line shows no validation red. */
  dirty: boolean;
  productId: string;
  receivedQty: string;
  rejectedQty: string;
  uomId: string;
  batchNo: string;
  expiryDate: string;
  orderedQty: string;
  varianceNote: string;
  unitPrice: string;
}

const emptyLine = (): DraftLine => ({
  key: crypto.randomUUID(),
  dirty: false,
  productId: '',
  receivedQty: '',
  rejectedQty: '0',
  uomId: '',
  batchNo: '',
  expiryDate: '',
  orderedQty: '',
  varianceNote: '',
  unitPrice: '',
});

const today = () => new Date().toISOString().slice(0, 10);

const QUALITY_OPTIONS = [
  { value: 'ACCEPTED', label: 'Tam qəbul edildi' },
  { value: 'PARTIALLY_ACCEPTED', label: 'Qismən qəbul edildi' },
  { value: 'REJECTED', label: 'Rədd edildi' },
];

export function GoodsReceiptCreateScreen() {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const { can } = useAuth();
  const canViewCost = can('master.product.view_cost');

  const [docDate, setDocDate] = useState(today);
  const [supplierId, setSupplierId] = useState(params.get('supplierId') ?? '');
  const [locationId, setLocationId] = useState('');
  const [temperatureC, setTemperatureC] = useState('');
  const [qualityStatus, setQualityStatus] = useState<
    'ACCEPTED' | 'PARTIALLY_ACCEPTED' | 'REJECTED'
  >('ACCEPTED');
  const [packagingNote, setPackagingNote] = useState('');
  const [lines, setLines] = useState<DraftLine[]>(() => [emptyLine()]);
  // The artboard shows the row under the cursor highlighted on `accent-soft` with its inline
  // controls open; a fresh document opens with its first line in exactly that state.
  const [editingKey, setEditingKey] = useState<string | undefined>(() => lines[0]?.key);

  const products = useApiPage<ProductSummary>(
    ['products', 'picker'],
    () => listProducts({ page: 1, size: 200, isActive: true }),
    200,
    { retry: false },
  );
  const suppliers = useApiPage<SupplierSummary>(
    ['suppliers', 'picker'],
    () => listSuppliers({ page: 1, size: 200 }),
    200,
    { retry: false },
  );
  const locations = useApiPage<Location>(['locations', 'picker'], () => listLocations({}), 200, {
    retry: false,
  });

  const productById = useMemo(
    () => new Map((products.data?.items ?? []).map((p) => [String(p.id), p])),
    [products.data],
  );
  // `master_product_uom` for every product on a line; a receipt defaults to the purchase unit.
  const productUoms = useProductUoms(
    lines.map((l) => Number(l.productId)).filter((id) => Number.isFinite(id) && id > 0),
    'purchase',
  );
  const supplier = (suppliers.data?.items ?? []).find((s) => String(s.id) === supplierId);

  const update = (key: string, patch: Partial<DraftLine>) =>
    setLines((prev) => prev.map((l) => (l.key === key ? { ...l, ...patch, dirty: true } : l)));

  function lineErrors(line: DraftLine): Record<string, string> {
    const errors: Record<string, string> = {};
    const product = productById.get(line.productId);
    if (!line.productId) errors.productId = 'Məhsul seçin.';
    if (!line.receivedQty) errors.receivedQty = 'Qəbul edilən miqdarı yazın.';
    if (product?.requiresBatch && !line.batchNo.trim()) {
      errors.batchNo = 'Bu məhsul partiya tələb edir — partiya nömrəsi yazın.';
    }
    if (product?.requiresExpiry) {
      if (!line.expiryDate) errors.expiryDate = 'Bu məhsul son istifadə tarixi tələb edir.';
      else if (line.expiryDate < today()) errors.expiryDate = 'Son istifadə tarixi keçmişdir.';
    }
    if (line.orderedQty && line.receivedQty) {
      try {
        if (
          !new Decimal(line.orderedQty).equals(new Decimal(line.receivedQty)) &&
          !line.varianceNote.trim()
        ) {
          errors.varianceNote = 'Sifarişdən fərq var — səbəbi yazın (422 VARIANCE_NOTE_REQUIRED).';
        }
      } catch {
        errors.receivedQty = 'Miqdar onluq ədəd olmalıdır.';
      }
    }
    return errors;
  }

  const allErrors = lines.map(lineErrors);
  /** What the user is shown: a line that has not been touched yet stays quiet. */
  const shownErrors = lines.map((line, i) => (line.dirty ? allErrors[i] : {}));
  const headerValid = Boolean(docDate && supplierId && locationId);
  const linesValid = allErrors.every((e) => Object.keys(e).length === 0);
  const canSubmit = headerValid && linesValid && lines.length > 0;

  /** How many lines differ from what was ordered — the artboard's document-level warning. */
  const varianceLines = lines.filter((line) => {
    if (!line.orderedQty || !line.receivedQty) return false;
    try {
      return !new Decimal(line.orderedQty).equals(new Decimal(line.receivedQty));
    } catch {
      return false;
    }
  }).length;

  /** Document total, summed through Decimal. Only assembled when the user may see cost. */
  const total = canViewCost
    ? lines.reduce((acc, line) => {
        if (!line.unitPrice || !line.receivedQty) return acc;
        try {
          return acc.plus(new Decimal(line.unitPrice).times(new Decimal(line.receivedQty)));
        } catch {
          return acc;
        }
      }, new Decimal(0))
    : null;

  const create = useMutation({
    mutationFn: () =>
      createGoodsReceipt({
        docDate,
        supplierId: Number(supplierId),
        locationId: Number(locationId),
        qualityStatus,
        ...(temperatureC ? { temperatureC } : {}),
        ...(packagingNote ? { packagingNote } : {}),
        lines: lines.map((l) => ({
          productId: Number(l.productId),
          receivedQty: l.receivedQty,
          rejectedQty: l.rejectedQty || '0',
          uomId: Number(
            l.uomId ||
              productUoms.uomsFor(productById.get(l.productId)).defaultUomId ||
              productById.get(l.productId)?.baseUomId ||
              1,
          ),
          ...(l.batchNo ? { batchNo: l.batchNo } : {}),
          ...(l.expiryDate ? { expiryDate: l.expiryDate } : {}),
          ...(l.varianceNote ? { varianceNote: l.varianceNote } : {}),
          ...(canViewCost && l.unitPrice
            ? { unitPrice: l.unitPrice, currency: 'AZN' as const }
            : {}),
        })),
      }),
    onSuccess: (created) => navigate(`/inventory/goods-receipts/${created.id}`),
  });

  const columns: Column<DraftLine>[] = [
    {
      key: 'no',
      header: '#',
      width: '44px',
      numeric: true,
      decimals: 0,
      render: (_row, i) => i + 1,
    },
    {
      key: 'product',
      header: 'Məhsul',
      render: (row, i) => {
        const product = productById.get(row.productId);
        // Once the product is chosen the cell goes back to text, exactly as the artboard draws
        // it: the picker is only as wide as it has to be, and the ten columns keep fitting.
        if (product) {
          return (
            <div className="wms-row">
              <ProductCell name={product.name} sku={product.sku} />
              {editingKey === row.key ? (
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => update(row.key, { productId: '', uomId: '' })}
                >
                  Dəyiş
                </Button>
              ) : null}
            </div>
          );
        }
        return (
          <Select
            value={row.productId}
            placeholder="Məhsul seçin"
            required
            error={shownErrors[i]?.productId}
            options={(products.data?.items ?? []).map((p) => ({
              value: String(p.id),
              label: `${p.sku} · ${p.name}`,
            }))}
            onChange={(e) => {
              // The unit is re-resolved from the new product's own rows, not carried over.
              update(row.key, { productId: e.target.value, uomId: '' });
            }}
          />
        );
      },
    },
    {
      key: 'batchNo',
      header: 'Partiya',
      width: '130px',
      render: (row, i) => {
        const product = productById.get(row.productId);
        if (editingKey !== row.key) {
          return row.batchNo ? (
            <span className="wms-num wms-small">{row.batchNo}</span>
          ) : (
            <span className="wms-muted wms-small">partiyasız</span>
          );
        }
        return (
          <TextField
            value={row.batchNo}
            mono
            required={product?.requiresBatch}
            error={shownErrors[i]?.batchNo}
            placeholder="Partiya nömrəsi"
            onChange={(e) => update(row.key, { batchNo: e.target.value })}
          />
        );
      },
    },
    {
      key: 'expiryDate',
      header: 'Son istifadə',
      width: '140px',
      render: (row, i) => {
        const product = productById.get(row.productId);
        if (editingKey !== row.key) {
          return row.expiryDate ? (
            <span className="wms-num wms-small">{formatDate(row.expiryDate)}</span>
          ) : (
            <span className="wms-muted">—</span>
          );
        }
        return (
          <TextField
            type="date"
            value={row.expiryDate}
            required={product?.requiresExpiry}
            error={shownErrors[i]?.expiryDate}
            onChange={(e) => update(row.key, { expiryDate: e.target.value })}
          />
        );
      },
    },
    {
      key: 'orderedQty',
      header: 'Sifariş',
      width: '100px',
      numeric: true,
      render: (row) => {
        const uom = productById.get(row.productId)?.baseUomCode ?? '';
        if (editingKey !== row.key) {
          return row.orderedQty ? (
            `${formatNumber(row.orderedQty, 3)} ${uom}`
          ) : (
            <span className="wms-muted">PO-suz</span>
          );
        }
        return (
          <TextField
            value={row.orderedQty}
            align="right"
            mono
            placeholder="PO-suz"
            onChange={(e) => update(row.key, { orderedQty: e.target.value })}
          />
        );
      },
    },
    {
      key: 'receivedQty',
      header: 'Qəbul edilən',
      width: '150px',
      numeric: true,
      render: (row, i) => {
        const product = productById.get(row.productId);
        if (editingKey !== row.key) {
          return row.receivedQty ? (
            `${formatNumber(row.receivedQty, 3)} ${product?.baseUomCode ?? ''}`
          ) : (
            <span className="wms-muted">—</span>
          );
        }
        // `master_product_uom`: a receipt is normally entered in the purchase unit (CASE),
        // not in the base unit, and the field shows the base equivalent underneath.
        const uomSet = productUoms.uomsFor(product);
        return (
          <QtyUomInput
            qty={row.receivedQty}
            uomId={row.uomId || String(uomSet.defaultUomId ?? '')}
            required
            error={shownErrors[i]?.receivedQty}
            baseUomCode={product?.baseUomCode}
            decimals={4}
            uoms={
              uomSet.options.length > 0
                ? uomSet.options
                : [{ id: '', code: '—', factorToBase: '1' }]
            }
            onQtyChange={(value) => update(row.key, { receivedQty: value })}
            onUomChange={(value) => update(row.key, { uomId: value })}
          />
        );
      },
    },
    {
      key: 'rejectedQty',
      header: 'Rədd',
      width: '90px',
      numeric: true,
      render: (row) =>
        editingKey !== row.key ? (
          formatNumber(row.rejectedQty || '0', 3)
        ) : (
          <TextField
            value={row.rejectedQty}
            align="right"
            mono
            onChange={(e) => update(row.key, { rejectedQty: e.target.value })}
          />
        ),
    },
    {
      key: 'variance',
      header: 'Fərq',
      width: '180px',
      render: (row, i) => {
        if (editingKey === row.key && !row.receivedQty) {
          return <span className="wms-muted wms-small">Daxil edilir…</span>;
        }
        if (!row.orderedQty || !row.receivedQty) {
          return <span className="wms-muted wms-small">Fərq yoxdur</span>;
        }
        const product = productById.get(row.productId);
        const result = computeVariance(row.orderedQty, row.receivedQty);
        return (
          <div className="wms-stack">
            <VarianceIndicator
              book={row.orderedQty}
              counted={row.receivedQty}
              uom={product?.baseUomCode}
              decimals={3}
              thresholdPct={0}
              reasonCode={row.varianceNote.trim() || undefined}
            />
            {editingKey === row.key && !result.variance.isZero() ? (
              <TextField
                value={row.varianceNote}
                error={shownErrors[i]?.varianceNote}
                placeholder="Fərqin səbəbi — məcburi"
                onChange={(e) => update(row.key, { varianceNote: e.target.value })}
              />
            ) : null}
          </div>
        );
      },
    },
    // Cost is only collected from a user allowed to see it — the column is absent otherwise.
    {
      key: 'unitPrice',
      header: 'Vahid qiymət',
      width: '100px',
      numeric: true,
      permission: 'master.product.view_cost',
      render: (row) =>
        editingKey !== row.key ? (
          row.unitPrice ? (
            formatNumber(row.unitPrice, 4)
          ) : (
            <span className="wms-muted">—</span>
          )
        ) : (
          <TextField
            value={row.unitPrice}
            align="right"
            mono
            placeholder="0,0000"
            onChange={(e) => update(row.key, { unitPrice: e.target.value })}
          />
        ),
    },
    {
      key: 'remove',
      header: '',
      width: '52px',
      render: (row) => (
        <Button
          size="sm"
          variant="ghost"
          disabled={lines.length <= 1}
          title={lines.length <= 1 ? 'Ən azı bir sətir olmalıdır' : undefined}
          onClick={() => {
            setLines((prev) => prev.filter((l) => l.key !== row.key));
            if (editingKey === row.key) setEditingKey(undefined);
          }}
        >
          Sil
        </Button>
      ),
    },
  ];

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/inventory/balances">Anbar</Link> ·{' '}
          <Link to="/inventory/goods-receipts">Qəbul</Link> · yeni sənəd
        </>
      }
      docNo="Yeni qəbul"
      mono={false}
      status="DRAFT"
      badges={
        supplier ? (
          <Badge tone="neutral" variant="outline">
            {supplier.name}
          </Badge>
        ) : undefined
      }
      context={`${lines.length} sətir`}
      actions={
        <>
          <Button variant="ghost" onClick={() => navigate('/inventory/goods-receipts')}>
            İmtina
          </Button>
          <Button
            variant="primary"
            loading={create.isPending}
            disabled={!canSubmit}
            title={
              !headerValid
                ? 'Tarix, təchizatçı və lokasiya məcburidir'
                : !linesValid
                  ? 'Sətirlərdə həll olunmamış xəta var'
                  : undefined
            }
            onClick={() => create.mutate()}
          >
            Qaralama yarat
          </Button>
        </>
      }
    >
      {create.isError ? <ErrorState error={create.error} /> : null}

      {varianceLines > 0 ? (
        <Alert tone="warning" title={`${varianceLines} sətirdə PO ilə fərq var`}>
          receipt_over_tolerance_pct = 0 olduğu üçün artıq qəbul təsdiq tələb edir; çatışmazlıqda
          fərq qeydi məcburidir.
        </Alert>
      ) : null}

      <Card>
        <MetaGrid columns={6}>
          <RefPicker
            label="Təchizatçı"
            required
            value={supplierId}
            operation="GET /masterdata/suppliers"
            listError={suppliers.error ?? null}
            placeholder="Təchizatçı seçin"
            hint="Qida məhsulu üçün təchizatçı təsdiqli olmalıdır"
            options={(suppliers.data?.items ?? []).map((s) => ({
              value: String(s.id),
              label: s.name,
            }))}
            onChange={setSupplierId}
          />
          <TextField
            label="Sənəd tarixi"
            type="date"
            required
            mono
            value={docDate}
            onChange={(e) => setDocDate(e.target.value)}
          />
          <RefPicker
            label="Qəbul lokasiyası"
            required
            value={locationId}
            operation="GET /masterdata/locations"
            listError={locations.error ?? null}
            placeholder="Lokasiya seçin"
            hint="Yalnız icazəniz olan lokasiyalar"
            options={(locations.data?.items ?? [])
              .filter((l) => !l.isVirtual)
              .map((l) => ({ value: String(l.id), label: `${l.name} (${l.code})` }))}
            onChange={setLocationId}
          />
          <TextField
            label="Temperatur, °C"
            mono
            align="right"
            value={temperatureC}
            hint="Soyuducu maşında ölçülüb"
            placeholder="3,4"
            onChange={(e) => setTemperatureC(e.target.value)}
          />
          <Select
            label="Keyfiyyət statusu"
            required
            value={qualityStatus}
            options={QUALITY_OPTIONS}
            onChange={(e) => setQualityStatus(e.target.value as typeof qualityStatus)}
          />
          <TextField
            label="Qablaşdırma qeydi"
            value={packagingNote}
            placeholder="Qeyd yoxdursa boş buraxın"
            onChange={(e) => setPackagingNote(e.target.value)}
          />
        </MetaGrid>
      </Card>

      <Card
        title="Qəbul sətirləri"
        subtitle="Redaktə etmək üçün sətrə toxunun"
        actions={
          <>
            <Button
              variant="ghost"
              size="sm"
              disabled
              title="Barkod oxuyucusu mobil tətbiqdədir (ADR-013)"
            >
              Barkodla əlavə et
            </Button>
            <Button
              variant="secondary"
              size="sm"
              onClick={() => {
                const line = emptyLine();
                setLines((prev) => [...prev, line]);
                setEditingKey(line.key);
              }}
            >
              Sətir əlavə et
            </Button>
          </>
        }
        flush
      >
        {products.isError ? (
          <div style={{ padding: 16 }}>
            <ErrorState error={products.error} />
          </div>
        ) : null}
        <DataTable<DraftLine>
          columns={columns}
          rows={lines}
          permissions={canViewCost ? ['master.product.view_cost'] : []}
          rowKey={(row) => row.key}
          selectedKey={editingKey}
          onRowClick={(row) => setEditingKey(row.key)}
          label="Qəbul sətirləri"
          empty="Sətir yoxdur. «Sətir əlavə et» ilə başlayın."
          footer={{
            product: `${lines.length} sətir`,
            ...(total ? { unitPrice: `${formatNumber(total.toFixed(2), 2)} AZN` } : {}),
          }}
        />
      </Card>

      <Alert tone="info" title="Post ayrıca addımdır">
        Sənəd əvvəlcə qaralama kimi yaradılır; balansa yalnız «Post et» addımından sonra düşür.
      </Alert>
    </DocumentPage>
  );
}
