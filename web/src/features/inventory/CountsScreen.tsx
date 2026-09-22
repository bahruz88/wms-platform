import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import {
  Alert,
  Badge,
  Button,
  DataTable,
  Dialog,
  DocStatusBadge,
  Select,
  TextField,
  type Column,
} from '@ds/index';
import { useApiPage } from '@api/hooks';
import {
  createCount,
  listCounts,
  listLocations,
  type CountSummary,
  type Location,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { formatDateTime } from '@core/format';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { Pager } from '@/components/Pager';
import { RefPicker } from '@/components/RefPicker';

/**
 * Stock counts — the list behind the artboard's «Sayım» entry.
 *
 * Web is the control and approval side; entering counted quantities shelf by shelf is the mobile
 * flow (ADR-013). What web owns is creating the document, freezing the location and deciding on
 * the variances — and freezing stops every movement on that location, so the screen says so
 * before the button is pressed rather than after.
 */
const COUNT_TYPE_LABELS: Record<string, string> = {
  FULL: 'Tam sayım',
  CYCLE: 'Dövri sayım',
  SPOT: 'Nöqtəvi sayım',
};

export function CountsScreen() {
  const navigate = useNavigate();
  const { can } = useAuth();
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState('');
  const [createOpen, setCreateOpen] = useState(false);
  const [locationId, setLocationId] = useState('');
  const [countType, setCountType] = useState<'FULL' | 'CYCLE' | 'SPOT'>('FULL');
  const [note, setNote] = useState('');

  const query = {
    page,
    size: 50,
    ...(status ? { status: status as CountSummary['status'] } : {}),
  };
  const counts = useApiPage<CountSummary>(['counts', query], () => listCounts(query), 50);
  const locations = useApiPage<Location>(['locations', 'counts'], () => listLocations({}), 200, {
    retry: false,
  });

  const create = useMutation({
    mutationFn: () =>
      createCount({
        countType,
        locationId: Number(locationId),
        ...(note ? { note } : {}),
      }),
    onSuccess: (created) => {
      setCreateOpen(false);
      navigate(`/inventory/counts/${created.id}`);
    },
  });

  const columns: Column<CountSummary>[] = [
    {
      key: 'docNo',
      header: 'Sənəd',
      width: '160px',
      render: (row) => (
        <Link to={`/inventory/counts/${row.id}`}>
          <span className="wms-doc-no">{row.docNo}</span>
        </Link>
      ),
    },
    { key: 'location', header: 'Lokasiya', render: (row) => row.location.name },
    {
      key: 'countType',
      header: 'Tip',
      width: '150px',
      render: (row) => (
        <Badge tone="neutral" variant="outline" title={row.countType}>
          {COUNT_TYPE_LABELS[row.countType] ?? row.countType}
        </Badge>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      width: '150px',
      render: (row) => <DocStatusBadge status={row.status} />,
    },
    {
      key: 'frozenAt',
      header: 'Dondurulub',
      width: '150px',
      render: (row) =>
        row.frozenAt ? (
          <span className="wms-num wms-small">{formatDateTime(row.frozenAt)}</span>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    { key: 'lineCount', header: 'Sətir', numeric: true, decimals: 0, width: '90px' },
    { key: 'countedLineCount', header: 'Sayılıb', numeric: true, decimals: 0, width: '100px' },
    {
      key: 'varianceLineCount',
      header: 'Fərqli sətir',
      numeric: true,
      decimals: 0,
      width: '120px',
    },
    {
      key: 'requiresApproval',
      header: 'Təsdiq',
      width: '150px',
      render: (row) =>
        row.requiresApproval ? (
          <Badge tone="warning" dot>
            Təsdiq tələb edir
          </Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
  ];

  return (
    <Page
      title="Sayım"
      subtitle="Sayım sənədləri, fərq icmalı və təsdiq vəziyyəti"
      actions={
        can('inv.count.create') ? (
          <Button variant="primary" onClick={() => setCreateOpen(true)}>
            Yeni sayım
          </Button>
        ) : (
          <Button disabled title="`inv.count.create` icazəniz yoxdur">
            Yeni sayım
          </Button>
        )
      }
    >
      <Alert tone="info" title="Dondurma lokasiyanı bloklayır">
        `freezeCount` işə düşdükdə həmin lokasiyada qəbul, məxaric, transfer, tullantı və nümunə
        əməliyyatları dayanır və server <span className="wms-num">409 LOCATION_FROZEN</span>{' '}
        qaytarır. Sayımı aparan özü təsdiqləyə bilməz (SoD, SPEC §7.1).
      </Alert>

      <Card>
        <div className="wms-toolbar">
          <Select
            label="Status"
            value={status}
            placeholder="Bütün statuslar"
            options={[
              { value: 'DRAFT', label: 'Qaralama' },
              { value: 'FROZEN', label: 'Dondurulub' },
              { value: 'COUNTING', label: 'Sayılır' },
              { value: 'REVIEW', label: 'Yoxlamada' },
              { value: 'APPROVED', label: 'Təsdiqlənib' },
              { value: 'POSTED', label: 'Post edilib' },
              { value: 'CANCELLED', label: 'Ləğv edilib' },
            ]}
            onChange={(e) => {
              setStatus(e.target.value);
              setPage(1);
            }}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      {counts.isLoading ? (
        <LoadingState />
      ) : counts.isError ? (
        <ErrorState error={counts.error} onRetry={() => void counts.refetch()} />
      ) : (
        <Card
          title="Sayım sənədləri"
          flush
          footer={counts.data ? <Pager page={counts.data} onPageChange={setPage} /> : undefined}
        >
          <DataTable<CountSummary>
            columns={columns}
            rows={counts.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Sayım siyahısı"
            empty="Açıq sayım yoxdur. «Yeni sayım» ilə lokasiya seçin; sayılan miqdarlar mobil tətbiqdən gəlir."
          />
        </Card>
      )}

      <Dialog
        open={createOpen}
        title="Yeni sayım yaradım?"
        subtitle="Sənəd qaralama kimi yaranır; sətirlər dondurma anında yazılır."
        onClose={create.isPending ? undefined : () => setCreateOpen(false)}
        footer={
          <>
            <Button
              disabled={create.isPending}
              title={create.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setCreateOpen(false)}
            >
              İmtina
            </Button>
            <Button
              variant="primary"
              loading={create.isPending}
              disabled={!locationId}
              title={!locationId ? 'Lokasiya məcburidir' : undefined}
              onClick={() => create.mutate()}
            >
              Yarat
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          {create.isError ? <ErrorState error={create.error} /> : null}
          <RefPicker
            label="Lokasiya"
            required
            value={locationId}
            operation="GET /masterdata/locations"
            listError={locations.error ?? null}
            placeholder="Lokasiya seçin"
            hint="Eyni lokasiyada açıq sayım varsa server 422 qaytarır."
            options={(locations.data?.items ?? [])
              .filter((l) => !l.isVirtual)
              .map((l) => ({ value: String(l.id), label: `${l.name} (${l.code})` }))}
            onChange={setLocationId}
          />
          <Select
            label="Sayım tipi"
            required
            value={countType}
            options={Object.entries(COUNT_TYPE_LABELS).map(([value, label]) => ({ value, label }))}
            onChange={(e) => setCountType(e.target.value as typeof countType)}
          />
          <TextField
            label="Qeyd"
            value={note}
            placeholder="Sayımın səbəbi və ya əhatəsi"
            onChange={(e) => setNote(e.target.value)}
          />
        </div>
      </Dialog>
    </Page>
  );
}
