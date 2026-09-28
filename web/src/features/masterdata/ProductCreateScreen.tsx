import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { Alert, Button, Select, TextField } from '@ds/index';
import { useApiPage } from '@api/hooks';
import {
  createProduct,
  listCategories,
  listSuppliers,
  listUoms,
  type Category,
  type SupplierSummary,
  type Uom,
} from '@api/endpoints';
import { Decimal } from '@core/decimal';
import { Card, DocumentPage, ErrorState, MetaGrid } from '@/components/Page';
import { RefPicker } from '@/components/RefPicker';

/**
 * New product — the card everything else points at.
 *
 * Two fields decide how the product behaves for the rest of its life and cannot be changed later:
 * `sku`, because documents quote it, and `baseUomId`, because every stored quantity is in that unit
 * (ADR-008) — changing it would silently rescale the balance. The form says so where they are.
 *
 * `productType` is not asked for: it is inherited from the category, which is what makes a receipt
 * from an unapproved supplier a 422 for food (TOR §7). Showing it as an editable field here would
 * invite someone to contradict the category.
 */
export function ProductCreateScreen() {
  const navigate = useNavigate();

  const [sku, setSku] = useState('');
  const [name, setName] = useState('');
  const [barcode, setBarcode] = useState('');
  const [categoryId, setCategoryId] = useState('');
  const [brand, setBrand] = useState('');
  const [baseUomId, setBaseUomId] = useState('');
  const [defaultSupplierId, setDefaultSupplierId] = useState('');
  const [minStock, setMinStock] = useState('');
  const [maxStock, setMaxStock] = useState('');
  const [reorderPoint, setReorderPoint] = useState('');
  const [vatRate, setVatRate] = useState('18');
  const [requiresBatch, setRequiresBatch] = useState('false');
  const [requiresExpiry, setRequiresExpiry] = useState('false');
  const [issueStrategy, setIssueStrategy] = useState('FEFO');
  const [shelfLifeDays, setShelfLifeDays] = useState('');

  const categories = useApiPage<Category>(
    ['categories', 'product-create'],
    () => listCategories({}),
    200,
    { retry: false },
  );
  const uoms = useApiPage<Uom>(['uoms', 'product-create'], () => listUoms({}), 200, {
    retry: false,
  });
  const suppliers = useApiPage<SupplierSummary>(
    ['suppliers', 'product-create'],
    () => listSuppliers({ page: 1, size: 200, isActive: true }),
    200,
    { retry: false },
  );

  const decimalError = (value: string): string | undefined => {
    if (value.trim().length === 0) return undefined;
    try {
      return new Decimal(value.replace(',', '.')).lessThan(0)
        ? 'Mənfi ola bilməz.'
        : undefined;
    } catch {
      return 'Onluq ədəd yazın.';
    }
  };

  const errors = {
    sku: sku.trim().length === 0 ? 'SKU məcburidir.' : undefined,
    name: name.trim().length === 0 ? 'Ad məcburidir.' : undefined,
    categoryId: categoryId ? undefined : 'Kateqoriya seçin.',
    baseUomId: baseUomId ? undefined : 'Baza vahidi seçin.',
    vatRate: vatRate.trim().length === 0 ? 'ƏDV dərəcəsi məcburidir.' : decimalError(vatRate),
    minStock: decimalError(minStock),
    maxStock: decimalError(maxStock),
    reorderPoint: decimalError(reorderPoint),
  };
  const blockers = Object.entries(errors).filter(([, v]) => v !== undefined);

  // Expiry tracking without batch tracking has nothing to hang the date on.
  const expiryNeedsBatch = requiresExpiry === 'true' && requiresBatch === 'false';

  const num = (value: string) => value.replace(',', '.');

  const create = useMutation({
    mutationFn: () =>
      createProduct({
        sku: sku.trim(),
        name: name.trim(),
        categoryId: Number(categoryId),
        baseUomId: Number(baseUomId),
        vatRate: num(vatRate),
        requiresBatch: requiresBatch === 'true',
        requiresExpiry: requiresExpiry === 'true',
        issueStrategy: issueStrategy as 'FEFO' | 'FIFO',
        ...(barcode.trim() ? { barcode: barcode.trim() } : {}),
        ...(brand.trim() ? { brand: brand.trim() } : {}),
        ...(defaultSupplierId ? { defaultSupplierId: Number(defaultSupplierId) } : {}),
        ...(minStock ? { minStock: num(minStock) } : {}),
        ...(maxStock ? { maxStock: num(maxStock) } : {}),
        ...(reorderPoint ? { reorderPoint: num(reorderPoint) } : {}),
        ...(shelfLifeDays ? { shelfLifeDays: Number(shelfLifeDays) } : {}),
      }),
    onSuccess: (doc) => navigate(`/master-data/products/${(doc as { id: number }).id}`),
  });

  const category = (categories.data?.items ?? []).find((c) => String(c.id) === categoryId);

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/master-data/products">Sorğu kitabçaları</Link> ·{' '}
          <Link to="/master-data/products">Məhsullar</Link>
        </>
      }
      docNo="Yeni məhsul"
      mono={false}
      status={category ? category.productType : 'DRAFT'}
      context={category ? category.path : undefined}
      actions={
        <>
          <Button variant="ghost" onClick={() => navigate('/master-data/products')}>
            İmtina
          </Button>
          <Button
            variant="primary"
            loading={create.isPending}
            disabled={blockers.length > 0 || expiryNeedsBatch}
            title={
              expiryNeedsBatch
                ? 'Son istifadə tarixi partiya izlənməsi olmadan saxlanmır'
                : blockers.length > 0
                  ? 'Məcburi sahələri doldurun'
                  : undefined
            }
            onClick={() => create.mutate()}
          >
            Məhsul yarat
          </Button>
        </>
      }
    >
      {create.isError ? <ErrorState error={create.error} /> : null}

      <Alert tone="info" title="SKU və baza vahidi sonradan dəyişmir">
        SKU sənədlərdə sitat gətirilir, baza vahidi isə bütün saxlanan miqdarların vahididir — onu
        dəyişmək qalığı səssizcə yenidən ölçüləndirərdi. Məhsul tipi kateqoriyadan miras qalır.
      </Alert>

      {expiryNeedsBatch ? (
        <Alert tone="warning" title="Son istifadə tarixi partiya tələb edir">
          Tarix partiyanın üzərində saxlanır. «Partiya izlənir» bəli olmasa, yazılacaq yer yoxdur.
        </Alert>
      ) : null}

      <Card title="Məhsul kartı">
        <MetaGrid columns={6}>
          <TextField
            label="SKU"
            required
            mono
            value={sku}
            error={sku.length > 0 ? errors.sku : undefined}
            hint="Sonradan dəyişmir."
            onChange={(e) => setSku(e.target.value)}
          />
          <div style={{ gridColumn: 'span 2' }}>
            <TextField
              label="Ad"
              required
              value={name}
              error={name.length > 0 ? errors.name : undefined}
              onChange={(e) => setName(e.target.value)}
            />
          </div>
          <TextField
            label="Barkod"
            mono
            value={barcode}
            onChange={(e) => setBarcode(e.target.value)}
          />
          <TextField label="Marka" value={brand} onChange={(e) => setBrand(e.target.value)} />
          <RefPicker
            label="Kateqoriya"
            required
            value={categoryId}
            placeholder="Kateqoriya seçin"
            operation="GET /masterdata/categories"
            listError={categories.error}
            hint="Məhsul tipi buradan gəlir."
            options={(categories.data?.items ?? []).map((c) => ({
              value: String(c.id),
              label: `${c.path} · ${c.name}`,
            }))}
            onChange={setCategoryId}
          />
          <RefPicker
            label="Baza vahidi"
            required
            value={baseUomId}
            placeholder="Vahid seçin"
            operation="GET /masterdata/uoms"
            listError={uoms.error}
            hint="Bütün qalıqlar bu vahiddə saxlanır. Sonradan dəyişmir."
            options={(uoms.data?.items ?? []).map((u) => ({
              value: String(u.id),
              label: `${u.code} · ${u.name}`,
            }))}
            onChange={setBaseUomId}
          />
          <RefPicker
            label="Default təchizatçı"
            value={defaultSupplierId}
            placeholder="Təchizatçı seçin"
            operation="GET /masterdata/suppliers"
            listError={suppliers.error}
            options={[
              { value: '', label: 'Yoxdur' },
              ...(suppliers.data?.items ?? []).map((s) => ({
                value: String(s.id),
                label: s.name,
              })),
            ]}
            onChange={setDefaultSupplierId}
          />
          <TextField
            label="ƏDV (%)"
            required
            mono
            value={vatRate}
            error={errors.vatRate}
            onChange={(e) => setVatRate(e.target.value)}
          />
        </MetaGrid>
      </Card>

      <Card title="Qalıq hədləri">
        <MetaGrid columns={4}>
          <TextField
            label="Minimum qalıq"
            mono
            value={minStock}
            error={errors.minStock}
            hint="Bu həddin altına düşəndə bildiriş gedir."
            onChange={(e) => setMinStock(e.target.value)}
          />
          <TextField
            label="Maksimum qalıq"
            mono
            value={maxStock}
            error={errors.maxStock}
            onChange={(e) => setMaxStock(e.target.value)}
          />
          <TextField
            label="Sifariş həddi"
            mono
            value={reorderPoint}
            error={errors.reorderPoint}
            hint="Satınalmanın yenidən sifariş üçün baxdığı hədd."
            onChange={(e) => setReorderPoint(e.target.value)}
          />
          <TextField
            label="Rəf ömrü (gün)"
            mono
            value={shelfLifeDays}
            onChange={(e) => setShelfLifeDays(e.target.value.replace(/[^0-9]/g, ''))}
          />
        </MetaGrid>
      </Card>

      <Card title="Partiya və məxaric">
        <MetaGrid columns={4}>
          <Select
            label="Partiya izlənir"
            value={requiresBatch}
            hint="Qəbulda partiya nömrəsi məcburi olur."
            options={[
              { value: 'false', label: 'Xeyr' },
              { value: 'true', label: 'Bəli' },
            ]}
            onChange={(e) => setRequiresBatch(e.target.value)}
          />
          <Select
            label="Son istifadə tarixi izlənir"
            value={requiresExpiry}
            hint="Partiya izlənməsi tələb edir."
            options={[
              { value: 'false', label: 'Xeyr' },
              { value: 'true', label: 'Bəli' },
            ]}
            onChange={(e) => setRequiresExpiry(e.target.value)}
          />
          <Select
            label="Məxaric sırası"
            value={issueStrategy}
            hint="FEFO — ilk bitən, FIFO — ilk gələn."
            options={[
              { value: 'FEFO', label: 'FEFO' },
              { value: 'FIFO', label: 'FIFO' },
            ]}
            onChange={(e) => setIssueStrategy(e.target.value)}
          />
        </MetaGrid>
      </Card>
    </DocumentPage>
  );
}
