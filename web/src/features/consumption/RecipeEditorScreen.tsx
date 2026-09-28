import { useEffect, useMemo, useState } from 'react';
import { useParams } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Alert,
  Badge,
  Button,
  DataTable,
  DocStatusBadge,
  QtyUomInput,
  TextField,
  type Column,
} from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  activateRecipe,
  createRecipeVersion,
  explodeRecipe,
  getMenuItem,
  getRecipe,
  listProducts,
  listRecipeVersions,
  updateRecipe,
  type ProductSummary,
  type MenuItemDetail,
  type Recipe,
  type RecipeExplosion,
  type RecipeLine,
  type RecipeSummary,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { useProductUoms } from '@api/productUoms';
import { Decimal } from '@core/decimal';
import { formatDate, formatNumber, formatPercent } from '@core/format';
import { Card, DocNo, ErrorState, KeyValue, LoadingState, Page, Section } from '@/components/Page';
import { RefPicker } from '@/components/RefPicker';

type ExplosionLine = RecipeExplosion['lines'][number];

/**
 * Recipe editor with a live BOM explosion preview.
 *
 * The portion count is a form field; every change re-runs `explodeRecipe`, which calculates the
 * ingredient requirement without touching stock:
 *
 *     required_base = portions × qtyPerPortion × conversionToBase ÷ (yieldPct ÷ 100)
 *
 * Sub-recipes are expanded recursively and each resulting line says which sub-recipe it came
 * through — the `depth` column makes a two-level explosion readable.
 *
 * An ACTIVE version is never edited in place. A change opens a new DRAFT (optionally copied from
 * the current one), the draft's lines are edited here, and activating it closes the previous version
 * at `validFrom − 1 day`. That seam is why `validFrom` cannot fall before a posted consumption run:
 * the run was priced by the recipe that was active on its date, and moving the seam would rewrite
 * history the ledger already recorded.
 */

interface DraftLine {
  key: string;
  dirty: boolean;
  productId: string;
  qtyPerPortion: string;
  uomId: string;
  yieldPct: string;
  note: string;
}

const emptyLine = (): DraftLine => ({
  key: crypto.randomUUID(),
  dirty: false,
  productId: '',
  qtyPerPortion: '',
  uomId: '',
  yieldPct: '100',
  note: '',
});

const today = () => new Date().toISOString().slice(0, 10);
export function RecipeEditorScreen() {
  const { menuItemId } = useParams();
  const itemId = Number(menuItemId);
  const { can } = useAuth();
  const queryClient = useQueryClient();
  const [portions, setPortions] = useState('10');
  const [selectedRecipeId, setSelectedRecipeId] = useState<number | null>(null);
  const [lines, setLines] = useState<DraftLine[]>([]);
  const [yieldPortions, setYieldPortions] = useState('1');
  const [note, setNote] = useState('');
  const [validFrom, setValidFrom] = useState(today);

  const menuItem = useApiQuery<MenuItemDetail>(['menu-item', itemId], () => getMenuItem(itemId));
  const versions = useApiQuery<RecipeSummary[]>(['recipe-versions', itemId], async () => {
    const result = await listRecipeVersions(itemId);
    return Array.isArray(result) ? result : [];
  });

  const activeId =
    selectedRecipeId ??
    menuItem.data?.activeRecipeId ??
    versions.data?.find((v) => v.status === 'ACTIVE')?.id ??
    versions.data?.[0]?.id ??
    null;

  const recipe = useApiQuery<Recipe>(['recipe', activeId], () => getRecipe(activeId as number), {
    enabled: activeId !== null,
  });

  // A portion count that is not a valid decimal must not be sent to the server.
  const portionsValid = useMemo(() => {
    if (!portions.trim()) return false;
    try {
      const d = new Decimal(portions);
      return d.isFinite() && d.greaterThan(0);
    } catch {
      return false;
    }
  }, [portions]);

  const manage = can('cons.recipe.manage');
  const isDraft = recipe.data?.status === 'DRAFT';

  const products = useApiPage<ProductSummary>(
    ['products', 'recipe'],
    () => listProducts({ page: 1, size: 200, isActive: true, productType: 'FOOD' }),
    200,
    { retry: false },
  );

  // The draft's lines are seeded from the server each time a different version is selected, so the
  // editor always starts from what is stored rather than from the previous version's leftovers.
  useEffect(() => {
    const doc = recipe.data;
    if (!doc) return;
    setYieldPortions(String(doc.yieldPortions ?? '1'));
    setNote(doc.note ?? '');
    setLines(
      (doc.lines ?? [])
        .filter((l) => l.componentType === 'FOOD_PRODUCT')
        .map((l) => ({
          key: crypto.randomUUID(),
          dirty: false,
          productId: String(l.productId ?? ''),
          qtyPerPortion: String(l.qtyPerPortion),
          uomId: String(l.uomId),
          yieldPct: String(l.yieldPct ?? '100'),
          note: l.note ?? '',
        })),
    );
  }, [recipe.data]);

  const productUoms = useProductUoms(
    lines.map((l) => Number(l.productId)).filter((id) => Number.isFinite(id) && id > 0),
    'issue',
  );

  const refresh = () => {
    void queryClient.invalidateQueries({ queryKey: ['recipe'] });
    void queryClient.invalidateQueries({ queryKey: ['recipe-versions', itemId] });
    void queryClient.invalidateQueries({ queryKey: ['menu-item', itemId] });
  };

  const update = (key: string, patch: Partial<DraftLine>) =>
    setLines((prev) => prev.map((l) => (l.key === key ? { ...l, ...patch, dirty: true } : l)));

  const lineErrors = (line: DraftLine): Record<string, string> => {
    const errors: Record<string, string> = {};
    if (!line.productId) errors.productId = 'Məhsul seçin.';
    if (!line.qtyPerPortion) errors.qtyPerPortion = 'Porsiyaya düşən miqdarı yazın.';
    else {
      try {
        if (new Decimal(line.qtyPerPortion).lessThanOrEqualTo(0))
          errors.qtyPerPortion = 'Sıfırdan böyük olmalıdır.';
      } catch {
        errors.qtyPerPortion = 'Onluq ədəd yazın.';
      }
    }
    try {
      const y = new Decimal(line.yieldPct || '100');
      if (y.lessThanOrEqualTo(0) || y.greaterThan(100)) errors.yieldPct = '0 ilə 100 arasında.';
    } catch {
      errors.yieldPct = 'Onluq ədəd yazın.';
    }
    return errors;
  };

  const linesValid = lines.length > 0 && lines.every((l) => Object.keys(lineErrors(l)).length === 0);

  const uomOf = (line: DraftLine): number => {
    if (line.uomId) return Number(line.uomId);
    const p = (products.data?.items ?? []).find((x) => String(x.id) === line.productId);
    return productUoms.uomsFor(p).defaultUomId ?? p?.baseUomId ?? 0;
  };

  const newVersion = useMutation({
    mutationFn: () =>
      createRecipeVersion(itemId, {
        validFrom,
        ...(activeId ? { copyFromRecipeId: activeId } : {}),
      }),
    onSuccess: (doc) => {
      setSelectedRecipeId((doc as { id: number }).id);
      refresh();
    },
  });

  const saveDraft = useMutation({
    mutationFn: () =>
      updateRecipe(activeId as number, {
        rowVersion: recipe.data?.rowVersion ?? 1,
        yieldPortions,
        ...(note.trim() ? { note: note.trim() } : {}),
        lines: lines.map((l, index) => ({
          lineNo: index + 1,
          componentType: 'FOOD_PRODUCT' as const,
          productId: Number(l.productId),
          qtyPerPortion: l.qtyPerPortion,
          uomId: uomOf(l),
          yieldPct: l.yieldPct || '100',
          ...(l.note.trim() ? { note: l.note.trim() } : {}),
        })),
      }),
    onSuccess: refresh,
  });

  const activate = useMutation({
    mutationFn: () => activateRecipe(activeId as number, recipe.data?.rowVersion ?? 1, validFrom),
    onSuccess: refresh,
  });

  const explosion = useApiQuery<RecipeExplosion>(
    ['recipe-explosion', activeId, portions],
    () => explodeRecipe(activeId as number, { portions }),
    { enabled: activeId !== null && portionsValid },
  );

  if (menuItem.isLoading) return <LoadingState />;
  if (menuItem.isError)
    return <ErrorState error={menuItem.error} onRetry={() => void menuItem.refetch()} />;
  const item = menuItem.data;
  if (!item) return null;

  const lineColumns: Column<RecipeLine>[] = [
    { key: 'lineNo', header: '№', numeric: true, decimals: 0, width: '48px' },
    {
      key: 'component',
      header: 'Komponent',
      render: (row) =>
        row.componentType === 'SUB_RECIPE' ? (
          <span className="wms-row">
            <Badge tone="accent">Alt-resept</Badge>
            <span>{row.subMenuItemName ?? `#${row.subMenuItemId}`}</span>
          </span>
        ) : (
          <span className="wms-stack" style={{ gap: 0 }}>
            <span>{row.productName ?? `#${row.productId}`}</span>
            <span className="wms-doc-no wms-muted">{row.productSku}</span>
          </span>
        ),
    },
    { key: 'qtyPerPortion', header: 'Porsiyaya', numeric: true, decimals: 4 },
    {
      key: 'uomCode',
      header: 'Vahid',
      width: '80px',
      render: (row) => row.uomCode || `#${row.uomId}`,
    },
    {
      key: 'yieldPct',
      header: 'Çıxım',
      numeric: true,
      decimals: 2,
      render: (row) => formatPercent(row.yieldPct, 2),
    },
    {
      key: 'attachRatePct',
      header: 'Tətbiq faizi',
      numeric: true,
      decimals: 2,
      render: (row) => formatPercent(row.attachRatePct, 2),
    },
    {
      key: 'isOptional',
      header: 'Seçimli',
      render: (row) =>
        row.isOptional ? (
          <Badge tone="neutral">Seçimli</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    { key: 'note', header: 'Qeyd', render: (row) => row.note ?? '—' },
  ];

  const explosionColumns: Column<ExplosionLine>[] = [
    {
      key: 'depth',
      header: 'Dərinlik',
      numeric: true,
      decimals: 0,
      width: '90px',
      render: (row) =>
        (row.depth ?? 0) === 0 ? (
          <Badge tone="neutral">Kök</Badge>
        ) : (
          <Badge tone="accent">{`${row.depth}. səviyyə`}</Badge>
        ),
    },
    {
      key: 'productSku',
      header: 'SKU',
      render: (row) => <span className="wms-doc-no">{row.productSku}</span>,
    },
    { key: 'productName', header: 'Məhsul' },
    { key: 'requiredQtyBase', header: 'Tələb (base)', numeric: true, decimals: 4 },
    { key: 'baseUomCode', header: 'Vahid', width: '80px' },
    {
      key: 'viaSubRecipe',
      header: 'Alt-resept vasitəsilə',
      render: (row) =>
        row.viaSubRecipe ? (
          <Badge tone="accent">{row.viaSubRecipe}</Badge>
        ) : (
          <span className="wms-muted">Birbaşa</span>
        ),
    },
  ];

  return (
    <Page
      title={item.name}
      subtitle="Resept redaktoru — BOM partlaması canlı önizləmə ilə"
      actions={<DocNo value={item.code} />}
    >
      <Section title="Menyu maddəsi">
        <div className="wms-card">
          <KeyValue
            items={[
              ['Kod', <DocNo key="c" value={item.code} />],
              ['POS kodu', item.posCode ? <DocNo key="p" value={item.posCode} /> : 'Bağlanmayıb'],
              ['Kateqoriya', item.category ?? '—'],
              ['Növ', item.isSubRecipe ? 'Yarımfabrikat' : 'Satılan maddə'],
              [
                'Aktiv resept',
                item.activeRecipeId ? `Versiya #${item.activeRecipeId}` : 'Resept yoxdur',
              ],
            ]}
          />
        </div>
      </Section>

      <Section title="Resept versiyaları">
        {manage ? (
          <Card>
            <div className="wms-toolbar">
              <TextField
                label="Qüvvəyə minmə tarixi"
                mono
                type="date"
                value={validFrom}
                hint="Yeni versiya bu tarixdən qüvvədədir; köhnəsi bir gün əvvəl bağlanır."
                onChange={(e) => setValidFrom(e.target.value)}
              />
              <div className="wms-toolbar__spacer" />
              <div className="wms-row">
                <Button
                  loading={newVersion.isPending}
                  onClick={() => newVersion.mutate()}
                  title={
                    activeId
                      ? 'Cari versiyanın tərkibi köçürülür'
                      : 'Boş qaralama versiya yaradılır'
                  }
                >
                  {activeId ? 'Yeni versiya (köçürərək)' : 'Yeni versiya'}
                </Button>
                {isDraft ? (
                  <Button
                    variant="primary"
                    loading={activate.isPending}
                    disabled={(recipe.data?.lines ?? []).length === 0}
                    title={
                      (recipe.data?.lines ?? []).length === 0
                        ? 'Boş resept aktivləşdirilmir — əvvəlcə tərkibi yadda saxlayın'
                        : undefined
                    }
                    onClick={() => activate.mutate()}
                  >
                    Aktivləşdir
                  </Button>
                ) : null}
              </div>
            </div>
            {newVersion.isError ? <ErrorState error={newVersion.error} /> : null}
            {activate.isError ? <ErrorState error={activate.error} /> : null}
          </Card>
        ) : null}

        {versions.isError ? (
          <ErrorState error={versions.error} />
        ) : (
          <div className="wms-row">
            {(versions.data ?? []).map((version) => (
              <button
                key={version.id}
                type="button"
                className={
                  version.id === activeId
                    ? 'wms-btn wms-btn--primary wms-btn--sm'
                    : 'wms-btn wms-btn--secondary wms-btn--sm'
                }
                onClick={() => setSelectedRecipeId(version.id)}
              >
                {`Versiya ${version.versionNo}`} · <DocStatusBadge status={version.status} /> ·{' '}
                {formatDate(version.validFrom)}
              </button>
            ))}
            {(versions.data ?? []).length === 0 ? (
              <Alert tone="warning" title="Bu maddənin resepti yoxdur">
                Resept olmadan satış sətri <span className="wms-num">unmapped</span> qalır və
                istehlak yaranmır.
              </Alert>
            ) : null}
          </div>
        )}
      </Section>

      {activeId !== null ? (
        <>
          <Section title="Resept sətirləri">
            {recipe.isLoading ? (
              <LoadingState />
            ) : recipe.isError ? (
              <ErrorState error={recipe.error} onRetry={() => void recipe.refetch()} />
            ) : (
              <>
                {recipe.data?.status === 'ACTIVE' ? (
                  <Alert tone="info" title="Aktiv versiya yerində redaktə olunmur">
                    Dəyişiklik üçün yeni versiya açılır; köhnə versiya `validTo` ilə bağlanır. Bu,
                    `factorToBase` qaydası ilə eyni məntiqdir (screen-map §5.3).
                  </Alert>
                ) : null}

                {isDraft && manage ? (
                  <Card
                    title="Qaralama tərkibi"
                    actions={
                      <div className="wms-row">
                        <Button
                          size="sm"
                          onClick={() => setLines((prev) => [...prev, emptyLine()])}
                        >
                          Sətir əlavə et
                        </Button>
                        <Button
                          size="sm"
                          variant="primary"
                          loading={saveDraft.isPending}
                          disabled={!linesValid}
                          title={!linesValid ? 'Sətirlərdə səhv var və ya sətir yoxdur' : undefined}
                          onClick={() => saveDraft.mutate()}
                        >
                          Tərkibi yadda saxla
                        </Button>
                      </div>
                    }
                  >
                    {saveDraft.isError ? <ErrorState error={saveDraft.error} /> : null}

                    <div className="wms-toolbar">
                      <TextField
                        label="Çıxım porsiyası"
                        mono
                        align="right"
                        value={yieldPortions}
                        hint="Bu resept bir dəfə hazırlandıqda neçə porsiya verir."
                        onChange={(e) => setYieldPortions(e.target.value)}
                      />
                      <TextField
                        label="Qeyd"
                        value={note}
                        onChange={(e) => setNote(e.target.value)}
                      />
                      <div className="wms-toolbar__spacer" />
                    </div>

                    <div className="wms-stack">
                      {lines.map((line, index) => {
                        const errors = line.dirty ? lineErrors(line) : {};
                        const product = (products.data?.items ?? []).find(
                          (p) => String(p.id) === line.productId,
                        );
                        const uomSet = productUoms.uomsFor(product);
                        return (
                          <Card key={line.key}>
                            <div className="wms-toolbar">
                              <RefPicker
                                label={`Sətir ${index + 1} · inqrediyent`}
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
                                onChange={(value) =>
                                  update(line.key, { productId: value, uomId: '' })
                                }
                              />
                              <QtyUomInput
                                label="Porsiyaya"
                                required
                                qty={line.qtyPerPortion}
                                uomId={line.uomId || String(uomSet.defaultUomId ?? '')}
                                error={errors.qtyPerPortion}
                                baseUomCode={product?.baseUomCode}
                                decimals={4}
                                uoms={
                                  uomSet.options.length > 0
                                    ? uomSet.options
                                    : [{ id: '', code: '—', factorToBase: '1' }]
                                }
                                onQtyChange={(value) => update(line.key, { qtyPerPortion: value })}
                                onUomChange={(value) => update(line.key, { uomId: value })}
                              />
                              <TextField
                                label="Çıxım (%)"
                                mono
                                align="right"
                                value={line.yieldPct}
                                error={errors.yieldPct}
                                hint="Kahının 8 %-i kəsilirsə 92."
                                onChange={(e) => update(line.key, { yieldPct: e.target.value })}
                              />
                              <TextField
                                label="Qeyd"
                                value={line.note}
                                onChange={(e) => update(line.key, { note: e.target.value })}
                              />
                              <Button
                                size="sm"
                                variant="ghost"
                                onClick={() =>
                                  setLines((prev) => prev.filter((l) => l.key !== line.key))
                                }
                              >
                                Sil
                              </Button>
                            </div>
                          </Card>
                        );
                      })}
                      {lines.length === 0 ? (
                        <Alert tone="warning" title="Tərkib boşdur">
                          Boş resept aktivləşdirilmir (422 RECIPE_EMPTY). İnqrediyent əlavə edin.
                        </Alert>
                      ) : null}
                    </div>
                  </Card>
                ) : (
                  <DataTable<RecipeLine>
                    columns={lineColumns}
                    rows={recipe.data?.lines ?? []}
                    rowKey={(row) => row.lineNo}
                    label="Resept sətirləri"
                    empty="Bu versiyada sətir yoxdur. İnqrediyent əlavə edin."
                  />
                )}
              </>
            )}
          </Section>

          <Section title="BOM partlaması — canlı önizləmə">
            <div className="wms-toolbar">
              <TextField
                label="Porsiya sayı"
                mono
                align="right"
                value={portions}
                hint="Dəyişiklik dərhal serverdə hesablanır; stokdan heç nə çıxmır."
                error={portionsValid ? undefined : 'Müsbət onluq ədəd yazın.'}
                onChange={(e) => setPortions(e.target.value)}
              />
              <div className="wms-toolbar__spacer" />
              {explosion.data ? (
                <div className="wms-row">
                  <Badge tone="neutral">{`Maksimum dərinlik: ${explosion.data.maxDepth ?? 0}`}</Badge>
                  <Badge tone="accent">{`Porsiya: ${formatNumber(explosion.data.portions, 4)}`}</Badge>
                </div>
              ) : null}
            </div>

            {!portionsValid ? (
              <Alert tone="warning" title="Porsiya sayı düzgün deyil">
                Partlama hesablanmır — müsbət onluq ədəd yazın.
              </Alert>
            ) : explosion.isLoading ? (
              <LoadingState label="Partlama hesablanır…" />
            ) : explosion.isError ? (
              <ErrorState error={explosion.error} onRetry={() => void explosion.refetch()} />
            ) : (
              <DataTable<ExplosionLine>
                columns={explosionColumns}
                rows={explosion.data?.lines ?? []}
                rowKey={(row, i) => `${row.productId}-${i}`}
                label="BOM partlaması"
                empty="Partlama nəticəsi boşdur. Reseptə inqrediyent əlavə edin."
              />
            )}
          </Section>
        </>
      ) : null}
    </Page>
  );
}
