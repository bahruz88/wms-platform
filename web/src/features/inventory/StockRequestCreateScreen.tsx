import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { Alert, Button, QtyUomInput, TextField } from '@ds/index';
import { useApiPage } from '@api/hooks';
import {
  createStockRequest,
  listLocations,
  listProducts,
  type Location,
  type ProductSummary,
} from '@api/endpoints';
import { Decimal } from '@core/decimal';
import { Card, DocumentPage, ErrorState, MetaGrid } from '@/components/Page';
import { RefPicker } from '@/components/RefPicker';

/**
 * New stock request — docs/ux/screen-map.md §3.5, the branch asking the warehouse for goods.
 *
 * The document is created as a `DRAFT`; it only reaches the warehouse's queue after «Təsdiqə
 * göndər» on the detail screen, which is why the primary button here says «Qaralama yarat» and
 * the alert says what has and has not happened.
 *
 * `fromLocation` must differ from `toLocation` — the server refuses it with `422`, and the
 * disabled primary says so before the request goes out.
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

export function StockRequestCreateScreen() {
  const navigate = useNavigate();

  const [docDate, setDocDate] = useState(today);
  const [requiredDate, setRequiredDate] = useState('');
  const [fromLocationId, setFromLocationId] = useState('');
  const [toLocationId, setToLocationId] = useState('');
  const [note, setNote] = useState('');
  const [lines, setLines] = useState<DraftLine[]>([emptyLine()]);

  const products = useApiPage<ProductSummary>(
    ['products', 'stock-request'],
    () => listProducts({ page: 1, size: 200, isActive: true }),
    200,
    { retry: false },
  );
  const locations = useApiPage<Location>(
    ['locations', 'stock-request'],
    () => listLocations({}),
    200,
    { retry: false },
  );

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

  const sameLocation = Boolean(fromLocationId) && fromLocationId === toLocationId;
  const linesValid = lines.every((l) => Object.keys(lineErrors(l)).length === 0);
  const headerValid = Boolean(docDate && fromLocationId && toLocationId) && !sameLocation;

  const uomOf = (line: DraftLine): number => {
    if (line.uomId) return Number(line.uomId);
    const p = (products.data?.items ?? []).find((x) => String(x.id) === line.productId);
    return p?.baseUomId ?? 0;
  };

  const create = useMutation({
    mutationFn: () =>
      createStockRequest({
        docDate,
        fromLocationId: Number(fromLocationId),
        toLocationId: Number(toLocationId),
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
    onSuccess: (doc) => navigate(`/inventory/stock-requests/${doc.id}`),
  });

  const blockers: string[] = [];
  if (!docDate) blockers.push('sənəd tarixi');
  if (!fromLocationId) blockers.push('mənbə lokasiya');
  if (!toLocationId) blockers.push('təyinat lokasiya');
  if (sameLocation) blockers.push('fərqli lokasiyalar');
  if (!linesValid) blockers.push('sətirlər');

  const locationOptions = (locations.data?.items ?? [])
    .filter((l) => !l.isVirtual)
    .map((l) => ({ value: String(l.id), label: `${l.code} · ${l.name}` }));

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/inventory/balances">Anbar</Link> ·{' '}
          <Link to="/inventory/stock-requests">Mal tələbi</Link>
        </>
      }
      docNo="Yeni mal tələbi"
      mono={false}
      status="DRAFT"
      context={`${lines.length} sətir`}
      actions={
        <>
          <Button variant="ghost" onClick={() => navigate('/inventory/stock-requests')}>
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

      <Alert tone="info" title="Qaralama yaradılır, anbara göndərilmir">
        Tələb `DRAFT` statusunda yaranır. Anbarın növbəsinə yalnız sənəd ekranındakı «Təsdiqə
        göndər» addımından sonra düşür.
      </Alert>

      <Card title="Tələb başlığı">
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
            label="Haradan (anbar)"
            required
            value={fromLocationId}
            placeholder="Mənbə lokasiya"
            operation="GET /master-data/locations"
            listError={locations.error}
            options={locationOptions}
            onChange={setFromLocationId}
          />
          <RefPicker
            label="Hara (filial)"
            required
            value={toLocationId}
            placeholder="Təyinat lokasiya"
            operation="GET /master-data/locations"
            listError={locations.error}
            error={sameLocation ? 'Mənbə və təyinat eyni ola bilməz.' : undefined}
            options={locationOptions}
            onChange={setToLocationId}
          />
          <TextField
            label="Tələb olunan tarix"
            mono
            type="date"
            value={requiredDate}
            hint="Anbar bu tarixə görə növbə qurur."
            onChange={(e) => setRequiredDate(e.target.value)}
          />
          <div style={{ gridColumn: 'span 2' }}>
            <TextField
              label="Qeyd"
              value={note}
              hint="Anbara görünür və audit jurnalına yazılır."
              onChange={(e) => setNote(e.target.value)}
            />
          </div>
        </MetaGrid>
      </Card>

      <Card
        title="Tələb sətirləri"
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
                    onChange={(value) => update(line.key, { productId: value, uomId: '' })}
                  />
                  <QtyUomInput
                    label="Tələb olunan miqdar"
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
