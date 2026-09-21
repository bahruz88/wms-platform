import { Alert, Badge, DataTable, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listPermissions, listRoles, type Permission, type RoleSummary } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { PERMISSION_CATALOGUE, ROLE_PERMISSIONS, roleAllows } from '@auth/permissions';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';

interface PermissionRow {
  code: string;
  module: string;
  isCritical: boolean;
  description?: string | null;
  roles: string[];
}

/**
 * Roles and permissions — docs/ux/screen-map.md §5.4.
 *
 * Two sources, in this order:
 *
 *   · `GET /identity/permissions` and `GET /identity/roles` — the tenant's real `iam_permission`
 *     and `iam_role` rows. When they answer, the matrix is the server's;
 *   · the bootstrap `RolePermissionMap` port in `src/auth/permissions.ts` — the same algorithm
 *     the gateway falls back to today, because `iam_role_permission` is empty and the endpoints
 *     are unrouted.
 *
 * Which one is on screen is stated at the top rather than left to be guessed: a matrix that
 * claims to be the tenant's configuration while actually coming from a TypeScript constant is
 * the kind of thing an administrator acts on and is wrong about.
 */
export function RolesScreen() {
  const { session } = useAuth();
  const roles = useApiPage<RoleSummary>(['roles'], () => listRoles(), 100, { retry: false });
  const permissions = useApiPage<Permission>(['permissions'], () => listPermissions(), 500, {
    retry: false,
  });

  const unrouted = (status: number | undefined | null) => status === 404 || status === 405;
  const permissionsUnrouted = permissions.isError && unrouted(permissions.error?.status);
  const rolesUnrouted = roles.isError && unrouted(roles.error?.status);
  const fromServer = !permissionsUnrouted && (permissions.data?.items ?? []).length > 0;

  // The role columns: the tenant's own roles when they are readable, else the bootstrap map's.
  const roleCodes =
    (roles.data?.items ?? []).length > 0
      ? (roles.data?.items ?? []).map((r) => r.code)
      : Object.keys(ROLE_PERMISSIONS);

  const catalogue: Array<{
    code: string;
    module: string;
    isCritical: boolean;
    description?: string | null;
  }> = fromServer
    ? (permissions.data?.items ?? []).map((p) => ({
        code: p.code,
        module: p.module,
        isCritical: p.isCritical ?? false,
        description: p.description,
      }))
    : PERMISSION_CATALOGUE.map((code) => ({
        code,
        module: code.split('.')[0] ?? '',
        isCritical:
          code.endsWith('view_cost') || code.endsWith('approve') || code.endsWith('reverse'),
      }));

  const rows: PermissionRow[] = catalogue.map((entry) => ({
    ...entry,
    roles: roleCodes.filter((role) => roleAllows([role], entry.code)),
  }));

  const matrixColumns: Column<PermissionRow>[] = [
    {
      key: 'module',
      header: 'Modul',
      width: '110px',
      render: (row) => <Badge tone="neutral">{row.module}</Badge>,
    },
    {
      key: 'code',
      header: 'İcazə',
      render: (row) => (
        <div>
          <span className="wms-row">
            <span className="wms-doc-no">{row.code}</span>
            {row.isCritical ? <Badge tone="warning">Kritik</Badge> : null}
          </span>
          {row.description ? <div className="wms-cell__sku">{row.description}</div> : null}
        </div>
      ),
    },
    ...roleCodes.map<Column<PermissionRow>>((role) => ({
      key: role,
      header: role,
      align: 'center',
      render: (row) =>
        row.roles.includes(role) ? (
          <Badge tone="success" title={`${role} → ${row.code}`}>
            Var
          </Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    })),
  ];

  const roleColumns: Column<RoleSummary>[] = [
    { key: 'code', header: 'Kod', render: (row) => <span className="wms-doc-no">{row.code}</span> },
    { key: 'name', header: 'Ad' },
    {
      key: 'isSystem',
      header: 'Növ',
      render: (row) =>
        row.isSystem ? (
          <Badge tone="accent">Sistem rolu</Badge>
        ) : (
          <Badge tone="neutral">Tenant rolu</Badge>
        ),
    },
  ];

  return (
    <Page
      title="Rollar və icazələr"
      subtitle="Rol → icazə xəritəsi, serverin öz alqoritmi ilə"
      actions={
        fromServer ? (
          <Badge tone="success">Mənbə: server</Badge>
        ) : (
          <Badge tone="warning" dot>
            Mənbə: bootstrap xəritəsi
          </Badge>
        )
      }
    >
      {permissionsUnrouted ? (
        <Alert
          tone="warning"
          title="Matris serverdən deyil, bootstrap xəritəsindən qurulub"
          code={permissions.error?.code}
        >
          <span className="wms-num">GET /identity/permissions</span> açılmayıb (
          <span className="wms-num">{permissions.error?.status ?? 404}</span>)
          {rolesUnrouted ? (
            <>
              , <span className="wms-num">GET /identity/roles</span> də
            </>
          ) : null}
          . Aşağıdakı matris <span className="wms-num">RolePermissionMap</span> portundan hesablanır
          — serverin bu gün faktiki tətbiq etdiyi qayda da elə budur, çünki{' '}
          <span className="wms-num">iam_role_permission</span> cədvəli boşdur. Endpoint açılan kimi
          matris tenantın öz sətirlərindən qurulacaq.
        </Alert>
      ) : null}

      <Alert tone="warning" title="Anbardara `master.product.view_cost` verilə bilməz">
        Vəzifə bölgüsü (SoD, SPEC §7.1): bu icazəni{' '}
        <span className="wms-num">WAREHOUSE_KEEPER</span> roluna əlavə etmək cəhdi{' '}
        <span className="wms-num">422</span> ilə rədd edilir.
      </Alert>

      <Card title="Tenant rolları" subtitle={`${roleCodes.length} rol`} flush>
        {roles.isLoading ? (
          <LoadingState />
        ) : rolesUnrouted ? (
          <div className="wms-card__body">
            <div className="wms-muted">
              <span className="wms-num">GET /identity/roles</span> açılmayıb (
              <span className="wms-num">{roles.error?.status ?? 404}</span>) — sütun başlıqları
              realm rollarından gəlir.
            </div>
          </div>
        ) : roles.isError ? (
          <div className="wms-card__body">
            <ErrorState error={roles.error} onRetry={() => void roles.refetch()} />
          </div>
        ) : (
          <DataTable<RoleSummary>
            columns={roleColumns}
            rows={roles.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Rollar"
            empty="Tenant-a məxsus rol yoxdur — yalnız realm rolları istifadə olunur."
          />
        )}
      </Card>

      <Card title="İcazə matrisi" subtitle={`${rows.length} icazə · ${roleCodes.length} rol`} flush>
        <DataTable<PermissionRow>
          columns={matrixColumns}
          rows={rows}
          rowKey={(row) => row.code}
          maxHeight="640px"
          label="Rol × icazə matrisi"
          caption={`Sizin rolunuz: ${session?.roles.join(', ') || '—'} · ${
            session?.permissions.length ?? 0
          } icazə`}
          empty="İcazə kataloqu boşdur."
        />
      </Card>
    </Page>
  );
}
