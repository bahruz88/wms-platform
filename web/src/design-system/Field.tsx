import { useId, type ReactNode } from 'react';

/**
 * Field — the label / hint / error frame every control sits in.
 * `error` hides `hint`: the two are never shown together (components/TextField/README.md).
 * The required marker comes from `required`, never typed into the label by hand.
 */
export interface FieldProps {
  label?: ReactNode;
  htmlFor?: string;
  required?: boolean;
  hint?: ReactNode;
  /** When set, `hint` is hidden and the control border turns `danger`. */
  error?: ReactNode;
  children?: ReactNode;
}

export interface FieldFrameProps extends FieldProps {
  /** Ids the control should point at with aria-describedby. */
  describedById?: string;
  className?: string;
}

export function Field({
  label,
  htmlFor,
  required,
  hint,
  error,
  describedById,
  className,
  children,
}: FieldFrameProps) {
  const generatedId = useId();
  const describeId = describedById ?? `${generatedId}-desc`;
  const classes = ['wms-field'];
  if (error) classes.push('wms-field--error');
  if (className) classes.push(className);

  return (
    <div className={classes.join(' ')}>
      {label ? (
        <label className="wms-field__label" htmlFor={htmlFor}>
          {label}
          {required ? (
            <span className="wms-field__req" aria-hidden="true">
              *
            </span>
          ) : null}
        </label>
      ) : null}
      {children}
      {error ? (
        <div className="wms-field__error" id={describeId} role="alert">
          {error}
        </div>
      ) : hint ? (
        <div className="wms-field__hint" id={describeId}>
          {hint}
        </div>
      ) : null}
    </div>
  );
}
