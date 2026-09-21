# Arxitektura qərarları (ADR)

Hər ADR bir qərarı, onun kontekstini və nəticələrini qeyd edir. Şablon:
**Status / Kontekst / Qərar / Nəticələr**.

ADR-001…005 spesifikasiyanın §2 bölməsində artıq qəbul edilmiş qərarların ayrıca
sənədləşdirilmiş formasıdır — mənbə mətn `docs/SPEC-Satinalma-Anbar-Platformasi.md` §2-dədir
və ziddiyyət olarsa SPEC üstündür. ADR-006…011 spesifikasiyadan sonra, frontend və
kontrakt qatı layihələndirilərkən qəbul edilib.

| № | Qərar | Status |
|---|---|---|
| [ADR-001](ADR-001-modular-monolith-per-module-deployment.md) | Modulyar kod bazası, modul üzrə deployment | Qəbul edilib |
| [ADR-002](ADR-002-inventory-not-split.md) | Inventory bölünmür | Qəbul edilib |
| [ADR-003](ADR-003-double-entry-ledger.md) | İkili yazılışlı stok ledger-i | Qəbul edilib |
| [ADR-004](ADR-004-balance-as-projection.md) | Balans yalnız proyeksiyadır | Qəbul edilib |
| [ADR-005](ADR-005-shared-database-tenant-id.md) | Shared database + `tenant_id` | Qəbul edilib |
| [ADR-006](ADR-006-flutter-monorepo-two-shells.md) | Flutter monorepo, iki tətbiq qabığı | Qəbul edilib |
| [ADR-007](ADR-007-contract-first-openapi.md) | Contract-first OpenAPI | Qəbul edilib |
| [ADR-008](ADR-008-decimal-on-client.md) | Client tərəfdə decimal | Qəbul edilib |
| [ADR-009](ADR-009-keycloak-oidc-pkce.md) | Keycloak OIDC + PKCE | Qəbul edilib |
| [ADR-010](ADR-010-mysql-single-db-table-prefix.md) | Tək MySQL database + cədvəl prefiksi | Qəbul edilib |
| [ADR-011](ADR-011-design-system.md) | Dizayn sistemi artifact-dan gəlir | Qəbul edilib |
| [ADR-012](ADR-012-branch-consumption-model.md) | Filial istehlakı: resept əsaslı nəzəri məxaric | Qəbul edilib |

Yeni ADR əlavə edərkən nömrəni artır, bu cədvələ sətir əlavə et və köhnə ADR-i
`Status: Əvəz edilib (ADR-0NN)` kimi işarələ — silmə.
