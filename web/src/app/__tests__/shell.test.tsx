import { describe, expect, it } from 'vitest';
import { render, screen, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { monogram } from '../AppShell';
import { NAV_GROUPS, navItemMatches, visibleNavGroups } from '../navigation';
import { permissionsForRoles } from '@auth/permissions';
import { Card, DocumentPage, Page, Tabs } from '@/components/Page';
import { RefPicker } from '@/components/RefPicker';
import { ApiError } from '@api/problem';

/**
 * The shell rules in docs/design-system/screens/README.md are structural, so they are testable:
 * the list header and the document header are different elements with different heights, the
 * document header carries a breadcrumb and a `wms-num` document number beside its status badge,
 * and the action row holds exactly one primary button.
 */

const renderIn = (ui: React.ReactElement) => render(<MemoryRouter>{ui}</MemoryRouter>);

describe('user monogram', () => {
  it('takes the initials of a two-part name', () => {
    expect(monogram('Orxan Məmmədov')).toBe('OM');
  });

  it('uppercases through the Azerbaijani locale — `i` becomes `İ`, never `I`', () => {
    expect(monogram('irade quliyeva')).toBe('İQ');
    expect(monogram('ilkin')).toBe('İL');
  });

  it('falls back to two letters of a single-token username', () => {
    expect(monogram('admin')).toBe('AD');
  });

  it('never renders an empty monogram', () => {
    expect(monogram('')).toBe('—');
    expect(monogram('   ')).toBe('—');
  });
});

describe('navigation', () => {
  it('opens with the artboards’ ungrouped «Panel» block', () => {
    expect(NAV_GROUPS[0]?.labelKey).toBeNull();
    expect(NAV_GROUPS[0]?.items[0]?.to).toBe('/');
  });

  it('keeps warehouse work in one group, in the artboards’ order', () => {
    const inventory = NAV_GROUPS.find((g) => g.labelKey === 'nav.inventory');
    expect(inventory?.items.map((i) => i.to)).toEqual([
      '/inventory/goods-receipts',
      '/inventory/issues',
      '/inventory/stock-requests',
      '/inventory/counts',
      '/inventory/waste',
      // Screen-map §3.11 «Qaytarma», between the other document flows and the read-only views.
      '/inventory/returns',
      '/inventory/balances',
      '/inventory/batches',
      '/inventory/movements',
    ]);
  });

  it('filters «Qaytarma» on the code the service enforces, not the contract spelling', () => {
    const returns = NAV_GROUPS.flatMap((g) => g.items).find((i) => i.to === '/inventory/returns');
    // The contract writes `inv.rtv.view`; the gateway checks `inv.return.view`.
    expect(returns?.permission).toBe('inv.return.view');
    expect(
      visibleNavGroups(permissionsForRoles(['WAREHOUSE_KEEPER'])).flatMap((g) => g.items),
    ).toContainEqual(expect.objectContaining({ to: '/inventory/returns' }));
    // The branch user gets 403 from the gateway, so the entry is not shown to them.
    expect(
      visibleNavGroups(permissionsForRoles(['BRANCH_USER'])).flatMap((g) => g.items),
    ).not.toContainEqual(expect.objectContaining({ to: '/inventory/returns' }));
  });

  it('lights the parent entry for a detail route and for a tab sibling', () => {
    const waste = NAV_GROUPS.flatMap((g) => g.items).find((i) => i.to === '/inventory/waste');
    const issues = NAV_GROUPS.flatMap((g) => g.items).find((i) => i.to === '/inventory/issues');
    expect(waste && navItemMatches(waste, '/inventory/samples')).toBe(true);
    expect(issues && navItemMatches(issues, '/inventory/issues/42')).toBe(true);
    expect(issues && navItemMatches(issues, '/inventory/counts')).toBe(false);
  });

  it('matches the dashboard only on the root path', () => {
    const panel = NAV_GROUPS[0]?.items[0];
    expect(panel && navItemMatches(panel, '/')).toBe(true);
    expect(panel && navItemMatches(panel, '/inventory/balances')).toBe(false);
  });

  it('shows a keeper the warehouse group and no cost-bound entry', () => {
    const groups = visibleNavGroups(permissionsForRoles(['WAREHOUSE_KEEPER']));
    const labels = groups.flatMap((g) => g.items.map((i) => i.labelKey));
    expect(labels).toContain('nav.issues');
    expect(labels).toContain('nav.counts');
    expect(labels).not.toContain('nav.priceHistory');
  });
});

describe('screen frames', () => {
  it('gives a list screen a 72px header and the content well', () => {
    const { container } = renderIn(
      <Page title="Qalıqlar" subtitle="Balans proyeksiyası">
        <div>məzmun</div>
      </Page>,
    );
    const header = container.querySelector('header');
    expect(header?.className).toBe('wms-header');
    expect(header?.className).not.toContain('wms-header--doc');
    expect(container.querySelector('.wms-content')).toBeInTheDocument();
    expect(screen.getByRole('heading', { name: 'Qalıqlar' })).toBeInTheDocument();
  });

  it('gives a document screen the 84px header with breadcrumb, mono number and status badge', () => {
    const { container } = renderIn(
      <DocumentPage breadcrumb="Anbar · Qəbul" docNo="GR-2026-00311" status="DRAFT">
        <div>məzmun</div>
      </DocumentPage>,
    );
    const header = container.querySelector('header');
    expect(header?.className).toContain('wms-header--doc');
    expect(container.querySelector('.wms-header__crumb')?.textContent).toBe('Anbar · Qəbul');
    const docNo = container.querySelector('.wms-header__docno');
    expect(docNo?.textContent).toBe('GR-2026-00311');
    // The document number is always in the mono face (design-system README, «Tipoqrafiya»).
    expect(docNo?.className).toContain('wms-num');
    // Status never gets a hand-written badge — DocStatusBadge names it in Azerbaijani.
    expect(screen.getByTitle('DRAFT')).toHaveTextContent('Qaralama');
  });

  it('drops the mono face for a draft that has no number yet', () => {
    const { container } = renderIn(
      <DocumentPage docNo="Yeni qəbul" mono={false} status="DRAFT">
        <div />
      </DocumentPage>,
    );
    expect(container.querySelector('.wms-header__docno')?.className).not.toContain('wms-num');
  });

  it('carries exactly one primary button in a document action row', () => {
    const { container } = renderIn(
      <DocumentPage
        docNo="GR-2026-00311"
        status="DRAFT"
        actions={
          <>
            <button className="wms-btn wms-btn--ghost">Çap et</button>
            <button className="wms-btn wms-btn--secondary">Ləğv et</button>
            <button className="wms-btn wms-btn--primary">Post et</button>
          </>
        }
      >
        <div />
      </DocumentPage>,
    );
    const actions = container.querySelector('.wms-header__actions');
    expect(actions?.querySelectorAll('.wms-btn--primary')).toHaveLength(1);
    // ghost → secondary → primary, in that order.
    expect(Array.from(actions?.querySelectorAll('button') ?? []).map((b) => b.textContent)).toEqual(
      ['Çap et', 'Ləğv et', 'Post et'],
    );
  });

  it('renders a card with the artboards’ head/body split, and flushes a table body', () => {
    const { container } = renderIn(
      <Card title="Qəbul sətirləri" subtitle="4 sətir" flush>
        <table />
      </Card>,
    );
    expect(container.querySelector('.wms-card__head')).toBeInTheDocument();
    expect(container.querySelector('.wms-card__title')?.textContent).toBe('Qəbul sətirləri');
    expect(container.querySelector('.wms-card__body')?.className).toContain(
      'wms-card__body--flush',
    );
  });

  it('marks the active tab so one nav entry can fan out', () => {
    const { container } = render(
      <MemoryRouter initialEntries={['/inventory/samples']}>
        <Tabs
          items={[
            { to: '/inventory/waste', label: 'Tullantı' },
            { to: '/inventory/samples', label: 'Nümunə' },
          ]}
        />
      </MemoryRouter>,
    );
    const active = container.querySelector('.wms-tab--active');
    expect(active?.textContent).toBe('Nümunə');
  });
});

describe('RefPicker', () => {
  const options = [{ value: '1', label: 'Azərsun MMC' }];

  it('is an ordinary select while the list endpoint answers', () => {
    renderIn(
      <RefPicker
        label="Təchizatçı"
        value=""
        options={options}
        operation="GET /master-data/suppliers"
        onChange={() => {}}
      />,
    );
    expect(screen.getByRole('combobox')).toBeInTheDocument();
  });

  it('degrades to an id field and names the missing operation when the gateway 404s', () => {
    const listError = new ApiError({
      type: 'about:blank',
      title: 'Not Found',
      status: 404,
      code: 'NOT_FOUND',
    });
    const { container } = renderIn(
      <RefPicker
        label="Təchizatçı"
        value=""
        options={[]}
        listError={listError}
        operation="GET /master-data/suppliers"
        onChange={() => {}}
      />,
    );
    expect(container.querySelector('select')).toBeNull();
    const hint = container.querySelector('.wms-field__hint');
    // The reason is named, with the status — never a silently empty picker.
    expect(hint?.textContent).toContain('GET /master-data/suppliers');
    expect(hint?.textContent).toContain('404');
  });

  it('keeps the select when the failure is not a missing route', () => {
    const listError = new ApiError({
      type: 'about:blank',
      title: 'Server error',
      status: 500,
      code: 'VALIDATION_FAILED',
    });
    renderIn(
      <RefPicker
        label="Təchizatçı"
        value=""
        options={options}
        listError={listError}
        operation="GET /master-data/suppliers"
        onChange={() => {}}
      />,
    );
    expect(screen.getByRole('combobox')).toBeInTheDocument();
  });
});

describe('document header context', () => {
  it('shows context badges beside the number', () => {
    renderIn(
      <DocumentPage
        docNo="IC-2026-00012"
        status="REVIEW"
        badges={<span data-testid="ctx">Tam sayım</span>}
        context="Food WH · dondurulub"
      >
        <div />
      </DocumentPage>,
    );
    const line = screen.getByText('IC-2026-00012').parentElement;
    expect(within(line as HTMLElement).getByTestId('ctx')).toHaveTextContent('Tam sayım');
    expect(within(line as HTMLElement).getByText(/Food WH/)).toBeInTheDocument();
  });
});
