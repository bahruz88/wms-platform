import type { ReactNode } from 'react';
import { Icons } from './Icons';

/**
 * Alert — docs/design-system/components/Alert/README.md.
 *
 * Block-level message for a server error (RFC 7807), a blocked operation or a confirmation.
 * The problem's `code` is printed as it came: support works with that string, so it is never
 * hidden or rewritten. `danger` gets `role="alert"`, everything else `role="status"`.
 *
 * Field-level validation does not belong here — it goes to `TextField`'s `error`.
 */
export interface AlertProps {
  tone?: 'info' | 'success' | 'warning' | 'danger';
  title?: ReactNode;
  /** RFC 7807 `code` — support works with it, do not hide it. */
  code?: string;
  traceId?: string;
  onClose?: () => void;
  children?: ReactNode;
}

const TONE_ICON = {
  info: Icons.info,
  success: Icons.check,
  warning: Icons.warn,
  danger: Icons.warn,
} as const;

export function Alert({ tone = 'info', title, code, traceId, onClose, children }: AlertProps) {
  const icon = TONE_ICON[tone];
  return (
    <div className={`wms-alert wms-alert--${tone}`} role={tone === 'danger' ? 'alert' : 'status'}>
      <span className="wms-alert__icon">{icon(16)}</span>
      <div className="wms-alert__body">
        {title ? <div className="wms-alert__title">{title}</div> : null}
        {children ? <div className="wms-alert__text">{children}</div> : null}
        {code || traceId ? (
          <div className="wms-alert__code">
            {code ? <span>{code}</span> : null}
            {code && traceId ? <span> · </span> : null}
            {traceId ? <span>trace {traceId}</span> : null}
          </div>
        ) : null}
      </div>
      {onClose ? (
        <button type="button" className="wms-iconbtn" onClick={onClose} aria-label="Bağla">
          {Icons.close(16)}
        </button>
      ) : null}
    </div>
  );
}
