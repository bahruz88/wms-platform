import { useState } from 'react';
import { Badge, DataTable, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listUsers, type UserSummary } from '@api/endpoints';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { Pager } from '@/components/Pager';

/**
 * Users — docs/ux/screen-map.md §5.4. `GET /identity/users` is routed and answering.
 *
 * Read-only: `createUser`, `setUserRoles` and `setUserLocations` are POST/PUT operations the
 * gateway does not route yet, and a user's Keycloak subject binding must not be guessable from a
 * half-wired form.
 *
 * Laid out like the other list screens the artboards define — a filter card, then one framed
 * table with the pager in the card's footer — rather than the untitled `Section` wrapper it
 * carried before.
 */
export function UsersScreen() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');

  const query = { page, size: 50, ...(search.trim() ? { q: search.trim() } : {}) };
  const users = useApiPage<UserSummary>(['users', query], () => listUsers(query), 50);

  const columns: Column<UserSummary>[] = [
    {
      key: 'username',
      header: 'İstifadəçi',
      render: (row) => <span className="wms-doc-no">{row.username}</span>,
    },
    { key: 'fullName', header: 'Ad, soyad' },
    { key: 'email', header: 'E-poçt', render: (row) => row.email ?? '—' },
    {
      key: 'isActive',
      header: 'Vəziyyət',
      render: (row) =>
        row.isActive ? <Badge tone="success">Aktiv</Badge> : <Badge tone="neutral">Bağlı</Badge>,
    },
  ];

  return (
    <Page
      title="İstifadəçilər"
      subtitle="Keycloak subject bağlanması, rollar və lokasiya girişi (boş = hamısı)"
    >
      <Card>
        <div className="wms-toolbar">
          <TextField
            label="Axtarış"
            value={search}
            placeholder="İstifadəçi adı və ya e-poçt"
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      {users.isLoading ? (
        <LoadingState />
      ) : users.isError ? (
        <ErrorState error={users.error} onRetry={() => void users.refetch()} />
      ) : (
        <Card
          title="İstifadəçilər"
          flush
          footer={users.data ? <Pager page={users.data} onPageChange={setPage} /> : undefined}
        >
          <DataTable<UserSummary>
            columns={columns}
            rows={users.data?.items ?? []}
            rowKey={(row) => row.id}
            label="İstifadəçi siyahısı"
            empty={
              search.trim()
                ? `«${search.trim()}» üçün istifadəçi tapılmadı. Axtarışı təmizləyin.`
                : 'Tenant-da qeydə alınmış istifadəçi yoxdur. Keycloak istifadəçisi ilk girişdə `iam_user` sətrinə bağlanır.'
            }
          />
        </Card>
      )}
    </Page>
  );
}
