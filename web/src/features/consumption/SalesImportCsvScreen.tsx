import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Select, TextField, type Column } from '@ds/index';
import { useApiPage } from '@api/hooks';
import { listLocations, listMenuItems, type Location, type MenuItem } from '@api/endpoints';
import { API_BASE_URL, newIdempotencyKey } from '@api/client';
import { toProblemDetails, ApiError } from '@api/problem';
import { userManager } from '@auth/index';
import { ErrorState, Page, Section } from '@/components/Page';

/**
 * CSV sales import with column mapping — `POST /sales-imports/upload-csv`.
 *
 * The file is parsed in the browser first so the user can map the columns before anything is sent:
 * the server's `columnMapping` expects `{"posCode": "<header>", "qtySold": "<header>", ...}` and a
 * wrong guess would produce a whole import of unmapped rows. The preview also shows, ahead of the
 * upload, which POS codes match no menu item — the problem that costs the most to discover later.
 *
 * The request is `multipart/form-data`, so it goes through `fetch` directly rather than through
 * `openapi-fetch`'s JSON body serialiser; the bearer token, the `Idempotency-Key` and the
 * problem+json parsing are applied by hand here, exactly as the middleware would.
 */

const FIELDS = [
  { key: 'posCode', label: 'POS kodu', required: true },
  { key: 'qtySold', label: 'Satılan miqdar', required: true },
  { key: 'grossAmount', label: 'Brüt məbləğ', required: false },
] as const;

type FieldKey = (typeof FIELDS)[number]['key'];

interface ParsedCsv {
  headers: string[];
  rows: string[][];
}

/** Minimal RFC 4180 reader: quoted fields, doubled quotes, `,` or `;` separators. */
export function parseCsv(text: string): ParsedCsv {
  const clean = text.replace(/^\uFEFF/, ''); // strip the BOM Excel writes
  const firstLine = clean.split(/\r?\n/, 1)[0] ?? '';
  const separator =
    (firstLine.match(/;/g)?.length ?? 0) > (firstLine.match(/,/g)?.length ?? 0) ? ';' : ',';

  const rows: string[][] = [];
  let row: string[] = [];
  let field = '';
  let quoted = false;

  for (let i = 0; i < clean.length; i += 1) {
    const char = clean[i] as string;
    if (quoted) {
      if (char === '"') {
        if (clean[i + 1] === '"') {
          field += '"';
          i += 1;
        } else quoted = false;
      } else field += char;
      continue;
    }
    if (char === '"') quoted = true;
    else if (char === separator) {
      row.push(field.trim());
      field = '';
    } else if (char === '\n') {
      row.push(field.trim());
      rows.push(row);
      row = [];
      field = '';
    } else if (char !== '\r') field += char;
  }
  if (field !== '' || row.length > 0) {
    row.push(field.trim());
    rows.push(row);
  }

  const headers = rows.shift() ?? [];
  return { headers, rows: rows.filter((r) => r.some((c) => c !== '')) };
}

/** Guesses a mapping from common header spellings so the usual file needs no manual work. */
export function guessMapping(headers: string[]): Record<FieldKey, string> {
  const find = (candidates: string[]) =>
    headers.find((h) => candidates.some((c) => h.toLowerCase().includes(c))) ?? '';
  return {
    posCode: find(['plu', 'pos', 'kod', 'code', 'sku']),
    qtySold: find(['qty', 'miqdar', 'say', 'count', 'quantity']),
    grossAmount: find(['amount', 'məbləğ', 'mebleg', 'total', 'sum']),
  };
}

const today = () => new Date().toISOString().slice(0, 10);

export function SalesImportCsvScreen() {
  const navigate = useNavigate();
  const [fileName, setFileName] = useState('');
  const [file, setFile] = useState<File | null>(null);
  const [parsed, setParsed] = useState<ParsedCsv | null>(null);
  const [mapping, setMapping] = useState<Record<FieldKey, string>>({
    posCode: '',
    qtySold: '',
    grossAmount: '',
  });
  const [businessDate, setBusinessDate] = useState(today);
  const [locationId, setLocationId] = useState('');
  const [externalRef, setExternalRef] = useState('');

  const locations = useApiPage<Location>(['locations', 'csv'], () => listLocations({}), 200);
  const menuItems = useApiPage<MenuItem>(
    ['menu-items', 'csv'],
    () => listMenuItems({ page: 1, size: 200 }),
    200,
  );

  const knownPosCodes = useMemo(
    () => new Set((menuItems.data?.items ?? []).map((m) => m.posCode).filter(Boolean) as string[]),
    [menuItems.data],
  );

  async function onFile(input: File) {
    setFile(input);
    setFileName(input.name);
    const text = await input.text();
    const result = parseCsv(text);
    setParsed(result);
    setMapping(guessMapping(result.headers));
  }

  interface PreviewRow {
    index: number;
    posCode: string;
    qtySold: string;
    grossAmount: string;
    known: boolean;
  }

  const preview: PreviewRow[] = useMemo(() => {
    if (!parsed) return [];
    const col = (name: string) => parsed.headers.indexOf(name);
    const pos = col(mapping.posCode);
    const qty = col(mapping.qtySold);
    const gross = col(mapping.grossAmount);
    return parsed.rows.slice(0, 50).map((row, index) => {
      const posCode = pos >= 0 ? (row[pos] ?? '') : '';
      return {
        index,
        posCode,
        qtySold: qty >= 0 ? (row[qty] ?? '') : '',
        grossAmount: gross >= 0 ? (row[gross] ?? '') : '',
        known: knownPosCodes.has(posCode),
      };
    });
  }, [parsed, mapping, knownPosCodes]);

  const unmappedCodes = useMemo(
    () => [...new Set(preview.filter((r) => !r.known && r.posCode).map((r) => r.posCode))],
    [preview],
  );

  const mappingComplete = FIELDS.every((f) => !f.required || mapping[f.key]);
  const canUpload = Boolean(file && locationId && businessDate && mappingComplete);

  const upload = useMutation({
    mutationFn: async () => {
      const user = await userManager().getUser();
      const form = new FormData();
      form.append('file', file as File);
      form.append('businessDate', businessDate);
      form.append('locationId', locationId);
      form.append('columnMapping', JSON.stringify(mapping));
      if (externalRef) form.append('externalRef', externalRef);

      const response = await fetch(`${API_BASE_URL}/api/v1/consumption/sales-imports/upload-csv`, {
        method: 'POST',
        headers: {
          Authorization: user ? `Bearer ${user.access_token}` : '',
          'Idempotency-Key': newIdempotencyKey(),
          Accept: 'application/json, application/problem+json',
        },
        body: form,
      });

      if (!response.ok) {
        const contentType = response.headers.get('content-type') ?? '';
        const body = contentType.includes('json') ? await response.json() : await response.text();
        throw new ApiError(
          toProblemDetails(body, response.status, 'CSV yüklənmədi', '/sales-imports/upload-csv'),
        );
      }
      return (await response.json()) as { salesImport: { id: number }; parsedRows: number };
    },
    onSuccess: (result) => {
      navigate(`/consumption/sales-imports/${result.salesImport.id}`);
    },
  });

  const previewColumns: Column<PreviewRow>[] = [
    {
      key: 'index',
      header: '№',
      numeric: true,
      decimals: 0,
      width: '60px',
      render: (row) => row.index + 1,
    },
    {
      key: 'posCode',
      header: 'POS kodu',
      render: (row) => <span className="wms-doc-no">{row.posCode || '—'}</span>,
    },
    // The preview shows the file's own text, unreformatted: the server parses the numbers (it
    // accepts both `504.00` and `504,00`), and silently rewriting them here would hide a
    // mis-mapped column.
    {
      key: 'qtySold',
      header: 'Miqdar',
      align: 'right',
      render: (row) => <span className="wms-num">{row.qtySold || '—'}</span>,
    },
    {
      key: 'grossAmount',
      header: 'Məbləğ',
      align: 'right',
      render: (row) => <span className="wms-num">{row.grossAmount || '—'}</span>,
    },
    {
      key: 'known',
      header: 'Uyğunluq',
      render: (row) =>
        !row.posCode ? (
          <Badge tone="danger">Kod boşdur</Badge>
        ) : row.known ? (
          <Badge tone="success">Menyu maddəsi tapıldı</Badge>
        ) : (
          <Badge tone="warning">Bağlanmayıb</Badge>
        ),
    },
  ];

  return (
    <Page
      title="CSV satış importu"
      subtitle="Fayl → sütun xəritəsi → önizləmə → yükləmə"
      actions={
        <>
          <Button onClick={() => navigate('/consumption/sales-imports')}>Geri</Button>
          <Button
            variant="primary"
            loading={upload.isPending}
            disabled={!canUpload}
            title={
              !file
                ? 'CSV faylı seçin'
                : !locationId
                  ? 'Lokasiya seçin'
                  : !mappingComplete
                    ? 'Məcburi sütunları xəritələyin'
                    : undefined
            }
            onClick={() => upload.mutate()}
          >
            Yüklə
          </Button>
        </>
      }
    >
      {upload.isError ? <ErrorState error={upload.error} /> : null}

      <Section title="1. Fayl">
        <div className="wms-card">
          <div className="wms-grid wms-grid--form">
            <div className="wms-field">
              <span className="wms-field__label">CSV faylı</span>
              <input
                type="file"
                accept=".csv,text/csv"
                className="wms-input"
                onChange={(e) => {
                  const selected = e.target.files?.[0];
                  if (selected) void onFile(selected);
                }}
              />
              <span className="wms-field__hint">
                Maksimum 5 MB. UTF-8 və Windows-1254 dəstəklənir; ayırıcı avtomatik aşkarlanır.
              </span>
            </div>
            <TextField
              label="İş günü"
              type="date"
              required
              value={businessDate}
              onChange={(e) => setBusinessDate(e.target.value)}
            />
            <Select
              label="Lokasiya"
              required
              value={locationId}
              placeholder="Lokasiya seçin"
              options={(locations.data?.items ?? [])
                .filter((l) => !l.isVirtual)
                .map((l) => ({ value: String(l.id), label: `${l.name} (${l.code})` }))}
              onChange={(e) => setLocationId(e.target.value)}
            />
            <TextField
              label="Xarici istinad"
              value={externalRef}
              placeholder="POS-BATCH-77"
              hint="POS hesabatının öz nömrəsi — təkrar yükləməni tanımağa kömək edir."
              onChange={(e) => setExternalRef(e.target.value)}
            />
          </div>
          {fileName ? (
            <Alert tone="info" title={`Fayl oxundu: ${fileName}`}>
              {parsed
                ? `${parsed.headers.length} sütun, ${parsed.rows.length} sətir.`
                : 'Fayl parse edilir…'}
            </Alert>
          ) : null}
        </div>
      </Section>

      {parsed ? (
        <>
          <Section title="2. Sütun xəritəsi">
            <div className="wms-card">
              <div className="wms-grid wms-grid--form">
                {FIELDS.map((field) => (
                  <Select
                    key={field.key}
                    label={field.label}
                    required={field.required}
                    value={mapping[field.key]}
                    placeholder="Sütun seçin"
                    error={
                      field.required && !mapping[field.key]
                        ? 'Bu sütun məcburidir — xəritələnməsə import boş qalır.'
                        : undefined
                    }
                    options={parsed.headers.map((h) => ({ value: h, label: h }))}
                    onChange={(e) =>
                      setMapping((prev) => ({ ...prev, [field.key]: e.target.value }))
                    }
                  />
                ))}
              </div>
              <span className="wms-field__hint">
                Xəritə serverə <span className="wms-num">columnMapping</span> kimi göndərilir:{' '}
                <span className="wms-num">{JSON.stringify(mapping)}</span>
              </span>
            </div>
          </Section>

          <Section title="3. Önizləmə (ilk 50 sətir)">
            {unmappedCodes.length > 0 ? (
              <Alert
                tone="warning"
                title={`${unmappedCodes.length} POS kodu menyu maddəsinə bağlı deyil`}
              >
                Bu kodlar import edildikdən sonra <span className="wms-num">unmapped</span> qalacaq
                və onlardan istehlak yaranmayacaq:{' '}
                <span className="wms-num">{unmappedCodes.slice(0, 12).join(', ')}</span>
                {unmappedCodes.length > 12 ? ' …' : ''}
              </Alert>
            ) : null}
            <DataTable<PreviewRow>
              columns={previewColumns}
              rows={preview}
              rowKey={(row) => row.index}
              label="CSV önizləmə"
              empty="Faylda sətir tapılmadı. Ayırıcını və başlıq sətrini yoxlayın."
            />
          </Section>
        </>
      ) : null}
    </Page>
  );
}
