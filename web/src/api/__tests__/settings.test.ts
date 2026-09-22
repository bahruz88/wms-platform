import { describe, expect, it } from 'vitest';
import * as settings from '../settings';
import { exceeds } from '@features/inventory/CountDetailScreen';
import { rejectReason, contentTypeOf } from '@/components/AttachmentsCard';

/**
 * TOR §36: no expiry window, tolerance percentage, costing method or count threshold is
 * hard-coded in the interface.
 *
 * The module used to hold a `SETTING_FALLBACKS` table so the screens had something to show
 * while `GET /inventory/settings` answered 404. The endpoint serves, and the table is gone —
 * this test is what keeps it gone. An unread threshold now reads as unknown, and a screen that
 * gets `null` draws no badge and counts no line, rather than judging against a number nobody
 * configured.
 */
describe('inventory settings module', () => {
  it('exports the keys the interface reads and no values for them', () => {
    expect(settings.SETTING_KEYS).toContain('expiry_warning_days');
    expect(settings.SETTING_KEYS).toContain('count_variance_approval_threshold_pct');
    expect(Object.keys(settings)).not.toContain('SETTING_FALLBACKS');
  });

  it('names the endpoint and says no default is substituted', () => {
    const note = settings.settingsUnavailableNote(503);
    expect(note).toContain('GET /inventory/settings');
    expect(note).toContain('503');
    expect(note).toContain('standart dəyər işlətmir');
  });

  it('separates «the call failed» from «the tenant has no rows»', () => {
    // A 200 with an empty list is not an outage; saying it is would send an administrator
    // chasing the gateway instead of the tenant`s own configuration.
    //
    // Changed 22.09.2026: the note used to read "GET /inventory/settings boş cavab qaytardı —
    // tenant üçün `inv_setting` sətri yazılmayıb". A route and a table name are not something an
    // administrator can act on; the distinction the test guards is kept, the plumbing is not.
    const empty = settings.settingsUnavailableNote(null);
    expect(empty).toContain('təyin edilməyib');
    expect(empty).not.toContain('cavab vermədi');
    expect(empty).not.toMatch(/\b(GET|POST)\s+\/|inv_setting/);
  });
});

describe('variance threshold', () => {
  it('marks a line over the tenant threshold', () => {
    expect(exceeds('3.5', 2)).toBe(true);
    expect(exceeds('-3.5', 2)).toBe(true);
    expect(exceeds('1.5', 2)).toBe(false);
  });

  it('passes no verdict at all when the tenant threshold could not be read', () => {
    // The old behaviour compared against a hard-coded 2 and reported lines as "over the
    // threshold" that no tenant had ever configured a threshold for.
    expect(exceeds('99', null)).toBe(false);
  });
});

/**
 * `POST /documents/attachments/presign` serves, so the upload flow is real. The contract closes
 * the content types and caps the object at 25 MB; both are checked before a presign is asked
 * for, so a refusal is immediate and names the file rather than arriving as a 400 later.
 */
describe('attachment guards', () => {
  it('maps the extensions the contract allows', () => {
    expect(contentTypeOf('qaimə.pdf')).toBe('application/pdf');
    expect(contentTypeOf('foto.JPG')).toBe('image/jpeg');
    expect(contentTypeOf('hesabat.xlsx')).toBe(
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    expect(contentTypeOf('arxiv.zip')).toBeNull();
  });

  it('refuses a type the contract does not list, by name', () => {
    expect(rejectReason({ name: 'arxiv.zip', size: 100 })).toContain('arxiv.zip');
  });

  it('refuses anything over the 25 MB the contract caps at', () => {
    expect(rejectReason({ name: 'böyük.pdf', size: 26_214_401 })).toContain('25 MB');
    expect(rejectReason({ name: 'tam.pdf', size: 26_214_400 })).toBeNull();
  });

  it('refuses an empty file rather than presigning for zero bytes', () => {
    expect(rejectReason({ name: 'boş.pdf', size: 0 })).toContain('boşdur');
  });
});
