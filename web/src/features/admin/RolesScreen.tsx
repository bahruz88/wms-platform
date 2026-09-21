import { Alert, Badge, DataTable, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listRoles, type RoleSummary } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { PERMISSION_CATALOGUE, ROLE_PERMISSIONS, roleAllows } from '@auth/permissions';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';

interface PermissionRow {
  code: string;
  module: string;
  isCritical: boolean;
  roles: string[];
}

/**
 * Roles and permissions — docs/ux/screen-map.md §5.4.
 *
 * The matrix is resolved with the same algorithm the server uses
 * (`Wms.Common.Infrastructure.Tenancy.RolePermissionMap`), so what the interface shows here is
 * what the gateway will actually allow. The `WAREHOUSE_KEEPER` row deliberately has no
 * `master.product.view_cost`: granting it is refused with `422` (SoD, SPEC §7.1).
 */
export function RolesScreen() {
  const { session } = useAuth();
  const roles = useApiPage<RoleSummary>(['roles'], () => listRoles(), 100);

  const roleCodes = Object.keys(ROLE_PERMISSIONS);

  const rows: PermissionRow[] = PERMISSION_CATALOGUE.map((code) => ({
    code,
    module: code.split('.')[0] ?? '',
    isCritical: code.endsWith('view_cost') || code.endsWith('approve') || code.endsWith('reverse'),
    roles: roleCodes.filter((role) => roleAllows([role], code)),
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
        <span className="wms-row">
          <span className="wms-doc-no">{row.code}</span>
          {row.isCritical ? <Badge tone="warning">Kritik</Badge> : null}
        </span>
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
    <Page title="Rollar və icazələr" subtitle="Rol → icazə xəritəsi, serverin öz alqoritmi ilə">
      <Alert tone="warning" title="Anbardara `master.product.view_cost` verilə bilməz">
        Vəzifə bölgüsü (SoD, SPEC §7.1): bu icazəni{' '}
        <span className="wms-num">WAREHOUSE_KEEPER</span> roluna əlavə etmək cəhdi{' '}
        <span className="wms-num">422</span> ilə rədd edilir.
      </Alert>

      <Section title="Tenant rolları">
        {roles.isLoading ? (
          <LoadingState />
        ) : roles.isError ? (
          <ErrorState error={roles.error} onRetry={() => void roles.refetch()} />
        ) : (
          <DataTable<RoleSummary>
            columns={roleColumns}
            rows={roles.data?.items ?? []}
            rowKey={(row) => row.id}
            label="Rollar"
            empty="Tenant-a məxsus rol yoxdur — yalnız realm rolları istifadə olunur."
          />
        )}
      </Section>

      <Section title="İcazə matrisi">
        <DataTable<PermissionRow>
          columns={matrixColumns}
          rows={rows}
          rowKey={(row) => row.code}
          maxHeight="640px"
          label="Rol × icazə matrisi"
          caption={`Sizin rolunuz: ${session?.roles.join(', ') || '—'} · ${session?.permissions.length ?? 0} icazə`}
          empty="İcazə kataloqu boşdur."
        />
      </Section>
    </Page>
  );
}
