import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Badge, Button, DataTable, DocStatusBadge, Select, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listIssues, type IssueSummary } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDate, formatDateTime } from '@core/format';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Issues and transfers — the list behind the artboard's «Məxaric və transfer» entry.
 *
 * A branch issue is a two-step document: dispatch moves the stock into `IN_TRANSIT`, and the
 * receiving location confirms what actually arrived. Both steps are visible in the status column,
 * so a document stuck in transit is obvious from the list (SPEC §12.4).
 */
const ISSUE_TYPE_LABELS: Record<string, string> = {
  BRANCH_ISSUE: 'Filiala məxaric',
  WH_TRANSFER: 'Anbarlararası transfer',
  BRANCH_TRANSFER: 'Filiallararası transfer',
};

export function IssuesScreen() {
  const navigate = useNavigate();
  const { can } = useAuth();
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState('');
  const [issueType, setIssueType] = useState('');

  const query = {
    page,
    size: 50,
    ...(status ? { status: status as IssueSummary['status'] } : {}),
    ...(issueType ? { issueType: issueType as IssueSummary['issueType'] } : {}),
  };
  const issues = useApiPage<IssueSummary>(['issues', query], () => listIssues(query), 50);

  const columns: Column<IssueSummary>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      width: '160px',
      render: (row) => (
        <Link to={`/inventory/issues/${row.id}`}>
          <span className="wms-doc-no">{row.docNo}</span>
        </Link>
      ),
    },
    {
      key: 'docDate',
      header: 'Tarix',
      width: '110px',
      render: (row) => <span className="wms-num wms-small">{formatDate(row.docDate)}</span>,
    },
    {
      key: 'issueType',
      header: 'Tip',
      width: '190px',
      render: (row) => (
        <Badge tone="neutral" variant="outline" title={row.issueType}>
          {ISSUE_TYPE_LABELS[row.issueType] ?? row.issueType}
        </Badge>
      ),
    },
    {
      key: 'route',
      header: 'Marşrut',
      render: (row) => `${row.fromLocation.name} → ${row.toLocation.name}`,
    },
    {
      key: 'requestDocNo',
      header: 'Tələb',
      width: '150px',
      render: (row) =>
        row.requestDocNo ? (
          <span className="wms-doc-no">{row.requestDocNo}</span>
        ) : (
          <span className="wms-muted">tələbsiz</span>
        ),
    },
    { key: 'lineCount', header: 'Sətir', numeric: true, decimals: 0, width: '90px' },
    {
      key: 'dispatchedAt',
      header: 'Yola salınıb',
      width: '150px',
      render: (row) =>
        row.dispatchedAt ? (
          <span className="wms-num wms-small">{formatDateTime(row.dispatchedAt)}</span>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'status',
      header: 'Status',
      width: '150px',
      render: (row) => <DocStatusBadge status={row.status} />,
    },
  ];

  return (
    <Page
      title="Məxaric və transfer"
      subtitle="Filiala məxaric, anbarlararası və filiallararası transfer sənədləri"
      actions={
        can('inv.issue.create') ? (
          <Button variant="primary" onClick={() => navigate('/inventory/issues/new')}>
            Yeni məxaric
          </Button>
        ) : (
          <Button disabled title="`inv.issue.create` icazəniz yoxdur">
            Yeni məxaric
          </Button>
        )
      }
    >
      <Card>
        <div className="wms-toolbar">
          <Select
            label="Status"
            value={status}
            placeholder="Bütün statuslar"
            options={[
              { value: 'DRAFT', label: 'Qaralama' },
              { value: 'DISPATCHED', label: 'Yola salınıb' },
              { value: 'RECEIVED', label: 'Qəbul edilib' },
              { value: 'DISCREPANCY', label: 'Fərqli' },
              { value: 'CANCELLED', label: 'Ləğv edilib' },
            ]}
            onChange={(e) => {
              setStatus(e.target.value);
              setPage(1);
            }}
          />
          <Select
            label="Tip"
            value={issueType}
            placeholder="Bütün tiplər"
            options={Object.entries(ISSUE_TYPE_LABELS).map(([value, label]) => ({ value, label }))}
            onChange={(e) => {
              setIssueType(e.target.value);
              setPage(1);
            }}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      {issues.isLoading ? (
        <LoadingState />
      ) : issues.isError ? (
        <ErrorState error={issues.error} onRetry={() => void issues.refetch()} />
      ) : (
        <Card
          title="Məxaric sənədləri"
          flush
          footer={issues.data ? <Pager page={issues.data} onPageChange={setPage} /> : undefined}
        >
          <DataTable<IssueSummary>
            columns={columns}
            rows={issues.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Məxaric siyahısı"
            empty="Məxaric sənədi yoxdur. «Yeni məxaric» ilə filiala mal göndərin."
          />
        </Card>
      )}
    </Page>
  );
}
