import { useAuth } from '@auth/index';
import { Tabs } from '@/components/Page';

/**
 * Master data is one navigation entry («Master data») that fans out into seven screens through
 * this tab strip — the artboards draw eleven entries for a product with far more screens, and
 * this is the corner they fold together (app/navigation.ts).
 *
 * A tab the user cannot open is not rendered; the route behind it refuses a deep link too.
 */
export function MasterDataTabs() {
  const { can } = useAuth();

  const items = [
    { to: '/master-data/products', label: 'Məhsullar', permission: 'master.product.view' },
    { to: '/master-data/categories', label: 'Kateqoriyalar', permission: 'master.product.view' },
    { to: '/master-data/suppliers', label: 'Təchizatçılar', permission: 'master.supplier.view' },
    { to: '/master-data/locations', label: 'Lokasiyalar', permission: 'master.location.view' },
    { to: '/master-data/uoms', label: 'Ölçü vahidləri', permission: 'master.product.view' },
    { to: '/master-data/reason-codes', label: 'Səbəb kodları', permission: 'master.reason.view' },
    { to: '/master-data/currency-rates', label: 'Məzənnələr', permission: 'master.currency.view' },
  ].filter((item) => can(item.permission));

  if (items.length <= 1) return null;
  return <Tabs items={items.map(({ to, label }) => ({ to, label }))} />;
}
