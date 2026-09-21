import { Alert, Badge, DataTable, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listReasonCodes, type ReasonCode } from '@api/endpoints';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';

/**
 * Reason codes — docs/ux/screen-map.md §5.3. `requiresPhoto` and `requiresApproval` change the
 * behaviour of every document that uses the code, which is why they are shown as badges rather
 * than as plain booleans.
 */
export function ReasonCodesScreen() {
  const reasons = useApiPage<ReasonCode>(['reason-codes'], () => listReasonCodes({}), 200);

  const columns: Column<ReasonCode>[] = [
    {
      key: 'code',
      header: 'Kod',
      width: '140px',
      render: (row) => <span className="wms-doc-no">{row.code}</span>,
    },
    { key: 'name', header: 'Ad' },
    {
      key: 'reasonGroup',
      header: 'Qrup',
      render: (row) => <Badge tone="neutral">{row.reasonGroup}</Badge>,
    },
    {
      key: 'requiresPhoto',
      header: 'Foto',
      render: (row) =>
        row.requiresPhoto ? (
          <Badge tone="warning">Məcburi</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'requiresApproval',
      header: 'Təsdiq',
      render: (row) =>
        row.requiresApproval ? (
          <Badge tone="warning">Tələb edir</Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'isActive',
      header: 'Vəziyyət',
      render: (row) =>
        row.isActive ? <Badge tone="success">Aktiv</Badge> : <Badge tone="neutral">Bağlı</Badge>,
    },
  ];

  return (
    <Page title="Səbəb kodları" subtitle="Tullantı, sayım fərqi, storno və transfer səbəbləri">
      <Alert tone="info" title="Səbəb kodu qrupla filtrlənir">
        Tullantı sənədində yalnız <span className="wms-num">WASTE</span> qrupu, nümunədə{' '}
        <span className="wms-num">SAMPLE</span> qrupu göstərilir — `reasonGroup` sonradan
        dəyişdirilmir.
      </Alert>
      <Section>
        {reasons.isLoading ? (
          <LoadingState />
        ) : reasons.isError ? (
          <ErrorState error={reasons.error} onRetry={() => void reasons.refetch()} />
        ) : (
          <DataTable<ReasonCode>
            columns={columns}
            rows={reasons.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Səbəb kodları"
            empty="Səbəb kodu yoxdur. Tullantı və sayım üçün ən azı bir kod lazımdır."
          />
        )}
      </Section>
    </Page>
  );
}
