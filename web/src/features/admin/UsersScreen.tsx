import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Badge, Button, DataTable, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { createUser, listUsers, type UserSummary } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import {
  ReferenceFormDialog,
  text,
  type FieldSpec,
  type FormValues,
} from '@/components/ReferenceFormDialog';
import { AdminTabs } from './AdminTabs';
import { Pager } from '@/components/Pager';

/**
 * Users — docs/ux/screen-map.md §5.4. `GET /identity/users` is routed and answering.
 *
 * Creating a user here does not create a Keycloak account — it binds one that already exists. The
 * form asks for the subject (`sub`) rather than a password, because the platform never holds
 * credentials: authentication is Keycloak's and authorisation is this row's.
 *
 * Roles and location scope are set on the user's own screen, where the empty-list rule can be
 * spelled out next to the control it applies to.
 *
 * Laid out like the other list screens the artboards define — a filter card, then one framed
 * table with the pager in the card's footer — rather than the untitled `Section` wrapper it
 * carried before.
 */
const USER_FIELDS: FieldSpec[] = [
  {
    name: 'externalId',
    label: 'Keycloak subject (sub)',
    kind: 'text',
    required: true,
    hint: 'Keycloak-daki mövcud hesabın `sub` dəyəri — burada yeni hesab yaradılmır.',
  },
  { name: 'username', label: 'İstifadəçi adı', kind: 'text', required: true },
  { name: 'fullName', label: 'Ad, soyad', kind: 'text', required: true },
  {
    name: 'email',
    label: 'E-poçt',
    kind: 'text',
    validate: (value) =>
      value.trim().length === 0 || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.trim())
        ? undefined
        : 'E-poçt ünvanı düzgün deyil.',
  },
  { name: 'phone', label: 'Telefon', kind: 'text' },
];

export function UsersScreen() {
  const { can } = useAuth();
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState('');
  const [creating, setCreating] = useState(false);

  const create = useMutation({
    mutationFn: (values: FormValues) =>
      createUser({
        externalId: text(values, 'externalId'),
        username: text(values, 'username'),
        fullName: text(values, 'fullName'),
        ...(text(values, 'email') ? { email: text(values, 'email') } : {}),
        ...(text(values, 'phone') ? { phone: text(values, 'phone') } : {}),
      }),
    onSuccess: () => {
      setCreating(false);
      void queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });

  const query = { page, size: 50, ...(search.trim() ? { q: search.trim() } : {}) };
  const users = useApiPage<UserSummary>(['users', query], () => listUsers(query), 50);

  const columns: Column<UserSummary>[] = [
    {
      key: 'username',
      header: 'İstifadəçi',
      render: (row) => (
        <Link className="wms-doc-no" to={`/admin/users/${row.id}`}>
          {row.username}
        </Link>
      ),
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
      actions={
        can('iam.user.manage') ? (
          <Button variant="primary" onClick={() => setCreating(true)}>
            İstifadəçi bağla
          </Button>
        ) : null
      }
    >
      <AdminTabs />

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
      <ReferenceFormDialog
        open={creating}
        mode="create"
        title="Keycloak istifadəçisini bağla"
        subtitle="Burada yeni hesab yaradılmır — mövcud Keycloak hesabı tenant-a bağlanır. Rol və lokasiya sonra istifadəçi ekranında təyin olunur."
        fields={USER_FIELDS}
        pending={create.isPending}
        error={create.isError ? create.error : undefined}
        onClose={() => setCreating(false)}
        onSubmit={(values) => create.mutate(values)}
      />

    </Page>
  );
}
