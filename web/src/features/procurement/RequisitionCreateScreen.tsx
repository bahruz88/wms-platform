import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { Alert, Button, QtyUomInput, Select, TextField } from '@ds/index';
import { useApiPage } from '@api/hooks';
import {
  createRequisition,
  listLocations,
  listProducts,
  type Location,
  type ProductSummary,
} from '@api/endpoints';
import { useProductUoms } from '@api/productUoms';
import { Decimal } from '@core/decimal';
import { Card, DocumentPage, ErrorState, MetaGrid } from '@/components/Page';
import { RefPicker } from '@/components/RefPicker';

/**
 * New requisition — the first document of the purchasing chain (spec §8.1).
 *
 * It is created as a `DRAFT` and reaches procurement only after «Təsdiqə göndər» on the detail
 * screen, so the primary button here promises a draft and nothing more.
 *
 * `productType` splits the tenant's approval rules (food and non-food are approved by different
 * people), which is why it is a required header field rather than something derived per line.
 */

interface DraftLine {
  key: string;
  dirty: boolean;
  productId: string;
  qty: string;
  uomId: string;
  note: string;
}

const emptyLine = (): DraftLine => ({
  key: crypto.randomUUID(),
  dirty: false,
  productId: '',
  qty: '',
  uomId: '',
  note: '',
});

const today = () => new Date().toISOString().slice(0, 10);

export function RequisitionCreateScreen() {
  const navigate = useNavigate();

  const [docDate, setDocDate] = useState(today);
  const [requesterLocationId, setRequesterLocationId] = useState('');
  const [productType, setProductType] = useState('FOOD');
  const [priority, setPriority] = useState('NORMAL');
  const [requiredDate, setRequiredDate] = useState('');
  const [note, setNote] = useState('');
  const [lines, setLines] = useState<DraftLine[]>([emptyLine()]);

  /*
   * The product list is filtered by the header's `productType`.
   *
   * Not cosmetic: the server refuses a line whose product belongs to the other type
   * (`422 PRODUCT_TYPE_MISMATCH`), because food and non-food follow different approval chains. A
   * picker that offered both would let someone build a document the server will reject, and the
   * rejection would name a product id rather than the mistake.
   */
  const products = useApiPage<ProductSummary>(
    ['products', 'requisition', productType],
    () =>
      listProducts({
        page: 1,
        size: 200,
        isActive: true,
        productType: productType as 'FOOD' | 'NON_FOOD',
      }),
    200,
    { retry: false },
  );
  const locations = useApiPage<Location>(['locations', 'requisition'], () => listLocations({}), 200, {
    retry: false,
  });

  const update = (key: string, patch: Partial<DraftLine>) =>
    setLines((prev) => prev.map((l) => (l.key === key ? { ...l, ...patch, dirty: true } : l)));

  const removeLine = (key: string) =>
    setLines((prev) => (prev.length <= 1 ? prev : prev.filter((l) => l.key !== key)));

  function lineErrors(line: DraftLine): Record<string, string> {
    const errors: Record<string, string> = {};
    if (!line.productId) errors.productId = 'Məhsul seçin.';
    if (!line.qty) errors.qty = 'Tələb olunan miqdarı yazın.';
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

  const linesValid = lines.every((l) => Object.keys(lineErrors(l)).length === 0);
  const headerValid = Boolean(docDate && requesterLocationId && productType);

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
      createRequisition({
        docDate,
        requesterLocationId: Number(requesterLocationId),
        productType: productType as 'FOOD' | 'NON_FOOD',
        priority: priority as 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT',
        ...(requiredDate ? { requiredDate } : {}),
        ...(note.trim() ? { note: note.trim() } : {}),
        lines: lines.map((l) => ({
          productId: Number(l.productId),
          // `qty` stays the contract's decimal string all the way to the wire (ADR-008).
          qty: l.qty,
          uomId: uomOf(l),
          ...(l.note.trim() ? { note: l.note.trim() } : {}),
        })),
      }),
    onSuccess: (doc) => navigate(`/procurement/requisitions/${(doc as { id: number }).id}`),
  });

  const blockers: string[] = [];
  if (!docDate) blockers.push('sənəd tarixi');
  if (!requesterLocationId) blockers.push('tələb edən lokasiya');
  if (!linesValid) blockers.push('sətirlər');

  const locationOptions = (locations.data?.items ?? [])
    .filter((l) => !l.isVirtual)
    .map((l) => ({ value: String(l.id), label: `${l.name} (${l.code})` }));

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/procurement/requisitions">Satınalma</Link> ·{' '}
          <Link to="/procurement/requisitions">Tələbnamə</Link>
        </>
      }
      docNo="Yeni tələbnamə"
      mono={false}
      status="DRAFT"
      context={`${lines.length} sətir`}
      actions={
        <>
          <Button variant="ghost" onClick={() => navigate('/procurement/requisitions')}>
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

      <Alert tone="info" title="Qaralama yaradılır, satınalmaya göndərilmir">
        Tələbnamə `DRAFT` statusunda yaranır. Satınalmanın növbəsinə yalnız sənəd ekranındakı
        «Təsdiqə göndər» addımından sonra düşür.
      </Alert>

      <Card title="Tələbnamə başlığı">
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
            label="Tələb edən lokasiya"
            required
            value={requesterLocationId}
            placeholder="Lokasiya seçin"
            operation="GET /masterdata/locations"
            listError={locations.error}
            options={locationOptions}
            onChange={setRequesterLocationId}
          />
          <Select
            label="Məhsul tipi"
            required
            value={productType}
            hint="Təsdiq zənciri buna görə seçilir."
            options={[
              { value: 'FOOD', label: 'Ərzaq' },
              { value: 'NON_FOOD', label: 'Ərzaq olmayan' },
            ]}
            onChange={(e) => {
              setProductType(e.target.value);
              // The chosen products no longer belong to this type, so the lines are cleared rather
              // than left pointing at something the server will refuse.
              setLines([emptyLine()]);
            }}
          />
          <Select
            label="Prioritet"
            value={priority}
            options={[
              { value: 'LOW', label: 'Aşağı' },
              { value: 'NORMAL', label: 'Normal' },
              { value: 'HIGH', label: 'Yüksək' },
              { value: 'URGENT', label: 'Təcili' },
            ]}
            onChange={(e) => setPriority(e.target.value)}
          />
          <TextField
            label="Tələb olunan tarix"
            mono
            type="date"
            value={requiredDate}
            hint="Satınalma bu tarixə görə növbə qurur."
            onChange={(e) => setRequiredDate(e.target.value)}
          />
          <div style={{ gridColumn: 'span 2' }}>
            <TextField
              label="Qeyd"
              value={note}
              hint="Satınalmaya görünür və audit jurnalına yazılır."
              onChange={(e) => setNote(e.target.value)}
            />
          </div>
        </MetaGrid>
      </Card>

      <Card
        title="Tələbnamə sətirləri"
        actions={
          <Button size="sm" onClick={() => setLines((prev) => [...prev, emptyLine()])}>
            Sətir əlavə et
          </Button>
        }
      >
        <div className="wms-stack">
          {lines.map((line, index) => {
            const errors = line.dirty ? lineErrors(line) : {};
            const product = productOf(line.productId);
            const uomSet = productUoms.uomsFor(product);
            return (
              <Card key={line.key}>
                <MetaGrid columns={4}>
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
                  <QtyUomInput
                    label="Tələb olunan miqdar"
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
                    label="Sətir qeydi"
                    value={line.note}
                    onChange={(e) => update(line.key, { note: e.target.value })}
                  />
                  <div className="wms-row">
                    <Button
                      size="sm"
                      variant="ghost"
                      disabled={lines.length <= 1}
                      title={lines.length <= 1 ? 'Ən azı bir sətir olmalıdır' : undefined}
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
      </Card>
    </DocumentPage>
  );
}
