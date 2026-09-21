# ADR-009: Keycloak OIDC + PKCE, `tenant_id` claim, icazə xəritəsi backend-də

**Status:** Qəbul edilib
**Əlaqəli:** [SPEC §16](../SPEC-Satinalma-Anbar-Platformasi.md#16-təhlükəsizlik), [SPEC §7](../SPEC-Satinalma-Anbar-Platformasi.md#7-şema-iam), [CONVENTIONS → Keycloak realm](../CONVENTIONS.md), [ADR-005](ADR-005-shared-database-tenant-id.md)

## Kontekst

Sistemin altı rolu (`ADMIN`, `PROCUREMENT_OFFICER`, `PROCUREMENT_MANAGER`, `WAREHOUSE_KEEPER`,
`BRANCH_USER`, `AUDITOR`), üç client-i (veb, mobil, API) və multi-tenant tələbi var.
Öz identity serverini yazmaq (parol hash-ı, sessiya, MFA, token rotasiyası, şifrə bərpası)
həm risklidir, həm də bu komanda ölçüsündə davamlı xərcdir.

Ayrıca sual: **icazələr harada yaşayır?** Keycloak-da rol → icazə xəritəsi qurmaq mümkündür,
lakin bu, icazə dəyişikliyini realm konfiqurasiyasına bağlayır və tenant başına fərqli
icazə dəsti (SaaS tələbi) idarə olunmaz olur.

## Qərar

**Autentifikasiya Keycloak-da (realm `wms`), avtorizasiya backend-də.**

- Client-lər **public + PKCE** (Authorization Code Flow with Proof Key for Code Exchange):
  - `wms-web` — redirect `http://localhost:3000/*`, `http://localhost:3001/*`;
  - `wms-mobile` — redirect `az.wms.mobile://callback`;
  - `wms-api` — bearer-only audience (`aud = wms-api`).
  Client secret **yoxdur** — brauzer və mobil tətbiq secret saxlaya bilməz; PKCE
  `code_verifier`/`code_challenge` cütü kodun oğurlanmasına qarşı qorumadır.
- Token: access 15 dəqiqə, refresh 8 saat. Mobil tərəfdə refresh token `flutter_secure_storage`
  (Keychain / EncryptedSharedPreferences), vebdə yaddaşda + `silent refresh`.
- **`tenant_id` claim-i məcburidir** (user attribute → token claim). Backend tenant kontekstini
  **yalnız** bu claim-dən götürür (ADR-005); body/query-dən gələn tenant dəyəri nəzərə alınmır.
  Claim yoxdursa sorğu `401`-dir.
- Realm rolları (`realm_access.roles`) yalnız **kobud** bölgüdür. Effektiv icazə dəsti
  backend-dədir: `iam_role` → `iam_role_permission` → `iam_permission` (`inv.receipt.create`,
  `master.product.view_cost`...). Endpoint `.RequirePermission("...")` ilə qorunur və kontrakt
  faylındakı `x-permission` ilə eyni olmalıdır.
- Client icazə siyahısını `GET /api/v1/identity/me`-dən alır və menyu/route qorumasını ona görə
  qurur — bu **UX-dir, təhlükəsizlik deyil**; yeganə həqiqi yoxlama serverdədir.
- Lokasiya məhdudiyyəti (`iam_user_location`) də serverdə, query filter səviyyəsində tətbiq olunur.

## Nəticələr

- Parol, MFA, şifrə bərpası, brute-force qoruması Keycloak-ın işidir — bizim kodda yoxdur.
- Tenant başına icazə dəstini dəyişmək üçün realm-a toxunmaq lazım deyil, DB sətri kifayətdir.
- SoD qaydaları (anbardarda `master.product.view_cost` olmamalıdır — SPEC §7.1) DB səviyyəsində
  yoxlanılır və `setRolePermissions` endpoint-i pozuntunu `422` ilə rədd edir.
- Mobil PKCE axını deep link tələb edir: `az.wms.mobile://callback` həm Android intent-filter,
  həm iOS URL scheme kimi qeydiyyatdan keçir.
- Qarşılığında: Keycloak əlavə infrastruktur komponentidir (dev-də konteyner, prod-da HA).
  On-prem müştəri üçün də qalxmalıdır — `docker-compose.onprem.yml`-ə daxildir.
- Keycloak müvəqqəti əlçatmaz olduqda mövcud access token bitənə qədər (15 dəq) sistem işləyir;
  yeni login mümkün deyil. Bu, qəbul edilən risk kimi sənədləşdirilib.
