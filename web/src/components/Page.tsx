import type { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';
import { Alert, Button, DocStatusBadge } from '@ds/index';
import { isApiError, type ProblemDetails } from '@api/problem';

/** Page frame: one `display` title per screen, actions on the right. */
export function Page({
  title,
  subtitle,
  actions,
  children,
}: {
  title: ReactNode;
  subtitle?: ReactNode;
  actions?: ReactNode;
  children: ReactNode;
}) {
  return (
    <>
      <div className="wms-page__head">
        <div>
          <h1 className="wms-page__title">{title}</h1>
          {subtitle ? <div className="wms-page__subtitle">{subtitle}</div> : null}
        </div>
        {actions ? <div className="wms-page__actions">{actions}</div> : null}
      </div>
      {children}
    </>
  );
}

export function Section({
  title,
  actions,
  children,
}: {
  title?: ReactNode;
  actions?: ReactNode;
  children: ReactNode;
}) {
  return (
    <section className="wms-section">
      {title || actions ? (
        <div className="wms-page__head">
          {title ? <h2 className="wms-section__title">{title}</h2> : <span />}
          {actions ? <div className="wms-page__actions">{actions}</div> : null}
        </div>
      ) : null}
      {children}
    </section>
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
