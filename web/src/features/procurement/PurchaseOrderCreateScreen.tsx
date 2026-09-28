import { useEffect, useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { Alert, Button, QtyUomInput, TextField } from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  createPurchaseOrder,
  getQuotation,
  listCurrencyRates,
  listLocations,
  listProducts,
  listSuppliers,
  type Location,
  type ProductSummary,
  type SupplierSummary,
} from '@api/endpoints';
import { useProductUoms } from '@api/productUoms';
import { Decimal } from '@core/decimal';
import { formatNumber } from '@core/format';
import { Card, DocumentPage, ErrorState, MetaGrid } from '@/components/Page';
import { RefPicker } from '@/components/RefPicker';

/**
 * New purchase order (spec §11.5).
 *
 * Normally reached from a chosen quotation (`?quotationId=`), which fills the supplier, the
 * currency, the lines and the prices — the comparison has already decided those, and retyping them
 * is how a price ends up differing from the offer that was accepted. A blank order is still
 * possible for a direct purchase with no RFQ behind it.
 *
 * The order is created as a DRAFT; approval and sending happen on the detail screen.
 */

interface DraftLine {
  key: string;
  dirty: boolean;
  productId: string;
  productLabel: string;
  qty: string;
  uomId: string;
  unitPrice: string;
  vatRate: string;
  requisitionLineId?: number;
}

const emptyLine = (): DraftLine => ({
  key: crypto.randomUUID(),
  dirty: false,
  productId: '',
  productLabel: '',
  qty: '',
  uomId: '',
  unitPrice: '',
  vatRate: '',
});

const today = () => new Date().toISOString().slice(0, 10);

export function PurchaseOrderCreateScreen() {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const quotationId = Number(params.get('quotationId')) || 0;

  const [docDate, setDocDate] = useState(today);
  const [supplierId, setSupplierId] = useState('');
  const [currency, setCurrency] = useState('AZN');
  const [deliveryLocationId, setDeliveryLocationId] = useState('');
  const [expectedDate, setExpectedDate] = useState('');
  const [incoterms, setIncoterms] = useState('');
  const [paymentTerms, setPaymentTerms] = useState('');
  const [note, setNote] = useState('');
  const [lines, setLines] = useState<DraftLine[]>([emptyLine()]);

  const products = useApiPage<ProductSummary>(
    ['products', 'purchase-order'],
    () => listProducts({ page: 1, size: 200, isActive: true }),
    200,
    { retry: false },
  );
  const suppliers = useApiPage<SupplierSummary>(
    ['suppliers', 'purchase-order'],
    () => listSuppliers({ page: 1, size: 200, isActive: true }),
    200,
    { retry: false },
  );
  const locations = useApiPage<Location>(
    ['locations', 'purchase-order'],
    () => listLocations({}),
    200,
    { retry: false },
  );
  const currencies = useApiPage<{ currency: string }>(
    ['currency-rates', 'purchase-order'],
    () => listCurrencyRates({ page: 1, size: 100 }),
    100,
    { retry: false },
  );

  const quotation = useApiQuery<{
    id: number;
    quoteNo?: string | null;
    currency: string;
    supplier: { id: number; name: string };
    paymentTerms?: string | null;
    lines: Array<{
      id: number;
      product: { id: number; sku: string; name: string };
      qty: string;
      uomId: number;
      unitPrice: string;
    }>;
  }>(['quotation', quotationId], () => getQuotation(quotationId) as never, {
    enabled: quotationId > 0,
    retry: false,
  });

  // Copied once, when the quotation arrives: supplier, currency, terms and the priced lines.
  useEffect(() => {
    const source = quotation.data;
    if (!source) return;
    setSupplierId(String(source.supplier.id));
    setCurrency(source.currency);
    if (source.paymentTerms) setPaymentTerms(source.paymentTerms);
    setLines(
      source.lines.map((l) => ({
        key: crypto.randomUUID(),
        dirty: false,
        productId: String(l.product.id),
        productLabel: `${l.product.sku} · ${l.product.name}`,
        qty: l.qty,
        uomId: String(l.uomId),
        unitPrice: l.unitPrice,
        vatRate: '',
      })),
    );
  }, [quotation.data]);

  const update = (key: string, patch: Partial<DraftLine>) =>
    setLines((prev) => prev.map((l) => (l.key === key ? { ...l, ...patch, dirty: true } : l)));

  const removeLine = (key: string) =>
    setLines((prev) => (prev.length <= 1 ? prev : prev.filter((l) => l.key !== key)));

  function lineErrors(line: DraftLine): Record<string, string> {
    const errors: Record<string, string> = {};
    if (!line.productId) errors.productId = 'Məhsul seçin.';
    if (!line.qty) errors.qty = 'Miqdarı yazın.';
    if (!line.unitPrice) errors.unitPrice = 'Vahid qiyməti yazın.';
    else {
      try {
        if (new Decimal(line.unitPrice).lessThan(0)) errors.unitPrice = 'Qiymət mənfi ola bilməz.';
      } catch {
        errors.unitPrice = 'Qiymət onluq ədəd olmalıdır.';
      }
    }
    return errors;
  }

  const lineTotal = (line: DraftLine): Decimal | null => {
    try {
      return new Decimal(line.qty || '0').times(new Decimal(line.unitPrice || '0'));
    } catch {
      return null;
    }
  };

  const total = lines.reduce((sum, line) => {
    const value = lineTotal(line);
    return value ? sum.plus(value) : sum;
  }, new Decimal(0));

  const linesValid = lines.every((l) => Object.keys(lineErrors(l)).length === 0);
  const headerValid = Boolean(docDate && supplierId && currency && deliveryLocationId);

  const productOf = (productId: string): ProductSummary | undefined =>
    (products.data?.items ?? []).find((p) => String(p.id) === productId);

  const productUoms = useProductUoms(
    lines.map((l) => Number(l.productId)).filter((id) => Number.isFinite(id) && id > 0),
    'issue',
  );

  const uomOf = (line: DraftLine): number => {
    if (line.uomId) return Number(line.uomId);
    const p = productOf(line.productId);
    return productUoms.uomsFor(p).defaultUomId ?? p?.baseUomId ?? 0;
  };

  const create = useMutation({
    mutationFn: () =>
      createPurchaseOrder({
        docDate,
        supplierId: Number(supplierId),
        currency,
        deliveryLocationId: Number(deliveryLocationId),
        ...(expectedDate ? { expectedDate } : {}),
        ...(incoterms.trim() ? { incoterms: incoterms.trim() } : {}),
        ...(paymentTerms.trim() ? { paymentTerms: paymentTerms.trim() } : {}),
        ...(quotationId ? { quotationId } : {}),
        ...(note.trim() ? { note: note.trim() } : {}),
        lines: lines.map((l) => ({
          productId: Number(l.productId),
          qty: l.qty,
          uomId: uomOf(l),
          unitPrice: l.unitPrice,
          ...(l.vatRate ? { vatRate: l.vatRate } : {}),
          ...(l.requisitionLineId ? { requisitionLineId: l.requisitionLineId } : {}),
        })),
      }),
    onSuccess: (doc) => navigate(`/procurement/purchase-orders/${(doc as { id: number }).id}`),
  });

  const blockers: string[] = [];
  if (!docDate) blockers.push('sənəd tarixi');
  if (!supplierId) blockers.push('təchizatçı');
  if (!deliveryLocationId) blockers.push('çatdırılma lokasiyası');
  if (!linesValid) blockers.push('qiymətlər');

  const locationOptions = (locations.data?.items ?? [])
    .filter((l) => !l.isVirtual)
    .map((l) => ({ value: String(l.id), label: `${l.name} (${l.code})` }));

  const currencyOptions = Array.from(
    new Set([currency, 'AZN', ...(currencies.data?.items ?? []).map((r) => r.currency)]),
  ).map((code) => ({ value: code, label: code }));

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/procurement/requisitions">Satınalma</Link> ·{' '}
          <Link to="/procurement/purchase-orders">Sifarişlər</Link>
        </>
      }
      docNo="Yeni sifariş"
      mono={false}
      status="DRAFT"
      context={`${lines.length} sətir · ${formatNumber(total.toString(), 2)} ${currency}`}
      actions={
        <>
          <Button variant="ghost" onClick={() => navigate('/procurement/purchase-orders')}>
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

      <Alert tone="info" title="Qaralama yaradılır, təchizatçıya göndərilmir">
        Sifariş `DRAFT` statusunda yaranır. Təsdiqə göndərmək və təchizatçıya çıxarmaq sənəd
        ekranındaki addımlardır.
      </Alert>

      {quotation.data ? (
        <Alert
          tone="info"
          title={`Təklifdən köçürüldü: ${quotation.data.quoteNo ?? `#${quotation.data.id}`}`}
        >
          Təchizatçı, valyuta və qiymətlər seçilmiş təklifdən gəldi. Onları yenidən yazmaq qəbul
          edilmiş təkliflə sifariş arasında fərq yaranmasının adi yoludur — dəyişmək lazımdırsa,
          səbəbi sifariş qeydində yazın.
        </Alert>
      ) : null}

      <Card title="Sifariş başlığı">
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
            operation="GET /masterdata/suppliers"
            listError={suppliers.error}
            options={(suppliers.data?.items ?? []).map((s) => ({
              value: String(s.id),
              label: s.name,
            }))}
            onChange={setSupplierId}
          />
          <RefPicker
            label="Çatdırılma lokasiyası"
            required
            value={deliveryLocationId}
            placeholder="Lokasiya seçin"
            operation="GET /masterdata/locations"
            listError={locations.error}
            options={locationOptions}
            onChange={setDeliveryLocationId}
          />
          <RefPicker
            label="Valyuta"
            required
            value={currency}
            placeholder="Valyuta"
            operation="GET /masterdata/currency-rates"
            listError={currencies.error}
            options={currencyOptions}
            onChange={setCurrency}
          />
          <TextField
            label="Gözlənilən tarix"
            mono
            type="date"
            value={expectedDate}
            onChange={(e) => setExpectedDate(e.target.value)}
          />
          <TextField
            label="Incoterms"
            value={incoterms}
            onChange={(e) => setIncoterms(e.target.value)}
          />
          <div style={{ gridColumn: 'span 3' }}>
            <TextField
              label="Ödəniş şərtləri"
              value={paymentTerms}
              onChange={(e) => setPaymentTerms(e.target.value)}
            />
          </div>
          <div style={{ gridColumn: 'span 3' }}>
            <TextField
              label="Qeyd"
              value={note}
              hint="Təsdiqləyənə görünür və audit jurnalına yazılır."
              onChange={(e) => setNote(e.target.value)}
            />
          </div>
        </MetaGrid>
      </Card>

      <Card
        title="Sifariş sətirləri"
        actions={
          quotationId ? null : (
            <Button size="sm" onClick={() => setLines((prev) => [...prev, emptyLine()])}>
              Sətir əlavə et
            </Button>
          )
        }
      >
        <div className="wms-stack">
          {lines.map((line, index) => {
            const errors = line.dirty ? lineErrors(line) : {};
            const product = productOf(line.productId);
            const uomSet = productUoms.uomsFor(product);
            const rowTotal = lineTotal(line);
            return (
              <Card key={line.key}>
                <MetaGrid columns={6}>
                  {line.productLabel ? (
                    <div>
                      <div className="wms-muted wms-small">{`Sətir ${index + 1} · məhsul`}</div>
                      <div>{line.productLabel}</div>
                    </div>
                  ) : (
                    <RefPicker
                      label={`Sətir ${index + 1} · məhsul`}
                      required
                      value={line.productId}
                      placeholder="Məhsul seçin"
                      operation="GET /masterdata/products"
                      listError={products.error}
                      error={errors.productId}
                      options={(products.data?.items ?? []).map((p) => ({
                        value: String(p.id),
                        label: `${p.sku} · ${p.name}`,
                      }))}
                      onChange={(value) => update(line.key, { productId: value, uomId: '' })}
                    />
                  )}
                  <QtyUomInput
                    label="Miqdar"
                    required
                    qty={line.qty}
                    uomId={line.uomId || String(uomSet.defaultUomId ?? '')}
                    error={errors.qty}
                    baseUomCode={product?.baseUomCode}
                    decimals={4}
                    uoms={
                      uomSet.options.length > 0
                        ? uomSet.options
                        : [{ id: '', code: '—', factorToBase: '1' }]
                    }
                    onQtyChange={(value) => update(line.key, { qty: value })}
                    onUomChange={(value) => update(line.key, { uomId: value })}
                  />
                  <TextField
                    label="Vahid qiymət"
                    required
                    mono
                    value={line.unitPrice}
                    error={errors.unitPrice}
                    onChange={(e) => update(line.key, { unitPrice: e.target.value })}
                  />
                  <TextField
                    label="ƏDV (%)"
                    mono
                    value={line.vatRate}
                    onChange={(e) => update(line.key, { vatRate: e.target.value })}
                  />
                  <div>
                    <div className="wms-muted wms-small">Sətir cəmi</div>
                    <div className="wms-num">
                      {rowTotal ? `${formatNumber(rowTotal.toString(), 2)} ${currency}` : '—'}
                    </div>
                  </div>
                  <div className="wms-row">
                    <Button
                      size="sm"
                      variant="ghost"
                      disabled={lines.length <= 1 || Boolean(quotationId)}
                      title={
                        quotationId
                          ? 'Təklifdən gələn sətirlər silinmir'
                          : lines.length <= 1
                            ? 'Ən azı bir sətir olmalıdır'
                            : undefined
                      }
                      onClick={() => removeLine(line.key)}
                    >
                      Sətri sil
                    </Button>
                  </div>
                </MetaGrid>
              </Card>
            );
          })}
        </div>
        <div className="wms-row">
          <strong>{`Ümumi: ${formatNumber(total.toString(), 2)} ${currency}`}</strong>
        </div>
      </Card>
    </DocumentPage>
  );
}
