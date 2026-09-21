# Wms.Reporting.Domain

Şema prefiksi: `rpt_`. Başqa moduldan asılılığı yoxdur — read-model integration event-lərdən qurulur (SPEC §5).

## Sahib olduğu cədvəllər

| Entity | Cədvəl | Qeyd |
|---|---|---|
| `StockSnapshot` | `rpt_stock_snapshot` | gün sonu qalıq və dəyər proyeksiyası (`ReportingProjector` job, SPEC §15) |
| `ReportDefinition` | `rpt_report_definition` | TOR §29-dakı 24 hesabatın kataloqu, Excel export üçün async endpoint |

Hesabat sorğuları EF Core ilə deyil, **Dapper** ilə yazılır (SPEC §3); `tenant_id` parametri hər raw SQL-də
məcburidir və arxitektura testi ilə yoxlanılır (SPEC §12.9).
