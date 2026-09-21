import type { ReactNode } from 'react';
import { NavLink } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Alert, Button, DocStatusBadge } from '@ds/index';
import { isApiError, type ProblemDetails } from '@api/problem';

/**
 * Screen frames — docs/design-system/screens/README.md «Layout qaydaları».
 *
 * A screen owns its header because the artboards give it two different heights: 72px on a list
 * (title + one muted line) and 84px on a document (breadcrumb, then the document number in
 * `wms-num` at 20px/600 beside its `DocStatusBadge` and any context badges). Both put the action
 * buttons on the right in ghost → secondary → primary order, and both are followed by the same
 * content well: `padding: 20px 32px`, `gap: 16px`.
 */

/** List screen: 72px header. */
export function Page({
  title,
  subtitle,
  actions,
  contentClassName,
  children,
}: {
  title: ReactNode;
  subtitle?: ReactNode;
  actions?: ReactNode;
  contentClassName?: string;
  children: ReactNode;
}) {
  return (
    <>
      <header className="wms-header">
        <div className="wms-header__main">
          <h1 className="wms-header__title">{title}</h1>
          {subtitle ? <div className="wms-header__sub">{subtitle}</div> : null}
        </div>
        {actions ? <div className="wms-header__actions">{actions}</div> : null}
      </header>
      <div className={contentClassName ? `wms-content ${contentClassName}` : 'wms-content'}>
        {children}
      </div>
    </>
  );
}

/**
 * Document screen: 84px header with the breadcrumb line above the document number.
 *
 * `status` goes through `DocStatusBadge` — no screen writes its own status badge
 * (docs/design-system/README.md «Sənəd statusu hər yerdə eyni görünür»).
 */
export function DocumentPage({
  breadcrumb,
  docNo,
  mono = true,
  status,
  statusLabel,
  badges,
  context,
  actions,
  contentClassName,
  children,
}: {
  breadcrumb?: ReactNode;
  docNo: ReactNode;
  /** A document that has no number yet (a draft being written) sets this to false. */
  mono?: boolean;
  status?: string | null;
  statusLabel?: string;
  badges?: ReactNode;
  context?: ReactNode;
  actions?: ReactNode;
  contentClassName?: string;
  children: ReactNode;
}) {
  return (
    <>
      <header className="wms-header wms-header--doc">
        <div className="wms-header__main">
          {breadcrumb ? <div className="wms-header__crumb">{breadcrumb}</div> : null}
          <div className="wms-header__docline">
            <span className={mono ? 'wms-num wms-header__docno' : 'wms-header__docno'}>
              {docNo}
            </span>
            {status ? <DocStatusBadge status={status} label={statusLabel} /> : null}
            {badges}
            {context ? <span className="wms-header__context">{context}</span> : null}
          </div>
        </div>
        {actions ? <div className="wms-header__actions">{actions}</div> : null}
      </header>
      <div className={contentClassName ? `wms-content ${contentClassName}` : 'wms-content'}>
        {children}
      </div>
    </>
  );
}

/**
 * Card — `surface`, `border`, `radius-lg`; head `14px 16px` with a bottom border, body `16px`.
 * `flush` drops the body padding so a table keeps the card's own frame instead of drawing a
 * second one.
 */
export function Card({
  title,
  subtitle,
  actions,
  flush,
  rows,
  footer,
  className,
  children,
}: {
  title?: ReactNode;
  subtitle?: ReactNode;
  actions?: ReactNode;
  /** The body holds a table or another framed block: no padding. */
  flush?: boolean;
  /** The body is a list of rows with their own 12/16 padding. */
  rows?: boolean;
  footer?: ReactNode;
  className?: string;
  children?: ReactNode;
}) {
  const bodyClasses = ['wms-card__body'];
  if (flush) bodyClasses.push('wms-card__body--flush');
  if (rows) bodyClasses.push('wms-card__body--rows');

  return (
    <section className={className ? `wms-card ${className}` : 'wms-card'}>
      {title || subtitle || actions ? (
        <div className="wms-card__head">
          <div>
            {title ? <h2 className="wms-card__title">{title}</h2> : null}
            {subtitle ? <div className="wms-card__sub">{subtitle}</div> : null}
          </div>
          {actions ? <div className="wms-card__actions">{actions}</div> : null}
        </div>
      ) : null}
      {children !== undefined ? <div className={bodyClasses.join(' ')}>{children}</div> : null}
      {footer ? <div className="wms-card__foot">{footer}</div> : null}
    </section>
  );
}

/**
 * Backwards-compatible section wrapper: a titled card. It renders the same card the artboards
 * draw, so a screen that still uses it reads as part of the same product — but it loses the list
 * rhythm the artboards set out (a filter card, then one flush-framed table with the pager in the
 * card's footer).
 *
 * Every warehouse, master-data and administration screen has been moved off it. What remains are
 * the consumption, procurement and reporting screens, whose endpoints are mostly unrouted; they
 * should be reworked when those land and the layouts can be checked against real data.
 */
export function Section({
  title,
  subtitle,
  actions,
  flush,
  children,
}: {
  title?: ReactNode;
  subtitle?: ReactNode;
  actions?: ReactNode;
  flush?: boolean;
  children: ReactNode;
}) {
  return (
    <Card title={title} subtitle={subtitle} actions={actions} flush={flush}>
      {children}
    </Card>
  );
}

/** A row of sibling screens reached from one navigation entry. */
export function Tabs({ items }: { items: Array<{ to: string; label: ReactNode }> }) {
  const { t } = useTranslation();
  return (
    <nav className="wms-tabs" aria-label={t('app.sectionNav')}>
      {items.map((item) => (
        <NavLink
          key={item.to}
          to={item.to}
          className={({ isActive }) => (isActive ? 'wms-tab wms-tab--active' : 'wms-tab')}
        >
          {item.label}
        </NavLink>
      ))}
    </nav>
  );
}

/** Metadata grid — six columns on a document header, as the goods-receipt artboard draws it. */
export function MetaGrid({ columns = 6, children }: { columns?: 2 | 4 | 6; children: ReactNode }) {
  const cls = columns === 6 ? 'wms-meta' : `wms-meta wms-meta--${columns}`;
  return <div className={cls}>{children}</div>;
}

export function Meta({
  label,
  value,
  sub,
}: {
  label: ReactNode;
  value: ReactNode;
  sub?: ReactNode;
}) {
  return (
    <div>
      <div className="wms-meta__k">{label}</div>
      <div className="wms-meta__v">{value}</div>
      {sub ? <div className="wms-meta__sub">{sub}</div> : null}
    </div>
  );
}

/** Key/value block for document headers. */
export function KeyValue({ items }: { items: Array<[ReactNode, ReactNode]> }) {
  return (
    <dl className="wms-kv">
      {items.map(([key, value], i) => (
        <div key={i} style={{ display: 'contents' }}>
          <dt className="wms-kv__key">{key}</dt>
          <dd className="wms-kv__val" style={{ margin: 0 }}>
            {value}
          </dd>
        </div>
      ))}
    </dl>
  );
}

export function DocNo({ value }: { value: string | null | undefined }) {
  return <span className="wms-doc-no">{value ?? '—'}</span>;
}

/** Product cell: name on top, SKU in `mono` underneath — the artboards' line-table idiom. */
export function ProductCell({ name, sku }: { name: ReactNode; sku?: ReactNode }) {
  return (
    <div>
      <div className="wms-cell__name">{name}</div>
      {sku ? <div className="wms-cell__sku wms-num">{sku}</div> : null}
    </div>
  );
}

export function StatusCell({ status }: { status: string | null | undefined }) {
  if (!status) return <span className="wms-muted">—</span>;
  return <DocStatusBadge status={status} />;
}

/**
 * The single place that turns a failed request into something the user can act on. The RFC 7807
 * fields are copied over unchanged — title → title, detail → body, code → code — because support
 * has to see the same text the server produced (components/Alert/README.md).
 *
 * A 404 or 405 from the gateway means the contract operation exists but the module has not been
 * enabled yet; that reads as information, not as a failure the user caused.
 */
export function ErrorState({ error, onRetry }: { error: unknown; onRetry?: () => void }) {
  const { t } = useTranslation();
  const problem: ProblemDetails | null = isApiError(error) ? error.problem : null;

  if (problem && (problem.status === 404 || problem.status === 405)) {
    return (
      <Alert tone="info" title={t('state.notImplementedTitle')} code={problem.code}>
        {t('state.notImplementedBody', { status: problem.status })}
      </Alert>
    );
  }

  return (
    <Alert
      tone="danger"
      title={problem?.title ?? t('state.errorTitle')}
      code={problem?.code}
      traceId={problem?.traceId}
    >
      <div className="wms-stack">
        <span>{problem?.detail ?? (error instanceof Error ? error.message : String(error))}</span>
        {problem?.errors ? (
          <ul style={{ margin: 0, paddingLeft: 18 }}>
            {Object.entries(problem.errors).map(([field, messages]) => (
              <li key={field}>
                <span className="wms-num">{field}</span>: {messages.join('; ')}
              </li>
            ))}
          </ul>
        ) : null}
        {onRetry ? (
          <div>
            <Button size="sm" onClick={onRetry}>
              {t('state.retry')}
            </Button>
          </div>
        ) : null}
      </div>
    </Alert>
  );
}

/**
 * Says out loud that an operation the screen offers is not routed yet. Used instead of a button
 * that would appear to work: the user never sees a success that did not happen.
 */
export function NotOpenYet({
  operation,
  status,
  children,
}: {
  operation: string;
  status?: number;
  children?: ReactNode;
}) {
  const { t } = useTranslation();
  return (
    <Alert tone="info" title={t('state.notImplementedTitle')}>
      <div className="wms-stack">
        <span>
          <span className="wms-num">{operation}</span> —{' '}
          {t('state.notImplementedBody', { status: status ?? 404 })}
        </span>
        {children}
      </div>
    </Alert>
  );
}

export function LoadingState({ label }: { label?: string }) {
  const { t } = useTranslation();
  return (
    <div className="wms-page-state" role="status">
      <span className="wms-spinner" aria-hidden="true" />
      <span>{label ?? t('state.loading')}</span>
    </div>
  );
}

/** Wraps a query's three states so no screen forgets one of them. */
export function QueryState({
  isLoading,
  error,
  onRetry,
  children,
}: {
  isLoading: boolean;
  error: unknown;
  onRetry?: () => void;
  children: ReactNode;
}) {
  if (isLoading) return <LoadingState />;
  if (error) return <ErrorState error={error} onRetry={onRetry} />;
  return <>{children}</>;
}
