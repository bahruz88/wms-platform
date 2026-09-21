import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import {
  Alert,
  Button,
  DataTable,
  QtyUomInput,
  Select,
  TextField,
  VarianceIndicator,
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
import { useAuth } from '@auth/index';
import { Decimal } from '@core/decimal';
import { ErrorState, Page, Section } from '@/components/Page';

/**
 * Goods receipt creation — docs/ux/screen-map.md §3.2.
 *
 * The validations here are the interface half of the spec's invariants:
 *   · `requiresBatch` → `batchNo` is mandatory (SPEC §9.2);
 *   · `requiresExpiry` → `expiryDate` is mandatory and may not be in the past;
 *   · a `receivedQty` that differs from the ordered quantity makes `varianceNote` mandatory —
 *     the server answers `422 VARIANCE_NOTE_REQUIRED` otherwise (SPEC §12.8);
 *   · `unitPrice` is only collected from a user who holds `master.product.view_cost`.
 *
 * Every quantity goes through `QtyUomInput`, never a bare input, and the POST carries an
 * `Idempotency-Key` so a double submit cannot create two documents.
 */

interface DraftLine {
  key: string;
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

export function GoodsReceiptCreateScreen() {
  const navigate = useNavigate();
  const { can } = useAuth();
  const canViewCost = can('master.product.view_cost');

  const [docDate, setDocDate] = useState(today);
  const [supplierId, setSupplierId] = useState('');
  const [locationId, setLocationId] = useState('');
  const [temperatureC, setTemperatureC] = useState('');
  const [qualityStatus, setQualityStatus] = useState<
    'ACCEPTED' | 'PARTIALLY_ACCEPTED' | 'REJECTED'
  >('ACCEPTED');
  const [packagingNote, setPackagingNote] = useState('');
  const [lines, setLines] = useState<DraftLine[]>([emptyLine()]);

  const products = useApiPage<ProductSummary>(
    ['products', 'picker'],
    () => listProducts({ page: 1, size: 200, isActive: true }),
    200,
  );
  const suppliers = useApiPage<SupplierSummary>(
    ['suppliers', 'picker'],
    () => listSuppliers({ page: 1, size: 200 }),
    200,
  );
  const locations = useApiPage<Location>(['locations', 'picker'], () => listLocations({}), 200);

  const productById = useMemo(
    () => new Map((products.data?.items ?? []).map((p) => [String(p.id), p])),
    [products.data],
  );

  const update = (key: string, patch: Partial<DraftLine>) =>
    setLines((prev) => prev.map((l) => (l.key === key ? { ...l, ...patch } : l)));

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
  const headerValid = Boolean(docDate && supplierId && locationId);
  const linesValid = allErrors.every((e) => Object.keys(e).length === 0);
  const canSubmit = headerValid && linesValid && lines.length > 0;

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
          uomId: Number(l.uomId || productById.get(l.productId)?.baseUomId || 1),
          ...(l.batchNo ? { batchNo: l.batchNo } : {}),
          ...(l.expiryDate ? { expiryDate: l.expiryDate } : {}),
          ...(l.varianceNote ? { varianceNote: l.varianceNote } : {}),
          ...(canViewCost && l.unitPrice
            ? { unitPrice: l.unitPrice, currency: 'AZN' as const }
            : {}),
        })),
      }),
    onSuccess: (created) => {
      navigate(`/inventory/goods-receipts/${created.id}`);
    },
  });

  const columns: Column<DraftLine>[] = [
    {
      key: 'productId',
      header: 'Məhsul',
      width: '240px',
      render: (row, i) => (
        <Select
          value={row.productId}
          placeholder="Məhsul seçin"
          required
          error={allErrors[i]?.productId}
          options={(products.data?.items ?? []).map((p) => ({
            value: String(p.id),
            label: `${p.sku} · ${p.name}`,
          }))}
          onChange={(e) => {
            const product = productById.get(e.target.value);
            update(row.key, {
              productId: e.target.value,
              uomId: product ? String(product.baseUomId) : '',
            });
          }}
        />
      ),
    },
    {
      key: 'orderedQty',
      header: 'Sifariş (PO)',
      width: '140px',
      render: (row) => (
        <TextField
          value={row.orderedQty}
          align="right"
          mono
          placeholder="PO-suz"
          hint="PO seçildikdə oxunur"
          onChange={(e) => update(row.key, { orderedQty: e.target.value })}
        />
      ),
    },
    {
      key: 'receivedQty',
      header: 'Qəbul edilən',
      width: '200px',
      render: (row, i) => {
        const product = productById.get(row.productId);
        return (
          <QtyUomInput
            qty={row.receivedQty}
            uomId={row.uomId}
            required
            error={allErrors[i]?.receivedQty}
            baseUomCode={product?.baseUomCode}
            decimals={4}
            uoms={
              product
                ? [{ id: product.baseUomId, code: product.baseUomCode ?? '—', factorToBase: 1 }]
                : [{ id: '', code: '—', factorToBase: 1 }]
            }
            onQtyChange={(value) => update(row.key, { receivedQty: value })}
            onUomChange={(value) => update(row.key, { uomId: value })}
          />
        );
      },
    },
    {
      key: 'rejectedQty',
      header: 'Rədd edilən',
      width: '140px',
      render: (row) => (
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
      render: (row) =>
        row.orderedQty && row.receivedQty ? (
          <VarianceIndicator
            book={row.orderedQty}
            counted={row.receivedQty}
            decimals={4}
            reasonCode={row.varianceNote || undefined}
          />
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'batchNo',
      header: 'Partiya',
      width: '160px',
      render: (row, i) => {
        const product = productById.get(row.productId);
        return (
          <TextField
            value={row.batchNo}
            mono
            required={product?.requiresBatch}
            error={allErrors[i]?.batchNo}
            placeholder="B-001"
            onChange={(e) => update(row.key, { batchNo: e.target.value })}
          />
        );
      },
    },
    {
      key: 'expiryDate',
      header: 'Son istifadə',
      width: '160px',
      render: (row, i) => {
        const product = productById.get(row.productId);
        return (
          <TextField
            type="date"
            value={row.expiryDate}
            required={product?.requiresExpiry}
            error={allErrors[i]?.expiryDate}
            onChange={(e) => update(row.key, { expiryDate: e.target.value })}
          />
        );
      },
    },
    {
      key: 'varianceNote',
      header: 'Fərqin səbəbi',
      width: '200px',
      render: (row, i) => (
        <TextField
          value={row.varianceNote}
          error={allErrors[i]?.varianceNote}
          placeholder="Fərq varsa məcburi"
          onChange={(e) => update(row.key, { varianceNote: e.target.value })}
        />
      ),
    },
    // Price is only collected from a user allowed to see cost.
    {
      key: 'unitPrice',
      header: 'Vahid qiyməti',
      width: '150px',
      permission: 'master.product.view_cost',
      render: (row) => (
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
      width: '80px',
      render: (row) => (
        <Button
          size="sm"
          variant="ghost"
          disabled={lines.length <= 1}
          title={lines.length <= 1 ? 'Ən azı bir sətir olmalıdır' : undefined}
          onClick={() => setLines((prev) => prev.filter((l) => l.key !== row.key))}
        >
          Sil
        </Button>
      ),
    },
  ];

  return (
    <Page
      title="Yeni qəbul"
      subtitle="PO-dan və ya PO-suz mal qəbulu"
      actions={
        <>
          <Button onClick={() => navigate('/inventory/goods-receipts')}>Geri</Button>
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
            Yadda saxla
          </Button>
        </>
      }
    >
      {create.isError ? <ErrorState error={create.error} /> : null}

      <Section title="Başlıq">
        <div className="wms-card">
          <div className="wms-grid wms-grid--form">
            <TextField
              label="Sənəd tarixi"
              type="date"
              required
              value={docDate}
              onChange={(e) => setDocDate(e.target.value)}
            />
            <Select
              label="Təchizatçı"
              required
              value={supplierId}
              placeholder="Təchizatçı seçin"
              hint="Qida məhsulu üçün təchizatçı təsdiqli olmalıdır (TOR §7)."
              options={(suppliers.data?.items ?? []).map((s) => ({
                value: String(s.id),
                label: s.name,
              }))}
              onChange={(e) => setSupplierId(e.target.value)}
            />
            <Select
              label="Lokasiya"
              required
              value={locationId}
              placeholder="Lokasiya seçin"
              hint="Siyahı `iam_user_location` ilə filtrlənir."
              options={(locations.data?.items ?? [])
                .filter((l) => !l.isVirtual)
                .map((l) => ({ value: String(l.id), label: `${l.name} (${l.code})` }))}
              onChange={(e) => setLocationId(e.target.value)}
            />
            <TextField
              label="Temperatur (°C)"
              mono
              align="right"
              value={temperatureC}
              placeholder="4,50"
              onChange={(e) => setTemperatureC(e.target.value)}
            />
            <Select
              label="Keyfiyyət"
              value={qualityStatus}
              options={[
                { value: 'ACCEPTED', label: 'Qəbul edilib' },
                { value: 'PARTIALLY_ACCEPTED', label: 'Qismən qəbul edilib' },
                { value: 'REJECTED', label: 'Rədd edilib' },
              ]}
              onChange={(e) => setQualityStatus(e.target.value as typeof qualityStatus)}
            />
            <TextField
              label="Qablaşdırma qeydi"
              value={packagingNote}
              onChange={(e) => setPackagingNote(e.target.value)}
            />
          </div>
        </div>
      </Section>

      <Section
        title="Sətirlər"
        actions={
          <Button variant="ghost" onClick={() => setLines((prev) => [...prev, emptyLine()])}>
            Sətir əlavə et
          </Button>
        }
      >
        {products.isError ? <ErrorState error={products.error} /> : null}
        <DataTable<DraftLine>
          columns={columns}
          rows={lines}
          dense={false}
          permissions={canViewCost ? ['master.product.view_cost'] : []}
          rowKey={(row) => row.key}
          label="Qəbul sətirləri"
          empty="Sətir yoxdur. «Sətir əlavə et» ilə başlayın."
        />
        <Alert tone="info" title="Post ayrıca addımdır">
          Sənəd əvvəlcə qaralama kimi yaradılır; balansa yalnız «Post et» addımından sonra düşür.
        </Alert>
      </Section>
    </Page>
  );
}
