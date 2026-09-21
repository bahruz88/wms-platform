import { useState } from 'react';
import { useMutation } from '@tanstack/react-query';
import { Alert, Badge, Button, DataTable, Dialog, Select, TextField, type Column } from '@ds/index';
import { useApiPage, useApiQuery } from '@api/hooks';
import {
  createExport,
  getReportDefinition,
  listReports,
  type ReportDefinitionSummary,
} from '@api/endpoints';
import { useAuth } from '@auth/index';
import { ErrorState, LoadingState, Page, Section } from '@/components/Page';

/**
 * Report catalogue and async export — docs/ux/screen-map.md §5.2.
 *
 * The parameter form is built from `ReportDefinition.parameters` at runtime, not hard-coded: each
 * report declares its own parameters, types and allowed values. A report with
 * `requiresCostPermission` is not shown at all to a user without `master.product.view_cost` — the
 * server leaves it out of the catalogue and the interface repeats that.
 *
 * Export is asynchronous: `POST /exports` returns `QUEUED`, and the job is followed on the exports
 * screen (or through an `ExportReady` notification).
 */
export function ReportsScreen() {
  const { can } = useAuth();
  const [selected, setSelected] = useState<string | null>(null);
  const [params, setParams] = useState<Record<string, string>>({});
  const [format, setFormat] = useState<'XLSX' | 'PDF' | 'CSV'>('XLSX');

  const reports = useApiPage<ReportDefinitionSummary>(['reports'], () => listReports(), 100);

  const definition = useApiQuery(
    ['report-definition', selected],
    () => getReportDefinition(selected as string),
    { enabled: selected !== null },
  );

  const exportJob = useMutation({
    mutationFn: () =>
      createExport({
        reportCode: selected as string,
        format,
        parameters: params,
      }),
  });

  const columns: Column<ReportDefinitionSummary>[] = [
    {
      key: 'code',
      header: 'Kod',
      width: '180px',
      render: (row) => <span className="wms-doc-no">{row.code}</span>,
    },
    { key: 'name', header: 'Ad' },
    {
      key: 'category',
      header: 'Kateqoriya',
      render: (row) => <Badge tone="neutral">{row.category}</Badge>,
    },
    { key: 'description', header: 'İzah', render: (row) => row.description ?? '—' },
    { key: 'torRef', header: 'TOR', render: (row) => row.torRef ?? '—' },
    {
      key: 'requiresCostPermission',
      header: 'Maya dəyəri',
      render: (row) =>
        row.requiresCostPermission ? (
          <Badge tone="warning" title="master.product.view_cost tələb olunur">
            İcazəyə bağlı
          </Badge>
        ) : (
          <span className="wms-muted">—</span>
        ),
    },
    {
      key: 'actions',
      header: '',
      width: '120px',
      render: (row) => (
        <Button
          size="sm"
          disabled={!can('rpt.export.create')}
          title={!can('rpt.export.create') ? '`rpt.export.create` icazəniz yoxdur' : undefined}
          onClick={() => {
            setSelected(row.code);
            setParams({});
            exportJob.reset();
          }}
        >
          Aç
        </Button>
      ),
    },
  ];

  const parameters = definition.data?.parameters ?? [];

  return (
    <Page title="Hesabat kataloqu" subtitle="Parametr forması hər hesabatın öz tərifindən qurulur">
      <Section>
        {reports.isLoading ? (
          <LoadingState />
        ) : reports.isError ? (
          <ErrorState error={reports.error} onRetry={() => void reports.refetch()} />
        ) : (
          <DataTable<ReportDefinitionSummary>
            columns={columns}
            rows={reports.data?.items ?? []}
            rowKey={(row) => row.code}
            label="Hesabat kataloqu"
            empty="Hesabat tərifi yoxdur. Reporting modulu hesabatları quraşdırdıqda burada görünəcək."
          />
        )}
      </Section>

      <Dialog
        open={selected !== null}
        size="lg"
        title={definition.data?.name ?? selected ?? ''}
        subtitle={definition.data?.description ?? 'Parametrləri doldurun və export sifariş edin.'}
        onClose={exportJob.isPending ? undefined : () => setSelected(null)}
        footer={
          <>
            <Button
              disabled={exportJob.isPending}
              title={exportJob.isPending ? 'Sorğu göndərilir' : undefined}
              onClick={() => setSelected(null)}
            >
              İmtina
            </Button>
            <Button
              variant="primary"
              loading={exportJob.isPending}
              disabled={parameters.some((p) => p.required && !params[p.name])}
              title={
                parameters.some((p) => p.required && !params[p.name])
                  ? 'Məcburi parametrləri doldurun'
                  : undefined
              }
              onClick={() => exportJob.mutate()}
            >
              Excel-ə çıxar
            </Button>
          </>
        }
      >
        <div className="wms-stack">
          {definition.isLoading ? <LoadingState /> : null}
          {definition.isError ? <ErrorState error={definition.error} /> : null}
          {exportJob.isError ? <ErrorState error={exportJob.error} /> : null}
          {exportJob.isSuccess ? (
            <Alert tone="success" title="Export növbəyə alındı">
              Sifariş <span className="wms-num">#{exportJob.data?.id}</span> yaradıldı. Hazır
              olduqda «Exportlar» ekranından yükləyin.
            </Alert>
          ) : null}

          {parameters.length > 0 ? (
            <div className="wms-grid wms-grid--form">
              {parameters.map((parameter) =>
                parameter.type === 'ENUM' && parameter.allowedValues ? (
                  <Select
                    key={parameter.name}
                    label={parameter.label}
                    required={parameter.required}
                    value={params[parameter.name] ?? ''}
                    placeholder="Seçin"
                    options={parameter.allowedValues.map((v) => ({
                      value: v.value,
                      label: v.label,
                    }))}
                    onChange={(e) =>
                      setParams((prev) => ({ ...prev, [parameter.name]: e.target.value }))
                    }
                  />
                ) : (
                  <TextField
                    key={parameter.name}
                    label={parameter.label}
                    required={parameter.required}
                    type={
                      parameter.type === 'DATE' || parameter.type === 'DATE_RANGE'
                        ? 'date'
                        : parameter.type === 'INT' || parameter.type === 'DECIMAL'
                          ? 'text'
                          : 'text'
                    }
                    mono={parameter.type === 'INT' || parameter.type === 'DECIMAL'}
                    value={params[parameter.name] ?? ''}
                    hint={`Tip: ${parameter.type}`}
                    onChange={(e) =>
                      setParams((prev) => ({ ...prev, [parameter.name]: e.target.value }))
                    }
                  />
                ),
              )}
            </div>
          ) : definition.data ? (
            <Alert tone="info" title="Bu hesabat parametr tələb etmir">
              Birbaşa export sifariş edə bilərsiniz.
            </Alert>
          ) : null}

          <Select
            label="Format"
            value={format}
            options={(definition.data?.supportedFormats ?? ['XLSX', 'PDF', 'CSV']).map((f) => ({
              value: f,
              label: f,
            }))}
            onChange={(e) => setFormat(e.target.value as typeof format)}
          />
        </div>
      </Dialog>
    </Page>
  );
}
