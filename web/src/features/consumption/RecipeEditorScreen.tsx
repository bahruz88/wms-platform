import { useMemo, useState } from 'react';
import { useParams } from 'react-router-dom';
import { Alert, Badge, DataTable, DocStatusBadge, TextField, type Column } from '@ds/index';
import { useApiQuery } from '@api/hooks';
import {
  explodeRecipe,
  getMenuItem,
  getRecipe,
  listRecipeVersions,
  type MenuItemDetail,
  type Recipe,
  type RecipeExplosion,
  type RecipeLine,
  type RecipeSummary,
} from '@api/endpoints';
import { Decimal } from '@core/decimal';
import { formatDate, formatNumber, formatPercent } from '@core/format';
import { DocNo, ErrorState, KeyValue, LoadingState, Page, Section } from '@/components/Page';

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
 * Recipe lines are read-only here: `createRecipeVersion` / `updateRecipe` are POST operations the
 * gateway does not route yet, and an ACTIVE version must never be edited in place — a new version
 * is opened instead.
 */
export function RecipeEditorScreen() {
  const { menuItemId } = useParams();
  const itemId = Number(menuItemId);
  const [portions, setPortions] = useState('10');
  const [selectedRecipeId, setSelectedRecipeId] = useState<number | null>(null);

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
                <DataTable<RecipeLine>
                  columns={lineColumns}
                  rows={recipe.data?.lines ?? []}
                  rowKey={(row) => row.lineNo}
                  label="Resept sətirləri"
                  empty="Bu versiyada sətir yoxdur. İnqrediyent əlavə edin."
                />
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
