import type { ReactNode } from 'react';

/** The shared tone scale (index.d.ts). `virtual` is only for virtual location types. */
export type Tone = 'neutral' | 'accent' | 'success' | 'warning' | 'danger' | 'virtual';

/**
 * Badge — docs/design-system/components/Badge/README.md.
 *
 * Text is mandatory: colour alone carries no meaning, so a badge with a `dot` but no children is
 * refused. Document status never goes through this component — use `DocStatusBadge`.
 */
export interface BadgeProps {
  tone?: Tone;
  variant?: 'soft' | 'solid' | 'outline';
  /** A small dot beside the text; it accompanies the word, it does not replace it. */
  dot?: boolean;
  icon?: ReactNode;
  title?: string;
  className?: string;
  children?: ReactNode;
}

export function Badge({
  tone = 'neutral',
  variant = 'soft',
  dot = false,
  icon,
  title,
  className,
  children,
}: BadgeProps) {
  if (import.meta.env?.DEV && (children === undefined || children === null || children === '')) {
    console.warn('[wms] Badge: text is mandatory — colour alone carries no meaning.');
  }

  const classes = ['wms-badge', `wms-badge--${tone}`];
  if (variant !== 'soft') classes.push(`wms-badge--${variant}`);
  if (className) classes.push(className);

  return (
    <span className={classes.join(' ')} title={title}>
      {dot ? <span className="wms-badge__dot" aria-hidden="true" /> : null}
      {icon}
      {children}
    </span>
  );
}
