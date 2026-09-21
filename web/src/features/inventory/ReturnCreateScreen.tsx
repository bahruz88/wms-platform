import { useMemo, useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { Alert, Badge, Button, QtyUomInput, Select, TextField } from '@ds/index';
import { useApiPage } from '@api/hooks';
import {
  createReturnToVendor,
  listBalances,
  listLocations,
  listProducts,
  listSuppliers,
  type Balance,
  type Location,
  type ProductSummary,
  type SupplierSummary,
} from '@api/endpoints';
import { normalizeBalance } from '@api/adapters';
import { useAuth } from '@auth/index';
import { Decimal } from '@core/decimal';
import { Card, DocumentPage, ErrorState, Meta, MetaGrid } from '@/components/Page';
import { RefPicker } from '@/components/RefPicker';
import { ReasonCodePicker } from '@/components/ReasonCodePicker';

/**
 * New return to vendor — screen-map §3.11.
 *
 * The reason code is mandatory and its group is `RETURN`; it goes through `ReasonCodePicker`, so
 * when `GET /master-data/reason-codes` is unrouted the field says so and takes an id instead of
 * rendering an empty dropdown that silently blocks the document.
 *
 * `receiptId` is optional but carried through from the goods-receipt screen when the user starts
 * there: the contract narrows the selectable batches to that receipt's when it is given.
 */

interface DraftLine {
  key: string;
  dirty: boolean;
  productId: string;
  qty: string;
  uomId: string;
  batchId: string;
  note: string;
}

const emptyLine = (): DraftLine => ({
  key: crypto.randomUUID(),
  dirty: false,
  productId: '',
  qty: '',
  uomId: '',
  batchId: '',
  note: '',
});

const today = () => new Date().toISOString().slice(0, 10);

export function ReturnCreateScreen() {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const { can } = useAuth();
  const canViewCost = can('master.product.view_cost');

  const [docDate, setDocDate] = useState(today);
  const [supplierId, setSupplierId] = useState(params.get('supplierId') ?? '');
  const [locationId, setLocationId] = useState(params.get('locationId') ?? '');
  const [receiptId, setReceiptId] = useState(params.get('receiptId') ?? '');
  const [reasonCodeId, setReasonCodeId] = useState('');
  const [claimAmount, setClaimAmount] = useState('');
  const [note, setNote] = useState('');
  const [lines, setLines] = useState<DraftLine[]>([emptyLine()]);

  const products = useApiPage<ProductSummary>(
    ['products', 'rtv'],
    () => listProducts({ page: 1, size: 200, isActive: true }),
    200,
    { retry: false },
  );
  const locations = useApiPage<Location>(['locations', 'rtv'], () => listLocations({}), 200, {
    retry: false,
  });
  const suppliers = useApiPage<SupplierSummary>(
    ['suppliers', 'rtv'],
    () => listSuppliers({ page: 1, size: 200 }),
    200,
    { retry: false },
  );

  const stock = useApiPage<Balance>(
    ['balances', 'rtv', locationId],
    () =>
      listBalances({
        page: 1,
        size: 200,
        ...(locationId ? { locationId: Number(locationId) } : {}),
      }),
    200,
    { enabled: Boolean(locationId), retry: false },
  );

  const batchesFor = useMemo(() => {
    const rows = (stock.data?.items ?? []).map((row) => normalizeBalance(row));
    const byProduct = new Map<string, Array<{ id: number; batchNo: string; available: string }>>();
    for (const row of rows) {
      if (!row.batch) continue;
      const key = String(row.product.id);
      const list = byProduct.get(key) ?? [];
      list.push({ id: row.batch.id, batchNo: row.batch.batchNo, available: row.qtyAvailable });
      byProduct.set(key, list);
    }
    return byProduct;
  }, [stock.data]);

  const update = (key: string, patch: Partial<DraftLine>) =>
    setLines((prev) => prev.map((l) => (l.key === key ? { ...l, ...patch, dirty: true } : l)));

  const removeLine = (key: string) =>
    setLines((prev) => (prev.length <= 1 ? prev : prev.filter((l) => l.key !== key)));

  function lineErrors(line: DraftLine): Record<string, string> {
    const errors: Record<string, string> = {};
    if (!line.productId) errors.productId = 'Məhsul seçin.';
    if (!line.qty) errors.qty = 'Qaytarılan miqdarı yazın.';
    else {
      try {
        if (new Decimal(line.qty).lessThanOrEqualTo(0))
          errors.qty = 'Miqdar sıfırdan böyük olmalıdır.';
      } catch {
        errors.qty = 'Miqdar onluq ədəd olmalıdır.';
      }
    }
    return errors;
  }

  const headerValid = Boolean(docDate && supplierId && locationId && reasonCodeId);
  const linesValid = lines.every((l) => Object.keys(lineErrors(l)).length === 0);

  /** The UoM defaults to the product's base unit until `GET /products/{id}/uoms` is routed. */
  const uomOf = (line: DraftLine): number => {
    if (line.uomId) return Number(line.uomId);
    const p = (products.data?.items ?? []).find((x) => String(x.id) === line.productId);
    return p?.baseUomId ?? 0;
  };

  const create = useMutation({
    mutationFn: () =>
      createReturnToVendor({
        docDate,
        supplierId: Number(supplierId),
        locationId: Number(locationId),
        reasonCodeId: Number(reasonCodeId),
        ...(receiptId.trim() ? { receiptId: Number(receiptId.trim()) } : {}),
        // `Money` carries its own currency; the amount is never parsed into a number.
        ...(claimAmount.trim()
          ? { claimAmount: { amount: claimAmount.trim(), currency: 'AZN' } }
          : {}),
        ...(note.trim() ? { note: note.trim() } : {}),
        lines: lines.map((l) => ({
          productId: Number(l.productId),
          // `value` is the contract's decimal **string**; it is never parsed into a number.
          quantity: { uomId: uomOf(l), value: l.qty },
          ...(l.batchId ? { batchId: Number(l.batchId) } : {}),
          ...(l.note.trim() ? { note: l.note.trim() } : {}),
        })),
      }),
    onSuccess: (doc) => navigate(`/inventory/returns/${doc.id}`),
  });

  const blockers: string[] = [];
  if (!docDate) blockers.push('sənəd tarixi');
  if (!supplierId) blockers.push('təchizatçı');
  if (!locationId) blockers.push('lokasiya');
  if (!reasonCodeId) blockers.push('səbəb kodu');
  if (!linesValid) blockers.push('sətirlər');

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/inventory/balances">Anbar</Link> ·{' '}
          <Link to="/inventory/returns">Qaytarma</Link>
        </>
      }
      docNo="Yeni qaytarma"
      mono={false}
      status="DRAFT"
      context={`${lines.length} sətir`}
      actions={
        <>
          <Button variant="ghost" onClick={() => navigate('/inventory/returns')}>
            İmtina
          </Button>
          <Button
            variant="primary"
            loading={create.isPending}
            disabled={!headerValid || !linesValid}
            title={blockers.length > 0 ? `Əvvəlcə doldurun: ${blockers.join(', ')}` : undefined}
            onClick={() => create.mutate()}
          >
            Qaralama yarat
          </Button>
        </>
      }
    >
      {create.isError ? <ErrorState error={create.error} /> : null}

      <Alert tone="info" title="Qaralama yaradılır, ledger-ə yazılmır">
        Sənəd `DRAFT` statusunda yaranır. Mal yalnız «Təchizatçıya göndər» addımında balansdan çıxır
        — `RETURN` qrupu o zaman yazılır (SPEC §12.3).
      </Alert>

      <Card title="Sənəd başlığı">
        <MetaGrid columns={6}>
          <TextField
            label="Sənəd tarixi"
            required
            mono
            type="date"
            value={docDate}
            onChange={(e) => setDocDate(e.target.value)}
          />
          <RefPicker
            label="Təchizatçı"
            required
            value={supplierId}
            placeholder="Təchizatçı seçin"
            operation="GET /master-data/suppliers"
            listError={suppliers.error}
            options={(suppliers.data?.items ?? []).map((s) => ({
              value: String(s.id),
              label: s.name,
            }))}
            onChange={setSupplierId}
          />
          <RefPicker
            label="Lokasiya"
            required
            value={locationId}
            placeholder="Lokasiya seçin"
            operation="GET /master-data/locations"
            listError={locations.error}
            options={(locations.data?.items ?? [])
              .filter((l) => !l.isVirtual)
              .map((l) => ({ value: String(l.id), label: `${l.code} · ${l.name}` }))}
            onChange={setLocationId}
          />
          <TextField
            label="Mənbə qəbul id"
            mono
            value={receiptId}
            placeholder="boş = qəbulsuz"
            hint="Verildikdə sətirlər həmin qəbulun partiyaları ilə məhdudlaşır."
            onChange={(e) => setReceiptId(e.target.value)}
          />
          <ReasonCodePicker
            reasonGroup="RETURN"
            cacheKey="rtv"
            value={reasonCodeId}
            onChange={setReasonCodeId}
          />
          {canViewCost ? (
            <TextField
              label="İddia məbləği, AZN"
              mono
              value={claimAmount}
              placeholder="0.0000"
              hint="Təchizatçıya bildiriləcək ilkin məbləğ."
              onChange={(e) => setClaimAmount(e.target.value)}
            />
          ) : (
            <Meta
              label="İddia məbləği"
              value={<span className="wms-muted">icazə yoxdur</span>}
              sub="master.product.view_cost"
            />
          )}
        </MetaGrid>
      </Card>

      <Card
        title="Qaytarılan sətirlər"
        subtitle="Partiya tələb edən məhsul üçün partiya seçilməlidir"
        actions={
          <Button size="sm" onClick={() => setLines((prev) => [...prev, emptyLine()])}>
            Sətir əlavə et
          </Button>
        }
      >
        <div className="wms-stack">
          {lines.map((line, index) => {
            const errors = line.dirty ? lineErrors(line) : {};
            const product = (products.data?.items ?? []).find(
              (p) => String(p.id) === line.productId,
            );
            const batchOptions = batchesFor.get(line.productId) ?? [];
            return (
              <Card key={line.key}>
                <MetaGrid columns={4}>
                  <RefPicker
                    label={`Sətir ${index + 1} · məhsul`}
                    required
                    value={line.productId}
                    placeholder="Məhsul seçin"
                    operation="GET /master-data/products"
                    listError={products.error}
                    error={errors.productId}
                    options={(products.data?.items ?? []).map((p) => ({
                      value: String(p.id),
                      label: `${p.sku} · ${p.name}`,
                    }))}
                    onChange={(value) =>
                      update(line.key, { productId: value, batchId: '', uomId: '' })
                    }
                  />
                  <Select
                    label="Partiya"
                    value={line.batchId}
                    placeholder={
                      batchOptions.length === 0
                        ? locationId
                          ? 'Bu lokasiyada partiya qalığı yoxdur'
                          : 'Əvvəlcə lokasiya seçin'
                        : 'Partiya seçin'
                    }
                    disabled={batchOptions.length === 0}
                    hint="Partiyasız məhsul üçün boş qalır."
                    options={batchOptions.map((b) => ({
                      value: String(b.id),
                      label: `${b.batchNo} · ${b.available}`,
                    }))}
                    onChange={(e) => update(line.key, { batchId: e.target.value })}
                  />
                  <QtyUomInput
                    label="Qaytarılan miqdar"
                    required
                    qty={line.qty}
                    uomId={line.uomId || String(product?.baseUomId ?? '')}
                    error={errors.qty}
                    baseUomCode={product?.baseUomCode}
                    decimals={4}
                    uoms={
                      product
                        ? [
                            {
                              id: product.baseUomId,
                              code: product.baseUomCode ?? '—',
                              factorToBase: 1,
                            },
                          ]
                        : [{ id: '', code: '—', factorToBase: 1 }]
                    }
                    onQtyChange={(value) => update(line.key, { qty: value })}
                    onUomChange={(value) => update(line.key, { uomId: value })}
                  />
                  <div className="wms-row">
                    <TextField
                      label="Qeyd"
                      value={line.note}
                      hint="Nə üçün qaytarılır"
                      onChange={(e) => update(line.key, { note: e.target.value })}
                    />
                    <Button
                      size="sm"
                      variant="ghost"
                      disabled={lines.length <= 1}
                      title={lines.length <= 1 ? 'Ən azı bir sətir olmalıdır' : undefined}
                      onClick={() => removeLine(line.key)}
                    >
                      Sil
                    </Button>
                  </div>
                </MetaGrid>
              </Card>
            );
          })}
          <TextField
            label="Sənəd qeydi"
            value={note}
            hint="Audit jurnalına yazılır."
            onChange={(e) => setNote(e.target.value)}
          />
          {stock.isError ? (
            <Badge tone="warning" variant="outline">
              Partiya qalıqları yüklənmədi — partiya seçimi boşdur
            </Badge>
          ) : null}
        </div>
      </Card>
    </DocumentPage>
  );
}
