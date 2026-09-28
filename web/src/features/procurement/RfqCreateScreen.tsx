import { useEffect, useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { Alert, Badge, Button, QtyUomInput, TextField } from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  createRfq,
  getRequisition,
  listProducts,
  listSuppliers,
  type ProductSummary,
  type SupplierSummary,
} from '@api/endpoints';
import { useProductUoms } from '@api/productUoms';
import { Decimal } from '@core/decimal';
import { Card, DocumentPage, ErrorState, MetaGrid } from '@/components/Page';
import { RefPicker } from '@/components/RefPicker';

/**
 * New request for quotation (spec §11.2).
 *
 * The contract requires **at least two suppliers** (`minItems: 2`) — an RFQ with one supplier is
 * not a comparison, it is a purchase decision wearing a comparison's clothes. The rule is stated on
 * the screen rather than left to a 422, because a buyer who has only one supplier in mind needs to
 * know to add a second, not to be told their request was malformed.
 *
 * Arriving with `?requisitionId=` copies that requisition's lines, and each copied line keeps its
 * `requisitionLineId` so the chain stays traceable from quotation back to the branch that asked.
 */

interface DraftLine {
  key: string;
  dirty: boolean;
  productId: string;
  qty: string;
  uomId: string;
  note: string;
  requisitionLineId?: number;
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

export function RfqCreateScreen() {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const requisitionId = Number(params.get('requisitionId')) || 0;

  const [docDate, setDocDate] = useState(today);
  const [dueDate, setDueDate] = useState('');
  const [note, setNote] = useState('');
  const [supplierIds, setSupplierIds] = useState<string[]>([]);
  const [lines, setLines] = useState<DraftLine[]>([emptyLine()]);

  const products = useApiPage<ProductSummary>(
    ['products', 'rfq'],
    () => listProducts({ page: 1, size: 200, isActive: true }),
    200,
    { retry: false },
  );
  const suppliers = useApiPage<SupplierSummary>(
    ['suppliers', 'rfq'],
    () => listSuppliers({ page: 1, size: 200, isActive: true }),
    200,
    { retry: false },
  );

  const requisition = useApiQuery<{
    docNo: string;
    lines: Array<{
      id: number;
      product: { id: number };
      qty: string;
      uomId: number;
      note?: string | null;
    }>;
  }>(['requisition', requisitionId], () => getRequisition(requisitionId) as never, {
    enabled: requisitionId > 0,
    retry: false,
  });

  // The requisition's lines are copied once, when they arrive. Editing them afterwards is the
  // buyer's business — quantities are routinely trimmed before going out to suppliers.
  useEffect(() => {
    const source = requisition.data?.lines;
    if (!source || source.length === 0) return;
    setLines(
      source.map((l) => ({
        key: crypto.randomUUID(),
        dirty: false,
        productId: String(l.product.id),
        qty: l.qty,
        uomId: String(l.uomId),
        note: l.note ?? '',
        requisitionLineId: l.id,
      })),
    );
  }, [requisition.data]);

  const update = (key: string, patch: Partial<DraftLine>) =>
    setLines((prev) => prev.map((l) => (l.key === key ? { ...l, ...patch, dirty: true } : l)));

  const removeLine = (key: string) =>
    setLines((prev) => (prev.length <= 1 ? prev : prev.filter((l) => l.key !== key)));

  const toggleSupplier = (id: string) =>
    setSupplierIds((prev) => (prev.includes(id) ? prev.filter((s) => s !== id) : [...prev, id]));

  function lineErrors(line: DraftLine): Record<string, string> {
    const errors: Record<string, string> = {};
    if (!line.productId) errors.productId = 'Məhsul seçin.';
    if (!line.qty) errors.qty = 'Miqdarı yazın.';
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
  const enoughSuppliers = supplierIds.length >= 2;
  const headerValid = Boolean(docDate) && enoughSuppliers;

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
      createRfq({
        docDate,
        ...(dueDate ? { dueDate } : {}),
        supplierIds: supplierIds.map(Number),
        ...(note.trim() ? { note: note.trim() } : {}),
        lines: lines.map((l) => ({
          productId: Number(l.productId),
          // `qty` stays the contract's decimal string all the way to the wire (ADR-008).
          qty: l.qty,
          uomId: uomOf(l),
          ...(l.requisitionLineId ? { requisitionLineId: l.requisitionLineId } : {}),
          ...(l.note.trim() ? { note: l.note.trim() } : {}),
        })),
      }),
    onSuccess: (doc) => navigate(`/procurement/rfqs/${(doc as { id: number }).id}`),
  });

  const blockers: string[] = [];
  if (!docDate) blockers.push('sənəd tarixi');
  if (!enoughSuppliers) blockers.push('ən azı iki təchizatçı');
  if (!linesValid) blockers.push('sətirlər');

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/procurement/requisitions">Satınalma</Link> ·{' '}
          <Link to="/procurement/rfqs">RFQ</Link>
        </>
      }
      docNo="Yeni RFQ"
      mono={false}
      status="DRAFT"
      context={`${supplierIds.length} təchizatçı · ${lines.length} sətir`}
      actions={
        <>
          <Button variant="ghost" onClick={() => navigate('/procurement/rfqs')}>
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

      <Alert tone="info" title="Müqayisə üçün ən azı iki təchizatçı lazımdır">
        Bir təchizatçılı RFQ müqayisə deyil — o, müqayisə görkəmində verilmiş qərardır. Server də bir
        təchizatçını qəbul etmir.
      </Alert>

      {requisition.data ? (
        <Alert tone="info" title={`Tələbnamədən köçürüldü: ${requisition.data.docNo}`}>
          Sətirlər tələbnamədən gəldi və hər biri öz tələbnamə sətrinə bağlı qalır. Miqdarları
          dəyişmək olar — təchizatçıya çıxmazdan əvvəl azaltmaq adi işdir.
        </Alert>
      ) : null}

      <Card title="RFQ başlığı">
        <MetaGrid columns={6}>
          <TextField
            label="Sənəd tarixi"
            required
            mono
            type="date"
            value={docDate}
            onChange={(e) => setDocDate(e.target.value)}
          />
          <TextField
            label="Cavab son tarixi"
            mono
            type="date"
            value={dueDate}
            hint="Təchizatçının təklif verə biləcəyi son gün."
            onChange={(e) => setDueDate(e.target.value)}
          />
          <div style={{ gridColumn: 'span 4' }}>
            <TextField
              label="Qeyd"
              value={note}
              hint="Təchizatçıya göndərilən mətnə düşür."
              onChange={(e) => setNote(e.target.value)}
            />
          </div>
        </MetaGrid>
      </Card>

      <Card
        title="Təchizatçılar"
        actions={
          <Badge tone={enoughSuppliers ? 'success' : 'warning'}>
            {`${supplierIds.length} seçildi`}
          </Badge>
        }
      >
        {suppliers.isError ? (
          <ErrorState error={suppliers.error} />
        ) : (
          <div className="wms-row">
            {(suppliers.data?.items ?? []).map((supplier) => {
              const id = String(supplier.id);
              const selected = supplierIds.includes(id);
              return (
                <Button
                  key={id}
                  size="sm"
                  variant={selected ? 'primary' : 'secondary'}
                  aria-pressed={selected}
                  onClick={() => toggleSupplier(id)}
                >
                  {supplier.name}
                </Button>
              );
            })}
          </div>
        )}
        {!enoughSuppliers ? (
          <div className="wms-muted wms-small">
            Ən azı iki təchizatçı seçin — indi {supplierIds.length} seçilib.
          </div>
        ) : null}
      </Card>

      <Card
        title="RFQ sətirləri"
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
                    label="Sətir qeydi"
                    value={line.note}
                    onChange={(e) => update(line.key, { note: e.target.value })}
                  />
                  <div className="wms-row">
                    {line.requisitionLineId ? (
                      <Badge tone="neutral" title="Tələbnamə sətrinə bağlıdır">
                        PR sətri
                      </Badge>
                    ) : null}
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
