# `src/api/` — kontraktdan gələn client

| Fayl | Nədir |
|---|---|
| `generated/` | `openapi-typescript` çıxışı — **git-ignore edilib**, əl ilə redaktə olunmur |
| `client.ts` | `openapi-fetch` client-ləri + bearer token, `Idempotency-Key`, `problem+json`, səhifələmə |
| `problem.ts` | RFC 7807 → `ProblemDetails` / `ApiError` (`code` sahəsi ilə) |
| `endpoints.ts` | Domen formalı çağırışlar; sorğu tipləri `paths[...]` -dan törədilir |
| `adapters.ts` | Gateway-in kontraktdan fərqli cavab verdiyi endpoint-lər üçün uyğunlaşdırıcı |
| `hooks.ts` | TanStack Query sarğıları (`useApiQuery`, `useApiPage`) |

## Generasiya

```bash
npm run gen:api                       # doqquz spesifikasiyanın hamısı
npm run gen:api -- inventory identity # yalnız seçilmiş modullar
```

Mənbə: [`contracts/openapi/*.v1.yaml`](../../../contracts/openapi). Generator:
[`scripts/gen-api.mjs`](../../scripts/gen-api.mjs). Çıxış hər modul üçün bir fayl:
`common.ts`, `identity.ts`, `masterdata.ts`, `inventory.ts`, `procurement.ts`,
`documents.ts`, `notifications.ts`, `consumption.ts`, `reporting.ts`.

> **Qeyd:** repo kökündəki `.gitignore` bütün `web/src/api/generated/` qovluğunu ignore edir,
> ona görə oradakı `README.md` də commit olunmur (Dart tərəfdə də eyni vəziyyətdir). Bu sənəd
> həmin məlumatı ignore edilməyən yerdə saxlayır.

## Qaydalar

1. **Onluq sahələr string-dir** (`common.v1.yaml#/components/schemas/Decimal`). `decimal.js` ilə
   [`src/core/decimal.ts`](../core/decimal.ts) üzərindən `Quantity` / `Money`-yə çevirin;
   `Number()` və `parseFloat()` qadağandır (ADR-008). `wms/no-number-for-decimal` ESLint qaydası
   miqdar sahəsini `number` kimi elan etməyə imkan vermir.
2. **Sorğu tipləri əl ilə yazılmır.** `endpoints.ts`-dəki `Query<Paths, '/route'>` köməkçisi
   parametrləri birbaşa generasiya olunan `paths` tipindən götürür.
3. **Hər `POST` `Idempotency-Key` daşıyır** — `client.ts` içindəki middleware onu avtomatik əlavə
   edir (SPEC §13.2).
4. **Xəta həmişə `ApiError`-dur** və `code` sahəsi `WmsAlert`-də görünür (SPEC §13.3).
