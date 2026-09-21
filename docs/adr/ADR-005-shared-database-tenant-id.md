# ADR-005: Shared database + `tenant_id`

**Status:** Qəbul edilib
**Mənbə:** [SPEC §2 → ADR-005](../SPEC-Satinalma-Anbar-Platformasi.md#adr-005-shared-database--tenant_id), icra qaydası [§12.9](../SPEC-Satinalma-Anbar-Platformasi.md#129-tenant-izolyasiyası)

## Kontekst

Məhsul multi-tenant SaaS-dır: Subway ilk müştəridir, platforma başqa şəbəkələrə də
satılacaq. Tenant izolyasiyasının üç variantı var — database-per-tenant,
schema-per-tenant, shared schema + `tenant_id`. İlk ikisi hər miqrasiyanı N dəfə
icra etməyi və N backup dəstini idarə etməyi tələb edir.

## Qərar

Bütün tenant-lar eyni database və eyni cədvəllərdə, **`tenant_id` sütunu ilə** yaşayır.
EF Core global query filter bütün `ITenantEntity` üçün avtomatik tətbiq olunur;
`TenantId` **yalnız** JWT `tenant_id` claim-indən gəlir, heç vaxt request body/query-dən.
On-prem müştəri eyni build-in tək-tenant konfiqurasiyasıdır.

## Nəticələr

- **Hər unikal indeksin birinci sütunu `tenant_id` olmalıdır** (SPEC §6.5) — arxitektura testi
  bunu yoxlayır. Bu qaydanın pozulması iki tenant arasında kod toqquşması deməkdir.
- Raw SQL (Dapper hesabatları) üçün `tenant_id` parametri məcburidir; testlə yoxlanılır.
- `IgnoreQueryFilters()` yalnız `[AllowCrossTenant]` atributlu admin əməliyyatlarında.
- Miqrasiya bir dəfə icra olunur, backup bir dəstdir — operativ yük minimaldır.
- Qarşılığında: izolyasiya **kod səviyyəsindədir**, fiziki deyil. Query filter-in bir yerdə
  unudulması data sızmasıdır; buna görə filter refleksiya ilə **avtomatik** tətbiq olunur,
  əl ilə deyil. Böyük müştəri fiziki ayrılıq tələb edərsə, həll yolu ayrıca instansdır
  (eyni image, ayrı database), schema-per-tenant deyil.
