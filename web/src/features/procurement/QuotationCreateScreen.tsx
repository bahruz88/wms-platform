import { useEffect, useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { Alert, Button, QtyUomInput, TextField } from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  createQuotation,
  getRfq,
  listCurrencyRates,
  listProducts,
  listSuppliers,
  type ProductSummary,
  type SupplierSummary,
} from '@api/endpoints';
import { useProductUoms } from '@api/productUoms';
import { Decimal } from '@core/decimal';
import { formatNumber } from '@core/format';
import { Card, DocumentPage, ErrorState, MetaGrid } from '@/components/Page';
import { RefPicker } from '@/components/RefPicker';

/**
 * Entering a supplier's quotation (spec §11.3).
 *
 * The supplier does not use this system — a buyer types in what arrived by email or on paper. That
 * shapes the screen: the lines come pre-filled from the RFQ so the buyer only fills prices, and the
 * line total is computed as they type so a mistyped price is visible before the offer is saved.
 *
 * Prices are `Decimal` strings end to end (ADR-008). The running total is computed the same way —
 * a float here would put a cent of drift into the comparison that decides the order.
 */

interface DraftLine {
  key: string;
  dirty: boolean;
  rfqLineId?: number;
  productId: string;
  productLabel: string;
  qty: string;
  uomId: string;
  unitPrice: string;
  note: string;
}

const emptyLine = (): DraftLine => ({
  key: crypto.randomUUID(),
  dirty: false,
  productId: '',
  productLabel: '',
  qty: '',
  uomId: '',
  unitPrice: '',
  note: '',
});

const today = () => new Date().toISOString().slice(0, 10);

export function QuotationCreateScreen() {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const rfqId = Number(params.get('rfqId')) || 0;

  const [supplierId, setSupplierId] = useState('');
  const [quoteNo, setQuoteNo] = useState('');
  const [quoteDate, setQuoteDate] = useState(today);
  const [validUntil, setValidUntil] = useState('');
  const [currency, setCurrency] = useState('AZN');
  const [deliveryDays, setDeliveryDays] = useState('');
  const [paymentTerms, setPaymentTerms] = useState('');
  const [lines, setLines] = useState<DraftLine[]>([emptyLine()]);

  const products = useApiPage<ProductSummary>(
    ['products', 'quotation'],
    () => listProducts({ page: 1, size: 200, isActive: true }),
    200,
    { retry: false },
  );
  const suppliers = useApiPage<SupplierSummary>(
    ['suppliers', 'quotation'],
    () => listSuppliers({ page: 1, size: 200, isActive: true }),
    200,
    { retry: false },
  );

  const rfq = useApiQuery<{
    docNo: string;
    suppliers: Array<{ id: number; name: string }>;
    lines: Array<{
      id: number;
      product: { id: number; sku: string; name: string };
      qty: string;
      uomId: number;
    }>;
  }>(['rfq', rfqId], () => getRfq(rfqId) as never, { enabled: rfqId > 0, retry: false });

  // The RFQ's lines arrive once; the buyer fills prices against them rather than retyping products.
  useEffect(() => {
    const source = rfq.data?.lines;
    if (!source || source.length === 0) return;
    setLines(
      source.map((l) => ({
        key: crypto.randomUUID(),
        dirty: false,
        rfqLineId: l.id,
        productId: String(l.product.id),
        productLabel: `${l.product.sku} · ${l.product.name}`,
        qty: l.qty,
        uomId: String(l.uomId),
        unitPrice: '',
        note: '',
      })),
    );
  }, [rfq.data]);

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
  const headerValid = Boolean(supplierId && quoteDate && currency);

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

  const currencies = useApiPage<{ currency: string }>(
    ['currency-rates', 'quotation'],
    () => listCurrencyRates({ page: 1, size: 100 }),
    100,
    { retry: false },
  );

  const create = useMutation({
    mutationFn: () =>
      createQuotation({
        ...(rfqId ? { rfqId } : {}),
        supplierId: Number(supplierId),
        ...(quoteNo.trim() ? { quoteNo: quoteNo.trim() } : {}),
        quoteDate,
        ...(validUntil ? { validUntil } : {}),
        currency,
        ...(deliveryDays ? { deliveryDays: Number(deliveryDays) } : {}),
        ...(paymentTerms.trim() ? { paymentTerms: paymentTerms.trim() } : {}),
        lines: lines.map((l) => ({
          ...(l.rfqLineId ? { rfqLineId: l.rfqLineId } : {}),
          productId: Number(l.productId),
          qty: l.qty,
          uomId: uomOf(l),
          unitPrice: l.unitPrice,
          ...(l.note.trim() ? { note: l.note.trim() } : {}),
        })),
      }),
    onSuccess: () =>
      navigate(rfqId ? `/procurement/rfqs/${rfqId}/comparison` : '/procurement/quotations'),
  });

  const blockers: string[] = [];
  if (!supplierId) blockers.push('təchizatçı');
  if (!quoteDate) blockers.push('təklif tarixi');
  if (!linesValid) blockers.push('qiymətlər');

  // When the quotation answers an RFQ, only the invited suppliers may be chosen.
  const invited = rfq.data?.suppliers;
  const supplierOptions = (suppliers.data?.items ?? [])
    .filter((s) => !invited || invited.some((i) => i.id === s.id))
    .map((s) => ({ value: String(s.id), label: s.name }));

  const currencyOptions = Array.from(
    new Set(['AZN', ...(currencies.data?.items ?? []).map((r) => r.currency)]),
  ).map((code) => ({ value: code, label: code }));

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/procurement/requisitions">Satınalma</Link> ·{' '}
          <Link to="/procurement/quotations">Təkliflər</Link>
        </>
      }
      docNo="Yeni təklif"
      mono={false}
      status="DRAFT"
      context={`${lines.length} sətir · ${formatNumber(total.toString(), 2)} ${currency}`}
      actions={
        <>
          <Button variant="ghost" onClick={() => navigate('/procurement/quotations')}>
            İmtina
          </Button>
          <Button
            variant="primary"
            loading={create.isPending}
            disabled={!headerValid || !linesValid}
            title={blockers.length > 0 ? `Əvvəlcə doldurun: ${blockers.join(', ')}` : undefined}
            onClick={() => create.mutate()}
          >
            Təklifi yaz
          </Button>
        </>
      }
    >
      {create.isError ? <ErrorState error={create.error} /> : null}

      <Alert tone="info" title="Təklifi təchizatçı deyil, siz yazırsınız">
        Təchizatçı bu sistemdən istifadə etmir — e-poçtla və ya kağızla gələn təklif burada qeydə
        alınır. Sətir cəmi yazdıqca hesablanır, ona görə səhv qiymət yadda saxlanmazdan əvvəl görünür.
      </Alert>

      {rfq.data ? (
        <Alert tone="info" title={`RFQ: ${rfq.data.docNo}`}>
          Sətirlər RFQ-dan gəldi — yalnız qiymətləri doldurun. Təchizatçı seçimi RFQ-ya dəvət
          edilənlərlə məhdudlaşır.
        </Alert>
      ) : null}

      <Card title="Təklif başlığı">
        <MetaGrid columns={6}>
          <RefPicker
            label="Təchizatçı"
            required
            value={supplierId}
            placeholder="Təchizatçı seçin"
            operation="GET /masterdata/suppliers"
            listError={suppliers.error}
            options={supplierOptions}
            onChange={setSupplierId}
          />
          <TextField
            label="Təklif nömrəsi"
            value={quoteNo}
            hint="Təchizatçının öz nömrəsi."
            onChange={(e) => setQuoteNo(e.target.value)}
          />
          <TextField
            label="Təklif tarixi"
            required
            mono
            type="date"
            value={quoteDate}
            onChange={(e) => setQuoteDate(e.target.value)}
          />
          <TextField
            label="Etibarlıdır"
            mono
            type="date"
            value={validUntil}
            onChange={(e) => setValidUntil(e.target.value)}
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
            label="Çatdırılma (gün)"
            mono
            value={deliveryDays}
            onChange={(e) => setDeliveryDays(e.target.value.replace(/[^0-9]/g, ''))}
          />
          <div style={{ gridColumn: 'span 3' }}>
            <TextField
              label="Ödəniş şərtləri"
              value={paymentTerms}
              onChange={(e) => setPaymentTerms(e.target.value)}
            />
          </div>
        </MetaGrid>
      </Card>

      <Card
        title="Təklif sətirləri"
        actions={
          rfqId ? null : (
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
                  {line.rfqLineId ? (
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
                      disabled={lines.length <= 1 || Boolean(line.rfqLineId)}
                      title={
                        line.rfqLineId
                          ? 'RFQ sətri silinmir — qiymət verilmirsə sıfır yazın'
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
