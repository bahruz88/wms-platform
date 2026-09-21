/**
 * RFC 7807 `application/problem+json` as the platform extends it (SPEC §13.3, common.v1.yaml).
 * The `code` field is what support works with, so it is never hidden or rewritten — the Alert
 * component prints it verbatim (design-system/components/Alert/README.md).
 */

/** The shared codes from common.v1.yaml#/components/schemas/ErrorCode. The list is open. */
export const ERROR_CODES = [
  'VALIDATION_FAILED',
  'NOT_FOUND',
  'FORBIDDEN',
  'UNAUTHORIZED',
  'INSUFFICIENT_STOCK',
  'LOCATION_FROZEN',
  'STALE_VERSION',
  'BATCH_BLOCKED',
  'FX_RATE_MISSING',
  'APPROVAL_REQUIRED',
  'IDEMPOTENT_REPLAY',
  'IDEMPOTENCY_KEY_MISSING',
  'INVALID_STATE_TRANSITION',
  'LEDGER_UNBALANCED',
  'NEGATIVE_STOCK',
  'SELECTION_NOTE_REQUIRED',
  'VARIANCE_NOTE_REQUIRED',
  'REASON_CODE_REQUIRED',
  'RATE_LIMITED',
] as const;

export type KnownErrorCode = (typeof ERROR_CODES)[number];
/** Modules may add their own codes, so the type stays open. */
export type ErrorCode = KnownErrorCode | (string & {});

export interface ProblemDetails {
  type: string;
  title: string;
  status: number;
  code: ErrorCode;
  detail?: string;
  instance?: string;
  traceId?: string;
  /** Field-level validation errors keyed by JSON path, e.g. `lines[2].qty`. */
  errors?: Record<string, string[]>;
}

/** Thrown by the typed client for every non-2xx response, including transport failures. */
export class ApiError extends Error {
  readonly problem: ProblemDetails;

  constructor(problem: ProblemDetails) {
    super(problem.detail ?? problem.title);
    this.name = 'ApiError';
    this.problem = problem;
  }

  get status(): number {
    return this.problem.status;
  }

  get code(): ErrorCode {
    return this.problem.code;
  }

  /** Messages for one field path, as the form layer needs them. */
  fieldErrors(path: string): string[] {
    return this.problem.errors?.[path] ?? [];
  }

  is(code: ErrorCode): boolean {
    return this.problem.code === code;
  }
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

/** Derives the `https://wms/errors/<kebab-code>` type URI when the server omitted it. */
function typeUriFor(code: string): string {
  return `https://wms/errors/${code.toLowerCase().replace(/_/g, '-')}`;
}

const STATUS_FALLBACK_CODE: Record<number, ErrorCode> = {
  400: 'VALIDATION_FAILED',
  401: 'UNAUTHORIZED',
  403: 'FORBIDDEN',
  404: 'NOT_FOUND',
  409: 'INVALID_STATE_TRANSITION',
  422: 'VALIDATION_FAILED',
  429: 'RATE_LIMITED',
};

/**
 * Turns any error body into a `ProblemDetails`. A gateway that answers with HTML, an empty body,
 * or a plain string still has to produce something the Alert can show a code for.
 */
export function toProblemDetails(
  body: unknown,
  status: number,
  fallbackTitle: string,
  instance?: string,
): ProblemDetails {
  if (isRecord(body) && typeof body.title === 'string' && typeof body.code === 'string') {
    return {
      type: typeof body.type === 'string' ? body.type : typeUriFor(body.code),
      title: body.title,
      status: typeof body.status === 'number' ? body.status : status,
      code: body.code,
      detail: typeof body.detail === 'string' ? body.detail : undefined,
      instance: typeof body.instance === 'string' ? body.instance : instance,
      traceId: typeof body.traceId === 'string' ? body.traceId : undefined,
      errors: isRecord(body.errors) ? (body.errors as Record<string, string[]>) : undefined,
    };
  }

  // ASP.NET Core's stock ValidationProblemDetails has no `code`; keep its title and errors.
  if (isRecord(body) && typeof body.title === 'string') {
    const code = STATUS_FALLBACK_CODE[status] ?? 'VALIDATION_FAILED';
    return {
      type: typeof body.type === 'string' ? body.type : typeUriFor(code),
      title: body.title,
      status: typeof body.status === 'number' ? body.status : status,
      code,
      detail: typeof body.detail === 'string' ? body.detail : undefined,
      instance: typeof body.instance === 'string' ? body.instance : instance,
      traceId: typeof body.traceId === 'string' ? body.traceId : undefined,
      errors: isRecord(body.errors) ? (body.errors as Record<string, string[]>) : undefined,
    };
  }

  const code = STATUS_FALLBACK_CODE[status] ?? 'VALIDATION_FAILED';
  return {
    type: typeUriFor(code),
    title: fallbackTitle,
    status,
    code,
    detail: typeof body === 'string' && body.trim() !== '' ? body.slice(0, 500) : undefined,
    instance,
  };
}

/** A transport failure (DNS, CORS, offline) still reaches the UI as a problem with a code. */
export function networkProblem(error: unknown, instance?: string): ProblemDetails {
  return {
    type: typeUriFor('NETWORK_UNAVAILABLE'),
    title: 'Server cavab vermir',
    status: 0,
    code: 'NETWORK_UNAVAILABLE',
    detail: error instanceof Error ? error.message : String(error),
    instance,
  };
}

export function isApiError(error: unknown): error is ApiError {
  return error instanceof ApiError;
}
