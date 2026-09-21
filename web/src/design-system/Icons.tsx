import type { JSX } from 'react';

/**
 * The bundle's inline icon set: outlined, 1.5px stroke, 16px grid, `stroke="currentColor"` so the
 * glyph inherits the text colour (docs/design-system/README.md, "İkonoqrafiya").
 *
 * Icons are decorative here — every component that uses one also prints a word, so they carry
 * `aria-hidden`. An icon that stands alone for an action needs its own `aria-label` at the
 * call site.
 */

type IconFactory = (size?: number) => JSX.Element;

function svg(size: number, children: JSX.Element): JSX.Element {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.5}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
    >
      {children}
    </svg>
  );
}

export const Icons: Record<
  'chevron' | 'close' | 'check' | 'warn' | 'info' | 'clock' | 'arrow',
  IconFactory
> = {
  chevron: (size = 16) => svg(size, <path d="M4 6l4 4 4-4" />),
  close: (size = 16) => svg(size, <path d="M4 4l8 8M12 4l-8 8" />),
  check: (size = 16) => svg(size, <path d="M3 8.5l3.5 3.5L13 5" />),
  warn: (size = 16) => (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.5}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
    >
      <path d="M8 1.75L15 14H1L8 1.75z" />
      <path d="M8 6v3.5" />
      <path d="M8 11.75h.01" />
    </svg>
  ),
  info: (size = 16) => (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.5}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
    >
      <circle cx="8" cy="8" r="6.25" />
      <path d="M8 7.25v4" />
      <path d="M8 4.75h.01" />
    </svg>
  ),
  clock: (size = 16) => (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      stroke="currentColor"
      strokeWidth={1.5}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      focusable="false"
    >
      <circle cx="8" cy="8" r="6.25" />
      <path d="M8 4.5V8l2.5 1.5" />
    </svg>
  ),
  arrow: (size = 16) => svg(size, <path d="M3 8h10M9 4l4 4-4 4" />),
};

export type IconName = keyof typeof Icons;
