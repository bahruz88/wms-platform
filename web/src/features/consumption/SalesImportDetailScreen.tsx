import { Link, useParams } from 'react-router-dom';
import { Alert, Badge, DataTable, DocStatusBadge, type Column } from '@ds/index';
import { useApiQuery } from '@api/hooks';
import { getSalesImport, type SalesImportDetail, type SalesLine } from '@api/endpoints';
import { formatDate, formatDateTime } from '@core/format';
import { DocNo, ErrorState, KeyValue, LoadingState, Page, Section } from '@/components/Page';

/**
 * One sales import with its lines. Unmapped POS codes are shown first-class: `isMapped = false`
 * means the code matched no menu item, and `hasRecipe = false` means it matched but the item has
 * no active recipe. Both produce no consumption, and both need a different fix.
 */
export function SalesImportDetailScreen() {
  const { id } = useParams();
  const importId = Number(id);

  const salesImport = useApiQuery<SalesImportDetail>(['sales-import', importId], () =>
    getSalesImport(importId),
  );

  if (salesImport.isLoading) return <LoadingState />;
  if (salesImport.isError)
    return <ErrorState error={salesImport.error} onRetry={() => void salesImport.refetch()} />;
  const doc = salesImport.data;
  if (!doc) return null;

  const unmapped = (doc.lines ?? []).filter((l) => !l.isMapped);
  const mappedWithoutRecipe = (doc.lines ?? []).filter((l) => l.isMapped && l.hasRecipe === false);

  const columns: Column<SalesLine>[] = [
    {
      key: 'rawPosCode',
      header: 'POS kodu',
      render: (row) => <span className="wms-doc-no">{row.rawPosCode ?? '—'}</span>,
    },
    {
      key: 'menuItemName',
      header: 'Menyu maddəsi',
      render: (row) =>
        row.menuItemName ? (
          <Link to={`/consumption/recipes/${row.menuItemId}`}>{row.menuItemName}</Link>
        ) : (
          <span className="wms-muted">Tanınmayıb</span>
        ),
    },
    { key: 'qtySold', header: 'Satılıb', numeric: true, decimals: 4 },
    { key: 'grossAmount', header: 'Brüt məbləğ', numeric: true, decimals: 2 },
    {
      key: 'status',
      header: 'Vəziyyət',
      render: (row) =>
        !row.isMapped ? (
          <Badge tone="danger">POS kodu bağlanmayıb</Badge>
        ) : row.hasRecipe === false ? (
          <Badge tone="warning">Resept yoxdur</Badge>
        ) : (
          <Badge tone="success">İstehlaka düşür</Badge>
        ),
    },
  ];

  return (
    <Page
      title={<DocNo value={`SI-${String(doc.id).padStart(5, '0')}`} />}
      subtitle="Satış importu"
      actions={<DocStatusBadge status={doc.status} />}
    >
      {unmapped.length > 0 ? (
        <Alert
          tone="warning"
          title={`${unmapped.length} POS kodu heç bir menyu maddəsinə bağlı deyil`}
        >
          Bu sətirlərdən istehlak yaranmır. Menyu maddəsinin{' '}
          <span className="wms-num">posCode</span> sahəsini doldurun, sonra importu yenidən
          göndərin.
        </Alert>
      ) : null}
      {mappedWithoutRecipe.length > 0 ? (
        <Alert tone="warning" title={`${mappedWithoutRecipe.length} maddənin aktiv resepti yoxdur`}>
          Maddə tanınır, lakin resept olmadan nəzəri istehlak hesablana bilmir.
        </Alert>
      ) : null}

      <Section title="Başlıq">
        <div className="wms-card">
          <KeyValue
            items={[
              ['İş günü', formatDate(doc.businessDate)],
              ['Lokasiya', doc.locationName ?? `#${doc.locationId}`],
              ['Mənbə', doc.source],
              ['Xarici istinad', doc.externalRef ?? '—'],
              [
                'Sətir sayı',
                <span key="l" className="wms-num">
                  {doc.lineCount}
                </span>,
              ],
              [
                'Uyğunsuz sətir',
                <span key="u" className="wms-num">
                  {doc.unmappedCount ?? 0}
                </span>,
              ],
              ['İmport vaxtı', formatDateTime(doc.importedAt)],
              [
                'İstehlak sənədi',
                doc.consumptionRunId ? (
                  <Link key="r" to={`/consumption/runs/${doc.consumptionRunId}`}>
                    {`#${doc.consumptionRunId}`}
                  </Link>
                ) : (
                  'Yaradılmayıb'
                ),
              ],
              [
                'rowVersion',
                <span key="rv" className="wms-num">
                  {doc.rowVersion}
                </span>,
              ],
            ]}
          />
        </div>
      </Section>

      <Section title="Satış sətirləri">
        <DataTable<SalesLine>
          columns={columns}
          rows={doc.lines ?? []}
          rowKey={(row, i) => row.id ?? i}
          label="Satış sətirləri"
          empty="Bu importda sətir yoxdur. CSV faylını yoxlayın."
        />
      </Section>
    </Page>
  );
}
