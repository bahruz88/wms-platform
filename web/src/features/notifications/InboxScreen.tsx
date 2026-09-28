import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Badge, Button, DataTable, Select, type Column } from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  getUnreadNotificationCount,
  listNotifications,
  markAllNotificationsRead,
  markNotificationRead,
  type Notification,
} from '@api/endpoints';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Notification inbox — notifications.v1.yaml `listNotifications`.
 *
 * The rows are written by the consumer that reads `wms.events`, so this screen is a reader: there is
 * no compose action and nothing here creates a notification. The two things a person does with an
 * inbox — open the thing it is about, and stop it shouting — are the whole interface.
 *
 * A row carries the deep link the server composed (`/inventory/goods-receipts/311`), so following a
 * notification lands on the document rather than on a search. Opening one marks it read on the way.
 */
export function InboxScreen() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [unreadOnly, setUnreadOnly] = useState(true);

  const query = { page, size: 50, ...(unreadOnly ? { unreadOnly: true } : {}) };
  const inbox = useApiPage<Notification>(['notifications', query], () => listNotifications(query), 50);
  const unread = useApiQuery(['notifications', 'unread-count'], getUnreadNotificationCount);

  const refresh = () => {
    void queryClient.invalidateQueries({ queryKey: ['notifications'] });
  };

  const open = useMutation({
    mutationFn: (row: Notification) => markNotificationRead(row.id),
    onSuccess: (_data, row) => {
      refresh();
      if (row.link) navigate(row.link);
    },
  });

  // The cut-off is taken when the screen renders, not when the button is tapped: a notification
  // that arrives in between stays unread rather than being silenced unseen.
  const [openedAt] = useState(() => new Date().toISOString());
  const readAll = useMutation({
    mutationFn: () => markAllNotificationsRead(openedAt),
    onSuccess: refresh,
  });

  const counts = unread.data as
    | { total: number; bySeverity: Record<string, number>; pendingApprovals?: number }
    | undefined;

  const columns: Column<Notification>[] = useMemo(
    () => [
      {
        key: 'severity',
        header: 'Səviyyə',
        width: '110px',
        render: (row) => (
          <Badge tone={SEVERITY_TONES[row.severity] ?? 'neutral'}>
            {SEVERITY_LABELS[row.severity] ?? row.severity}
          </Badge>
        ),
      },
      {
        key: 'title',
        header: 'Bildiriş',
        render: (row) => (
          <span className={row.isRead ? 'wms-muted' : undefined}>
            <strong>{row.title}</strong>
            {row.body ? <div className="wms-muted wms-small">{row.body}</div> : null}
          </span>
        ),
      },
      {
        key: 'createdAt',
        header: 'Vaxt',
        width: '150px',
        render: (row) => <span className="wms-num">{formatWhen(row.createdAt)}</span>,
      },
      {
        key: 'isRead',
        header: '',
        width: '150px',
        render: (row) => (
          <Button
            variant={row.link ? 'primary' : 'secondary'}
            loading={open.isPending && open.variables?.id === row.id}
            onClick={() => open.mutate(row)}
          >
            {row.link ? 'Sənədə keç' : 'Oxundu işarələ'}
          </Button>
        ),
      },
    ],
    [open],
  );

  return (
    <Page
      title="Bildirişlər"
      subtitle="Anbarda baş verənlərdən sizə çatanlar. Hansı hadisənin kimə çatdığı «Sistem» qaydaları ilə təyin olunur."
      actions={
        counts && counts.total > 0 ? (
          <Button variant="secondary" loading={readAll.isPending} onClick={() => readAll.mutate()}>
            Hamısını oxundu işarələ
          </Button>
        ) : null
      }
    >
      <Card>
        <div className="wms-toolbar">
          <Select
            label="Göstərilənlər"
            value={unreadOnly ? '1' : '0'}
            options={[
              { value: '1', label: 'Yalnız oxunmayanlar' },
              { value: '0', label: 'Hamısı' },
            ]}
            onChange={(e) => {
              setUnreadOnly(e.target.value === '1');
              setPage(1);
            }}
          />
          <div className="wms-toolbar__spacer" />
          {counts ? (
            <div className="wms-row">
              <Badge tone="danger">{`Kritik ${counts.bySeverity.CRITICAL ?? 0}`}</Badge>
              <Badge tone="warning">{`Xəbərdarlıq ${counts.bySeverity.WARNING ?? 0}`}</Badge>
              <Badge tone="neutral">{`Məlumat ${counts.bySeverity.INFO ?? 0}`}</Badge>
            </div>
          ) : null}
        </div>
      </Card>

      {inbox.isLoading ? (
        <LoadingState />
      ) : inbox.isError ? (
        <ErrorState error={inbox.error} />
      ) : (
        <Card>
          <DataTable
            columns={columns}
            rows={inbox.data?.items ?? []}
            rowKey={(row) => row.id}
            empty={
              unreadOnly
                ? 'Oxunmamış bildiriş yoxdur.'
                : 'Hələ bildiriş yoxdur. Anbarda sənəd post edildikcə burada görünəcək.'
            }
          />
          {inbox.data ? <Pager page={inbox.data} onPageChange={setPage} /> : null}
        </Card>
      )}
      {readAll.isError ? <ErrorState error={readAll.error} /> : null}
      {open.isError ? <ErrorState error={open.error} /> : null}
    </Page>
  );
}

const SEVERITY_LABELS: Record<string, string> = {
  INFO: 'Məlumat',
  WARNING: 'Xəbərdarlıq',
  CRITICAL: 'Kritik',
};

const SEVERITY_TONES: Record<string, 'neutral' | 'warning' | 'danger'> = {
  INFO: 'neutral',
  WARNING: 'warning',
  CRITICAL: 'danger',
};

/** Same-day notifications show the clock; older ones the date — the usual inbox convention. */
function formatWhen(iso: string): string {
  const at = new Date(iso);
  if (Number.isNaN(at.getTime())) return '—';
  const today = new Date();
  const sameDay =
    at.getDate() === today.getDate() &&
    at.getMonth() === today.getMonth() &&
    at.getFullYear() === today.getFullYear();
  const two = (n: number) => String(n).padStart(2, '0');
  return sameDay
    ? `${two(at.getHours())}:${two(at.getMinutes())}`
    : `${two(at.getDate())}.${two(at.getMonth() + 1)}.${at.getFullYear()}`;
}
