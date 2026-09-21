import { describe, expect, it } from 'vitest';
import { guessMapping, parseCsv } from '../SalesImportCsvScreen';

/**
 * The CSV is parsed in the browser before anything is uploaded, so the user can map the columns
 * and see which POS codes will arrive unmapped.
 */
describe('parseCsv', () => {
  it('reads a comma-separated file with a header row', () => {
    const { headers, rows } = parseCsv('PLU,Qty,Amount\nPLU-1001,42,504.00\nPLU-2002,5,15.00\n');
    expect(headers).toEqual(['PLU', 'Qty', 'Amount']);
    expect(rows).toEqual([
      ['PLU-1001', '42', '504.00'],
      ['PLU-2002', '5', '15.00'],
    ]);
  });

  it('detects a semicolon separator, as Excel writes in many locales', () => {
    const { headers, rows } = parseCsv('PLU;Qty;Amount\nPLU-1001;42;504,00\n');
    expect(headers).toEqual(['PLU', 'Qty', 'Amount']);
    expect(rows[0]).toEqual(['PLU-1001', '42', '504,00']);
  });

  it('honours quoted fields containing the separator', () => {
    const { rows } = parseCsv('PLU,Name\nPLU-1001,"Italian BMT, 15 sm"\n');
    expect(rows[0]).toEqual(['PLU-1001', 'Italian BMT, 15 sm']);
  });

  it('unescapes doubled quotes', () => {
    const { rows } = parseCsv('PLU,Name\nPLU-1,"He said ""yes"""\n');
    expect(rows[0]?.[1]).toBe('He said "yes"');
  });

  it('strips the BOM Excel writes', () => {
    const { headers } = parseCsv('﻿PLU,Qty\nPLU-1,1\n');
    expect(headers[0]).toBe('PLU');
  });

  it('handles CRLF line endings and drops blank lines', () => {
    const { rows } = parseCsv('PLU,Qty\r\nPLU-1,1\r\n\r\nPLU-2,2\r\n');
    expect(rows).toEqual([
      ['PLU-1', '1'],
      ['PLU-2', '2'],
    ]);
  });

  it('returns an empty result for an empty file', () => {
    expect(parseCsv('')).toEqual({ headers: [], rows: [] });
  });
});

describe('guessMapping', () => {
  it('recognises the common English header spellings', () => {
    expect(guessMapping(['PLU', 'Qty', 'Amount'])).toEqual({
      posCode: 'PLU',
      qtySold: 'Qty',
      grossAmount: 'Amount',
    });
  });

  it('recognises Azerbaijani headers', () => {
    expect(guessMapping(['POS kodu', 'Miqdar', 'Məbləğ'])).toEqual({
      posCode: 'POS kodu',
      qtySold: 'Miqdar',
      grossAmount: 'Məbləğ',
    });
  });

  it('leaves a field unmapped when nothing matches, so the user must choose', () => {
    expect(guessMapping(['A', 'B'])).toEqual({ posCode: '', qtySold: '', grossAmount: '' });
  });
});
