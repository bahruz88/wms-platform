import { Link, useParams } from 'react-router-dom';
import { Badge, Button, LedgerTable, type LedgerLine } from '@ds/index';
import { useMemo } from 'react';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  getMovementGroup,
  listLocations,
  listProducts,
  type Location,
  type MovementGroup,
  type ProductSummary,
} from '@api/endpoints';
import { indexById, normalizeMovement } from '@api/adapters';
import { useAuth } from '@auth/index';
import { formatDate, formatDateTime } from '@core/format';
import { Card, DocumentPage, ErrorState, LoadingState, Meta, MetaGrid } from '@/components/Page';

/**
 * One movement group, rendered with `LedgerTable` — docs/ux/screen-map.md §3.12.
 *
 * The group header (document number, type, who posted it, when) sits above the table because the
 * component only renders lines. The zero-sum check row is always on: it is the interface twin of
 * the nightly `DoubleEntryCheck` job.
 */
export function MovementGroupScreen() {
  const { id } = useParams();
  const groupId = Number(id);
  const { can } = useAuth();

  const products = useApiPage<ProductSummary>(
    ['products', 'group'],
    () => listProducts({ page: 1, size: 200 }),
    200,
  );
  const locations = useApiPage<Location>(['locations', 'group'], () => listLocations({}), 200);

  const group = useApiQuery<MovementGroup>(['movement-group', groupId], () =>
    getMovementGroup(groupId),
  );

  const normalizedLines = useMemo(() => {
    const productIndex = indexById(products.data?.items ?? []);
    const locationIndex = indexById(locations.data?.items ?? []);
    return (group.data?.lines ?? []).map((line) =>
      normalizeMovement(line, productIndex, locationIndex),
    );
  }, [group.data, products.data, locations.data]);

  if (group.isLoading) return <LoadingState />;
  if (group.isError)
    return (
      <DocumentPage breadcrumb="Anbar · Ledger" docNo={`#${groupId}`}>
        <ErrorState error={group.error} onRetry={() => void group.refetch()} />
      </DocumentPage>
    );
  const doc = group.data;
  if (!doc) return null;

  const lines: LedgerLine[] = normalizedLines.map((line) => ({
    lineNo: line.lineNo,
    product: line.product.name,
    sku: line.product.sku,
    batchNo: line.batch?.batchNo,
    location: line.location.name,
    locationType: line.location.isVirtual ? line.location.code : undefined,
    qtyBase: line.qtyBase,
    uom: line.product.baseUomCode,
    unitCost: line.unitCost ?? undefined,
  }));

  return (
    <DocumentPage
      breadcrumb={
        <>
          <Link to="/inventory/balances">Anbar</Link> ·{' '}
          <Link to="/inventory/movements">Ledger</Link>
        </>
      }
      docNo={doc.docNo}
      badges={
        <Badge tone="neutral" variant="outline" title="movement group doc_type">
          {doc.docType}
        </Badge>
      }
      context={`${lines.length} sətir · ikili yazılış`}
      actions={
        <Button variant="ghost" onClick={() => window.print()}>
          Çap et
        </Button>
      }
    >
      <Card title="Qrup başlığı">
        <MetaGrid columns={4}>
          <Meta
            label="Sənəd tarixi"
            value={<span className="wms-num">{formatDate(doc.docDate)}</span>}
          />
          <Meta
            label="Post vaxtı"
            value={<span className="wms-num">{formatDateTime(doc.postedAt)}</span>}
            sub={`post edən #${doc.postedBy}`}
          />
          <Meta
            label="Mənbə sənəd"
            value={doc.sourceDocType ? `${doc.sourceDocType} #${doc.sourceDocId}` : '—'}
          />
          <Meta
            label="Storno"
            value={
              doc.reversesGroupId
                ? `#${doc.reversesGroupId} qrupunu storno edir`
                : doc.reversedByGroupId
                  ? `#${doc.reversedByGroupId} ilə storno edilib`
                  : '—'
            }
            sub={doc.note ?? undefined}
          />
        </MetaGrid>
      </Card>

      <Card
        title="Sətirlər"
        subtitle="Qrupun cəmi sıfır olmalıdır — bu, gecə işləyən DoubleEntryCheck-in interfeys tərəfidir"
      >
        {/* showCost only with the permission — the component never decides that itself. */}
        <LedgerTable
          lines={lines}
          decimals={4}
          showCost={can('master.product.view_cost')}
          showBalanceCheck
          label={`${doc.docNo} hərəkət sətirləri`}
        />
      </Card>
    </DocumentPage>
  );
}
