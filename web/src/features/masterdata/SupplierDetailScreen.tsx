import { Link, useParams } from 'react-router-dom';
import { Alert, Badge, DataTable, type Column } from '@ds/index';
import { useApiQuery } from '@api/hooks';
import { getSupplier, type Supplier, type SupplierCertificate } from '@api/endpoints';
import { formatDate, formatDateTime } from '@core/format';
import {
  Card,
  DocumentPage,
  ErrorState,
  KeyValue,
  LoadingState,
  Meta,
  MetaGrid,
} from '@/components/Page';

/**
 * A supplier as master data holds it — docs/ux/screen-map.md §5.3.
 *
 * `isApprovedFoodSupplier` is the flag that decides whether a food receipt from this supplier is
 * accepted at all (TOR §7, `422` otherwise), and the certificates below are the evidence behind
 * it: an expired HACCP row is the usual reason a receipt that worked last month now fails, and
 * that is a thing a buyer should be able to see before the lorry arrives rather than after.
 *
 * Read-only: the supplier write operations are in the contract and not routed.
 */
export function SupplierDetailScreen() {
  const { id } = useParams();
  const supplierId = Number(id);

  const supplier = useApiQuery<Supplier>(['supplier', supplierId], () => getSupplier(supplierId));

  if (supplier.isLoading) return <LoadingState />;
  if (supplier.isError)
    return (
      <DocumentPage breadcrumb="Master data · Təchizatçılar" docNo={`#${supplierId}`}>
        <ErrorState error={supplier.error} onRetry={() => void supplier.refetch()} />
      </DocumentPage>
    );

  const doc = supplier.data;
  if (!doc) return null;

  const certificates = doc.certificates ?? [];
  const expired = certificates.filter((c) => c.isExpired);

  const certColumns: Column<SupplierCertificate>[] = [
    {
      key: 'certType',
      header: 'Sertifikat',
      width: '180px',
      render: (row) => <span className="wms-doc-no">{row.certType}</span>,
    },
    {
      key: 'certNumber',
      header: 'Nömrə',
      width: '200px',
      render: (row) =>
        row.certNumber ? (
          <span className="wms-num">{row.certNumber}</span>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'issuedDate',
      header: 'Verilib',
      width: '130px',
      render: (row) => <span className="wms-num wms-small">{formatDate(row.issuedDate)}</span>,
    },
    {
      key: 'expiryDate',
      header: 'Bitir',
      width: '160px',
      render: (row) =>
        row.isExpired ? (
          <Badge tone="danger" dot>
            {formatDate(row.expiryDate)}
          </Badge>
        ) : (
          <span className="wms-num wms-small">{formatDate(row.expiryDate)}</span>
        ),
    },
    {
      key: 'attachmentId',
      header: 'Sənəd',
      render: (row) =>
        row.attachmentId ? (
          <span className="wms-num">#{row.attachmentId}</span>
        ) : (
          <span className="wms-muted">əlavə yoxdur</span>
        ),
    },
  ];

  return (
    <DocumentPage
      breadcrumb={<Link to="/master-data/suppliers">Master data · Təchizatçılar</Link>}
      docNo={doc.code}
      badges={
        <>
          {doc.isActive ? <Badge tone="success">Aktiv</Badge> : <Badge tone="neutral">Bağlı</Badge>}
          {doc.isApprovedFoodSupplier ? (
            <Badge tone="success">Qida təsdiqlənib</Badge>
          ) : (
            <Badge tone="warning" dot>
              Qida təsdiqi yoxdur
            </Badge>
          )}
        </>
      }
      context={doc.name}
    >
      {!doc.isApprovedFoodSupplier ? (
        <Alert tone="warning" title="Bu təchizatçıdan qida məhsulu qəbul edilmir">
          <span className="wms-num">isApprovedFoodSupplier = false</span> — `FOOD` kateqoriyalı
          sətri olan qəbul <span className="wms-num">422</span> ilə rədd edilir (TOR §7).
        </Alert>
      ) : null}

      {expired.length > 0 ? (
        <Alert tone="danger" title="Vaxtı keçmiş sertifikat" code="CERTIFICATE_EXPIRED">
          <span className="wms-num">{expired.length}</span> sertifikatın müddəti bitib:{' '}
          <span className="wms-num">{expired.map((c) => c.certType).join(', ')}</span>. Qida təsdiqi
          bu sənədlərə əsaslanır.
        </Alert>
      ) : null}

      <Card title="Təchizatçı">
        <MetaGrid columns={6}>
          <Meta label="Kod" value={<span className="wms-doc-no">{doc.code}</span>} />
          <Meta label="Ad" value={doc.name} />
          <Meta
            label="VÖEN"
            value={
              doc.taxId ? (
                <span className="wms-num">{doc.taxId}</span>
              ) : (
                <span className="wms-muted">—</span>
              )
            }
          />
          <Meta label="Valyuta" value={<span className="wms-num">{doc.currency}</span>} />
          <Meta
            label="Əlaqələndirici"
            value={doc.contactPerson ?? <span className="wms-muted">—</span>}
            sub={doc.phone ?? undefined}
          />
          <Meta label="E-poçt" value={doc.email ?? <span className="wms-muted">—</span>} />
        </MetaGrid>
      </Card>

      <div className="wms-grid wms-grid--2">
        <Card title="Kommersiya şərtləri">
          <KeyValue
            items={[
              ['Ödəniş şərtləri', doc.paymentTerms ?? <span className="wms-muted">—</span>],
              ['Çatdırılma şərtləri', doc.deliveryTerms ?? <span className="wms-muted">—</span>],
              ['Incoterms', doc.incoterms ?? <span className="wms-muted">—</span>],
              ['Bank rekvizitləri', doc.bankDetails ?? <span className="wms-muted">—</span>],
            ]}
          />
        </Card>
        <Card title="Ünvan və audit">
          <KeyValue
            items={[
              ['Ünvan', doc.address ?? <span className="wms-muted">—</span>],
              [
                'Yaradılıb',
                <span className="wms-num wms-small" key="created">
                  {formatDateTime(doc.audit.createdAt)}
                </span>,
              ],
              [
                'Son dəyişiklik',
                <span className="wms-num wms-small" key="updated">
                  {formatDateTime(doc.audit.updatedAt ?? doc.audit.createdAt)} · v
                  {doc.audit.rowVersion}
                </span>,
              ],
            ]}
          />
        </Card>
      </div>

      <Card
        title="Sertifikatlar"
        subtitle={`${certificates.length} sənəd · ${expired.length} vaxtı keçib`}
        flush
      >
        <DataTable<SupplierCertificate>
          columns={certColumns}
          rows={certificates}
          rowKey={(row) => row.id}
          label="Təchizatçı sertifikatları"
          empty="Sertifikat yazılmayıb. Qida təsdiqi üçün ən azı bir etibarlı sənəd tələb olunur (TOR §7)."
        />
      </Card>
    </DocumentPage>
  );
}
