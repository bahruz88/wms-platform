import { useMemo, useState } from 'react';
import { Alert, Badge, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listPermissions, listRoles, type Permission, type RoleSummary } from '@api/endpoints';
import { useAuth } from '@auth/index';
import { ROLE_PERMISSIONS, roleAllows } from '@auth/permissions';
import { Card, ErrorState, LoadingState, Page } from '@/components/Page';
import { AdminTabs } from './AdminTabs';

/**
 * Roles and permissions — docs/ux/screen-map.md §5.4.
 *
 * The matrix is the tenant's: the rows come from `GET /identity/permissions` (`iam_permission`)
 * and the columns from `GET /identity/roles` (`iam_role`), including the roles a tenant added
 * itself — `STOCKTAKER` and `WASTE_TESTER` are in the running realm and no TypeScript constant
 * knows about them.
 *
 * Each role carries its own granted codes, so a cell is a fact about `iam_role_permission`, not
 * a re-derivation of the bootstrap map. That distinction is the whole point of this screen: an
 * administrator must not act on a matrix they believe is the tenant's when it is a constant
 * compiled into the interface. The bootstrap map is still imported, but only as a **fallback**
 * for a role the server sends without a permission list, and every such column says so.
 */

interface PermissionRow {
  code: string;
  module: string;
  isCritical: boolean;
  description?: string | null;
  roles: string[];
}

/**
 * `identity.v1.yaml` declares `RoleSummary` without its granted codes; the running service sends
 * them on `GET /identity/roles`. Reading them is what makes the matrix the tenant's, so the
 * extension is accepted here explicitly rather than by widening the generated type.
 */
type RoleRow = RoleSummary & { permissions?: string[] };

const grantedBy = (role: RoleRow): string[] | null =>
  Array.isArray(role.permissions) ? role.permissions : null;

export function RolesScreen() {
  const { session, permissionFallbackReason } = useAuth();
  const [search, setSearch] = useState('');
  const [module, setModule] = useState('');

  const roles = useApiPage<RoleRow>(['roles'], () => listRoles(), 200, { retry: false });
  const permissions = useApiPage<Permission>(['permissions'], () => listPermissions(), 500, {
    retry: false,
  });

  const roleRows = useMemo(() => roles.data?.items ?? [], [roles.data]);
  const permissionRows = useMemo(() => permissions.data?.items ?? [], [permissions.data]);

  /** Columns whose cells are derived rather than read: the server sent no granted list. */
  const derivedRoles = roleRows.filter((r) => grantedBy(r) === null).map((r) => r.code);

  const rows: PermissionRow[] = useMemo(
    () =>
      permissionRows.map((p) => ({
        code: p.code,
        module: p.module,
        isCritical: p.isCritical ?? false,
        description: p.description,
        roles: roleRows
          .filter((role) => {
            const granted = grantedBy(role);
            // The tenant's own rows when the service sends them; the bootstrap algorithm only
            // for a role that arrived without a list, and that column is labelled.
            return granted ? granted.includes(p.code) : roleAllows([role.code], p.code);
          })
          .map((role) => role.code),
      })),
    [permissionRows, roleRows],
  );

  const modules = [...new Set(permissionRows.map((p) => p.module))].sort();
  const needle = search.trim().toLowerCase();
  const visibleRows = rows.filter(
    (row) =>
      (module === '' || row.module === module) &&
      (needle === '' ||
        row.code.toLowerCase().includes(needle) ||
        (row.description ?? '').toLowerCase().includes(needle)),
  );

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
    ...roleRows.map<Column<PermissionRow>>((role) => ({
      key: role.code,
      header: role.code,
      align: 'center',
      render: (row) =>
        row.roles.includes(role.code) ? (
          <Badge tone="success" title={`${role.code} → ${row.code}`}>
            Var
          </Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    })),
  ];

  const roleColumns: Column<RoleRow>[] = [
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
    {
      key: 'granted',
      header: 'İcazə sayı',
      width: '130px',
      numeric: true,
      decimals: 0,
      render: (row) => {
        const granted = grantedBy(row);
        return granted ? (
          granted.length
        ) : (
          <Badge tone="warning" dot title="Server bu rol üçün icazə siyahısı göndərmədi">
            hesablanıb
          </Badge>
        );
      },
    },
  ];

  const loading = roles.isLoading || permissions.isLoading;
  const failed = roles.isError || permissions.isError;

  return (
    <Page
      title="Rollar və icazələr"
      subtitle="Şirkətinizdəki rollar və hər rolun icazələri"
      actions={
        failed ? (
          <Badge tone="danger" dot>
            Matris oxunmadı
          </Badge>
        ) : (
          <Badge tone="success">Mənbə: tenant</Badge>
        )
      }
    >
      <AdminTabs />

      {permissionFallbackReason ? (
        <Alert tone="warning" title="Sizin öz icazələriniz serverdən oxunmadı">
          {permissionFallbackReason} Aşağıdakı matris tenantın sətirlərindəndir, lakin sizin
          gördüyünüz menyu və düymələr token rollarından hesablanıb — yeganə həqiqi yoxlama serverin{' '}
          <span className="wms-num">x-permission</span> yoxlamasıdır.
        </Alert>
      ) : null}

      {derivedRoles.length > 0 ? (
        <Alert tone="warning" title="Bir neçə sütun serverdən deyil, hesablanıb">
          <span className="wms-num">{derivedRoles.join(', ')}</span> rolu üçün server icazə siyahısı
          göndərmədi; həmin sütunlar <span className="wms-num">RolePermissionMap</span>{' '}
          alqoritmindən hesablanır və tenantın faktiki sətirlərini əks etdirməyə bilər.
        </Alert>
      ) : null}

      <Alert tone="warning" title="Anbardara `master.product.view_cost` verilə bilməz">
        Vəzifə bölgüsü (SoD, SPEC §7.1): bu icazəni{' '}
        <span className="wms-num">WAREHOUSE_KEEPER</span> roluna əlavə etmək cəhdi{' '}
        <span className="wms-num">422</span> ilə rədd edilir.
      </Alert>

      <Card
        title="Tenant rolları"
        subtitle={`${roleRows.length} rol · ${roleRows.filter((r) => !r.isSystem).length} tenant rolu`}
        flush
      >
        {roles.isLoading ? (
          <LoadingState />
        ) : roles.isError ? (
          <div className="wms-card__body">
            <ErrorState error={roles.error} onRetry={() => void roles.refetch()} />
          </div>
        ) : (
          <DataTable<RoleRow>
            columns={roleColumns}
            rows={roleRows}
            rowKey={(row) => row.id}
            label="Rollar"
            empty="Hələ rol təyin edilməyib. Sistem administratoru rolları qurmalıdır."
          />
        )}
      </Card>

      <Card>
        <div className="wms-toolbar">
          <TextField
            label="Axtarış"
            value={search}
            placeholder="İcazə kodu və ya izah"
            onChange={(e) => setSearch(e.target.value)}
          />
          <Select
            label="Modul"
            value={module}
            placeholder="Bütün modullar"
            options={modules.map((m) => ({ value: m, label: m }))}
            onChange={(e) => setModule(e.target.value)}
          />
          <div className="wms-toolbar__spacer" />
        </div>
      </Card>

      <Card
        title="İcazə matrisi"
        subtitle={`${visibleRows.length} / ${rows.length} icazə · ${roleRows.length} rol`}
        flush
      >
        {loading ? (
          <LoadingState />
        ) : permissions.isError ? (
          <div className="wms-card__body">
            <ErrorState error={permissions.error} onRetry={() => void permissions.refetch()} />
          </div>
        ) : (
          <DataTable<PermissionRow>
            columns={matrixColumns}
            rows={visibleRows}
            rowKey={(row) => row.code}
            maxHeight="640px"
            label="Rol × icazə matrisi"
            caption={`Sizin rolunuz: ${session?.roles.join(', ') || '—'} · ${
              session?.permissions.length ?? 0
            } icazə · bootstrap xəritəsi ${Object.keys(ROLE_PERMISSIONS).length} rol tanıyır`}
            empty={
              rows.length === 0
                ? 'İcazə siyahısı boşdur — sistem administratoru ilə əlaqə saxlayın.'
                : 'Bu filtrə uyğun icazə yoxdur. Axtarışı və ya modulu dəyişin.'
            }
          />
        )}
      </Card>
    </Page>
  );
}
