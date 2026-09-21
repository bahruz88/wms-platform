import type { ReactNode } from 'react';

/**
 * Button — docs/design-system/components/Button/README.md.
 *
 * `loading` keeps the button's width (the label stays in the flow, hidden from the accessibility
 * tree, with the spinner overlaid) so the row does not jump; it also sets `disabled` and
 * `aria-busy`, which is the interface half of the double-POST guard `Idempotency-Key` enforces
 * on the server.
 *
 * A disabled button must say why: `title` is required whenever `disabled` is set without
 * `loading`. In development a missing reason is reported on the console rather than silently
 * shipped ("Səbəbsiz deaktiv düymə buraxma").
 */
export interface ButtonProps {
  /** Only one `primary` per screen. `danger` only for an irreversible operation. */
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  size?: 'md' | 'sm';
  disabled?: boolean;
  /** Keeps the button width; the spinner replaces the label in place. */
  loading?: boolean;
  iconLeft?: ReactNode;
  type?: 'button' | 'submit' | 'reset';
  title?: string;
  className?: string;
  onClick?: (e: unknown) => void;
  children?: ReactNode;
}

export function Button({
  variant = 'secondary',
  size = 'md',
  disabled = false,
  loading = false,
  iconLeft,
  type = 'button',
  title,
  className,
  onClick,
  children,
}: ButtonProps) {
  const isDisabled = disabled || loading;

  if (import.meta.env?.DEV && disabled && !loading && !title) {
    console.warn(
      '[wms] Button: a disabled button needs a reason in `title` — see components/Button/README.md.',
    );
  }

  const classes = ['wms-btn', `wms-btn--${variant}`];
  if (size === 'sm') classes.push('wms-btn--sm');
  if (className) classes.push(className);

  return (
    <button
      type={type}
      className={classes.join(' ')}
      disabled={isDisabled}
      aria-busy={loading || undefined}
      title={title}
      onClick={onClick}
    >
      {loading ? (
        <span
          style={{ position: 'relative', display: 'inline-flex', alignItems: 'center', gap: 4 }}
        >
          {/* The label stays laid out so the button keeps its width, but is hidden visually. */}
          <span aria-hidden="true" style={{ visibility: 'hidden', display: 'inline-flex', gap: 4 }}>
            {iconLeft}
            {children}
          </span>
          <span
            style={{
              position: 'absolute',
              inset: 0,
              display: 'grid',
              placeItems: 'center',
            }}
          >
            <span className="wms-spinner" data-testid="wms-spinner" />
          </span>
        </span>
      ) : (
        <>
          {iconLeft}
          {children}
        </>
      )}
    </button>
  );
}
