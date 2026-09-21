# ADR-010: Tək MySQL database + cədvəl prefiksi (schema-per-module əvəzinə)

**Status:** Qəbul edilib
**Əlaqəli:** [SPEC §5](../SPEC-Satinalma-Anbar-Platformasi.md#5-modul-sərhədləri), [SPEC §6](../SPEC-Satinalma-Anbar-Platformasi.md#6-data-modeli--ümumi-qaydalar), [CONVENTIONS → Modullar](../CONVENTIONS.md), [ADR-001](ADR-001-modular-monolith-per-module-deployment.md)

## Kontekst

Spesifikasiya modul başına "şema" tələb edir: `iam`, `master`, `inv`, `proc`, `doc`, `notif`,
`rpt`, `intg`. PostgreSQL-də bu birbaşa `CREATE SCHEMA`-dır. **MySQL-də isə "schema" = "database"** —
ayrı şema ayrı database deməkdir. Bu, bir neçə praktik nəticə doğurur:

- `CREATE DATABASE` başına ayrı istifadəçi hüquqları, ayrı backup/restore mülahizəsi;
- EF Core Pomelo provayderində bir `DbContext` bir database ilə işləyir — cross-database
  sorğu və miqrasiya idarəetməsi əl işi tələb edir;
- on-prem müştəridə (tək konteyner, tək MySQL) səkkiz database qurmaq və restore etmək
  sadə əməliyyat deyil;
- Testcontainers ilə integration testlərdə hər test üçün səkkiz database yaratmaq lazım gəlir.

## Qərar

**Tək database `wms` + cədvəl adı prefiksi.** Hər modul öz prefiksini alır:

| Modul | Prefiks | Modul | Prefiks |
|---|---|---|---|
| Identity | `iam_` | Documents | `doc_` |
| MasterData | `master_` | Notification | `notif_` |
| Inventory | `inv_` | Reporting | `rpt_` |
| Procurement | `proc_` | Integration | `intg_` |

Ortaq cədvəllər prefiksiz-ortaq adla: `common_outbox`, `common_audit_log`, `common_attachment`.

Məntiqi sərhəd **kodla** qorunur, DB ilə deyil:

- Modul başına ayrıca `DbContext` və ayrıca `Migrations/` qovluğu (SPEC §18.3);
- Şemalararası `FOREIGN KEY` **yoxdur** (`inv_movement.product_id` → `master_product.id`
  FK deyil, sadəcə sütundur);
- Şemalararası `JOIN` **yoxdur** (yeganə istisna — Reporting read-model-i);
- Bir modul başqasının `DbContext`-inə müraciət edə bilməz — `Wms.ArchitectureTests` yoxlayır.

## Nəticələr

- Bir connection string, bir miqrasiya işi (`wms-migrator`), bir backup dəsti, bir restore proseduru.
- Testcontainers-də bir database qalxır; integration testlər sürətlidir.
- DB istifadəçi hüquqları cədvəl səviyyəsində verilə bilir: `inv_movement` və `common_audit_log`
  üçün tətbiq istifadəçisinə yalnız `SELECT, INSERT` (SPEC §9.4, §16) — bu, schema-per-module
  olmadan da mümkündür və `deploy/mysql/post-migrate/ledger-grants.sql`-də tətbiq olunur.
- Prefiks adlandırma qaydası **məcburidir**: prefikssiz cədvəl adı review-də rədd edilir,
  çünki modul sahibliyi yalnız addan görünür.
- Qarşılığında: DB səviyyəsində modul izolyasiyası **yoxdur** — səhvən yazılmış cross-module
  `JOIN` işləyəcək. Yeganə qoruyucu arxitektura testi və review-dir; buna görə həmin testlər
  CI-da məcburidir.
- PostgreSQL-ə keçid (gələcək ehtimal) halında prefikslər həqiqi şemalara çevrilə bilər:
  `inv_movement` → `inv.movement`. Miqrasiya yolu açıq qalır.
