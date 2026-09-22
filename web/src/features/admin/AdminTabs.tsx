import { useAuth } from '@auth/index';
import { Tabs } from '@/components/Page';

/**
 * The administration corner is one navigation entry that fans out here, exactly as the
 * artboards' single «Master data» / «Hesabatlar» entries imply (app/navigation.ts).
 *
 * A tab the user may not open is **not shown** — it is not disabled (docs/ux/screen-map.md §2),
 * and the route behind it refuses a deep link anyway.
 */
export function AdminTabs() {
  const { can } = useAuth();

  const items = [
    { to: '/admin/users', label: 'İstifadəçilər', permission: 'iam.user.view' },
    { to: '/admin/roles', label: 'Rollar və icazələr', permission: 'iam.role.view' },
    { to: '/admin/settings', label: 'Parametrlər', permission: 'inv.settings.view' },
  ].filter((item) => can(item.permission));

  if (items.length <= 1) return null;
  return <Tabs items={items.map(({ to, label }) => ({ to, label }))} />;
}
