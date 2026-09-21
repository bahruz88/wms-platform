import { useEffect, useRef, type ReactNode } from 'react';
import { Icons } from './Icons';

/**
 * Dialog — docs/design-system/components/Dialog/README.md.
 *
 * Confirmation, a mandatory reason, a small form. A multi-line document is edited on its own page,
 * never in a modal. Footer order: confirm on the right, cancel to its left, and the confirm button
 * carries the operation's name ("Storno et"), never "OK".
 *
 * Clicking the scrim calls `onClose`; when data could be lost the screen simply does not pass
 * `onClose` and leaves only the footer buttons. Focus moves to the first interactive element on
 * open and returns to the opener on close; Escape closes when `onClose` is given.
 */
export interface DialogProps {
  open: boolean;
  title?: ReactNode;
  subtitle?: ReactNode;
  size?: 'md' | 'lg';
  /** Without it the modal closes only through the footer buttons. */
  onClose?: () => void;
  footer?: ReactNode;
  children?: ReactNode;
}

export function Dialog({
  open,
  title,
  subtitle,
  size = 'md',
  onClose,
  footer,
  children,
}: DialogProps) {
  const dialogRef = useRef<HTMLDivElement>(null);
  const openerRef = useRef<Element | null>(null);

  useEffect(() => {
    if (!open) return;
    openerRef.current = document.activeElement;
    const node = dialogRef.current;
    const focusable = node?.querySelector<HTMLElement>(
      'button:not([disabled]), [href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])',
    );
    focusable?.focus();

    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && onClose) onClose();
    };
    document.addEventListener('keydown', onKeyDown);
    return () => {
      document.removeEventListener('keydown', onKeyDown);
      (openerRef.current as HTMLElement | null)?.focus?.();
    };
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div
      className="wms-scrim"
      onClick={(e) => {
        if (e.target === e.currentTarget && onClose) onClose();
      }}
    >
      <div
        ref={dialogRef}
        className={size === 'lg' ? 'wms-dialog wms-dialog--lg' : 'wms-dialog'}
        role="dialog"
        aria-modal="true"
        aria-label={typeof title === 'string' ? title : undefined}
      >
        <div className="wms-dialog__head">
          <div style={{ flex: 1, minWidth: 0 }}>
            {title ? <div className="wms-dialog__title">{title}</div> : null}
            {subtitle ? <div className="wms-dialog__sub">{subtitle}</div> : null}
          </div>
          {onClose ? (
            <button type="button" className="wms-iconbtn" onClick={onClose} aria-label="Bağla">
              {Icons.close(16)}
            </button>
          ) : null}
        </div>
        <div className="wms-dialog__body">{children}</div>
        {footer ? <div className="wms-dialog__foot">{footer}</div> : null}
      </div>
    </div>
  );
}
