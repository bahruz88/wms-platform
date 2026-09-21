import { describe, expect, it } from 'vitest';
import { ApiError, ERROR_CODES, isApiError, networkProblem, toProblemDetails } from '../problem';

/** SPEC §13.3 — RFC 7807 with the WMS `code` extension. */
describe('toProblemDetails', () => {
  it('copies a full problem+json body through unchanged', () => {
    const body = {
      type: 'https://wms/errors/insufficient-stock',
      title: 'Kifayət qədər stok yoxdur',
      status: 409,
      code: 'INSUFFICIENT_STOCK',
      detail: 'Chicken Strips: mövcud 45.0000 KG, tələb olunan 60.0000 KG',
      traceId: '00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01',
      errors: { 'lines[2].qty': ['Mövcud qalıqdan çoxdur'] },
    };
    const problem = toProblemDetails(body, 409, 'fallback');
    expect(problem).toEqual(body);
  });

  it('derives the type URI when the server omits it', () => {
    const problem = toProblemDetails(
      { title: 'X', code: 'LOCATION_FROZEN', status: 409 },
      409,
      'f',
    );
    expect(problem.type).toBe('https://wms/errors/location-frozen');
  });

  it('gives a stock ValidationProblemDetails a code so the Alert can show one', () => {
    const problem = toProblemDetails(
      {
        title: 'One or more validation errors occurred.',
        status: 400,
        errors: { name: ['Required'] },
      },
      400,
      'f',
    );
    expect(problem.code).toBe('VALIDATION_FAILED');
    expect(problem.errors?.name).toEqual(['Required']);
  });

  it('maps bare HTTP statuses to a usable code', () => {
    expect(toProblemDetails(null, 403, 'f').code).toBe('FORBIDDEN');
    expect(toProblemDetails(null, 404, 'f').code).toBe('NOT_FOUND');
    expect(toProblemDetails(null, 409, 'f').code).toBe('INVALID_STATE_TRANSITION');
    expect(toProblemDetails(null, 429, 'f').code).toBe('RATE_LIMITED');
  });

  it('survives an HTML error page from the gateway', () => {
    const problem = toProblemDetails('<html>502 Bad Gateway</html>', 502, 'Server cavab vermir');
    expect(problem.title).toBe('Server cavab vermir');
    expect(problem.detail).toContain('502');
    expect(problem.code).toBeTruthy();
  });

  it('records the request path as the instance', () => {
    expect(toProblemDetails(null, 404, 'f', '/inventory/balances').instance).toBe(
      '/inventory/balances',
    );
  });

  it('knows the shared error codes from common.v1.yaml', () => {
    expect(ERROR_CODES).toContain('SELECTION_NOTE_REQUIRED');
    expect(ERROR_CODES).toContain('VARIANCE_NOTE_REQUIRED');
    expect(ERROR_CODES).toContain('REASON_CODE_REQUIRED');
    expect(ERROR_CODES).toContain('STALE_VERSION');
  });
});

describe('ApiError', () => {
  it('exposes status, code and field errors for the form layer', () => {
    const error = new ApiError(
      toProblemDetails(
        {
          title: 'Doğrulama uğursuz oldu',
          status: 422,
          code: 'VARIANCE_NOTE_REQUIRED',
          errors: { 'lines[0].varianceNote': ['Məcburidir'] },
        },
        422,
        'f',
      ),
    );
    expect(error.status).toBe(422);
    expect(error.code).toBe('VARIANCE_NOTE_REQUIRED');
    expect(error.is('VARIANCE_NOTE_REQUIRED')).toBe(true);
    expect(error.fieldErrors('lines[0].varianceNote')).toEqual(['Məcburidir']);
    expect(error.fieldErrors('nope')).toEqual([]);
    expect(isApiError(error)).toBe(true);
  });

  it('uses detail as the message so a thrown error reads usefully', () => {
    const error = new ApiError(
      toProblemDetails({ title: 'T', code: 'X', status: 400, detail: 'D' }, 400, 'f'),
    );
    expect(error.message).toBe('D');
  });
});

describe('networkProblem', () => {
  it('turns a transport failure into a problem with a code', () => {
    const problem = networkProblem(new TypeError('Failed to fetch'), '/balances');
    expect(problem.status).toBe(0);
    expect(problem.code).toBe('NETWORK_UNAVAILABLE');
    expect(problem.detail).toContain('Failed to fetch');
  });
});
