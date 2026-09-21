# `web/` — WMS veb tətbiqi (Vite + React 18 + TypeScript)

Satınalma və Anbar Platformasının **veb qabığı**: satınalmaçı, menecer, admin və auditor üçün.
Anbardar və filial işçisi mobil tətbiqdən (`mobile/`) istifadə edir. İki stack, bir kontrakt —
[ADR-013](../docs/adr/ADR-013-web-react-mobile-flutter.md).

Ortaq nöqtə yalnız [`contracts/openapi/`](../contracts/openapi)-dir: TypeScript client də,
Dart client də oradan generasiya olunur. Kod paylaşılmır.

---

## Tez başlanğıc

```bash
cd web
cp .env.example .env        # portlar bu maşına uyğundur
npm ci                      # və ya: npm install
npm run gen:api             # OpenAPI → TypeScript tipləri (git-ignore edilir)
npm run dev                 # http://localhost:3001
```

Backend və Keycloak işləməlidir:

```bash
make dev-up                 # repo kökündən — docker-compose
scripts/keycloak-token.sh admin   # curl üçün token
```

Dev istifadəçiləri (parol = istifadəçi adı): `admin`, `manager`, `procurement`, `keeper`,
`branch1`, `auditor`. Hamısı `tenant_id=1`.

---

## Əmrlər

| Əmr | Nə edir |
|---|---|
| `npm run dev` | Vite dev server, port **3001** (Keycloak redirect siyahısındadır) |
| `npm run gen:api` | `contracts/openapi/*.v1.yaml` → `src/api/generated/*.ts` |
| `npm run gen:api -- inventory identity` | yalnız seçilmiş modullar |
| `npm run gen:tokens` | `docs/design-system/tokens.json` → `src/design-system/tokens.css` |
| `npm run typecheck` | `tsc -b --force` — sıfır xəta tələb olunur |
| `npm run lint` | ESLint (o cümlədən `wms/no-number-for-decimal` və `toUpperCase()` qadağası) |
| `npm run format` / `format:check` | Prettier |
| `npm test` | Vitest + React Testing Library |
| `npm run test:watch` | interaktiv test rejimi |
| `npm run build` | tokenləri yenilə → tip yoxla → `dist/` istehsal buildi |
| `npm run serve` | `dist/`-i **3000** portunda ver (`vite preview`) |

`npm run build` tokenləri hər dəfə yenidən generasiya edir, ona görə `tokens.css` heç vaxt
köhnəlmir; `src/design-system/tokens.test.ts` köhnəlmiş faylı test səviyyəsində də tutur.

---

## Konfiqurasiya

`.env` (git-ignore edilir; nümunə: `.env.example`):

| Dəyişən | Mənası |
|---|---|
| `VITE_API_BASE_URL` | **Boş** = eyni origin (`/api/v1/...`), sorğular proxy vasitəsilə gateway-ə gedir. Mütləq URL yalnız gateway CORS başlıqları göndərdikdə yazılır. |
| `VITE_API_PROXY_TARGET` | Proxy hədəfi. Standart `http://localhost:5001` (CONVENTIONS: standart port 5000, bu maşında 5001). |
| `VITE_KEYCLOAK_ISSUER` | `http://localhost:8180/realms/wms` |
| `VITE_KEYCLOAK_CLIENT_ID` | `wms-web` — public client, Authorization Code + PKCE (S256) |

> **Niyə proxy?** Gateway (YARP) hazırda `Access-Control-Allow-Origin` göndərmir, ona görə
> brauzer `:3000`-dan `:5001`-ə birbaşa müraciət edə bilmir. Dev və preview serverləri `/api`
> yolunu gateway-ə ötürür; istehsalda eyni işi nginx görür
> (`deploy/docker/web.Dockerfile`). Gateway CORS başlıqları göndərməyə başlayanda
> `VITE_API_BASE_URL=http://localhost:5001` yazmaq kifayətdir.

---

## Struktur

```
web/
├── eslint-rules/
│   └── no-number-for-decimal.mjs    ADR-008 mühafizəçisi (öz ESLint qaydamız)
├── scripts/
│   ├── gen-api.mjs                  OpenAPI → TypeScript tipləri
│   └── gen-tokens.mjs               tokens.json → tokens.css  (--check rejimi ilə)
├── src/
│   ├── api/                         generasiya olunan client + tipli qat
│   ├── app/                         shell, routing, tema, naviqasiya, query client
│   ├── auth/                        OIDC sessiyası, icazə modeli, route guard-ları
│   ├── components/                  ekranlar üçün ortaq karkas (Page, Pager, xəta/boş hallar)
│   ├── core/                        decimal.js sarğıları (Quantity/Money) və formatlar
│   ├── design-system/               WMS Enterprise-in React portu (15 komponent + Icons + format)
│   ├── features/                    ekranlar: dashboard, procurement, inventory, consumption,
│   │                                masterdata, reporting, admin, auth
│   └── i18n/                        az (default), en, ru
├── index.html
├── silent-renew.html                OIDC səssiz yenilənmə üçün ayrıca giriş nöqtəsi
└── vite.config.ts
```

---

## Dizayn sistemi

Mənbə: [`docs/design-system/`](../docs/design-system). Burada **tərcümə qatı yoxdur** —
komponentlər öz doğma formatında (React) işlənir.

| Mənbə | Burada | Necə |
|---|---|---|
| `tokens.json` | `src/design-system/tokens.css` | `npm run gen:tokens` ilə generasiya olunur |
| `components/bundle.css` | `src/design-system/bundle.css` | **hərfi köçürülüb**, dəyişdirilmir |
| `components/index.d.ts` | `src/design-system/*.tsx` | tipli ESM React modulları |

`window.Wms` qlobalı işlədilmir (ADR-013).

**15 komponent:** `Button`, `Badge`, `DocStatusBadge`, `Alert`, `Field`, `TextField`, `Select`,
`QtyUomInput`, `DataTable`, `KpiCard`, `LedgerTable`, `BatchPicker`, `ApprovalChain`,
`VarianceIndicator`, `Dialog` — üstəgəl `Icons` və `format`.

Hər komponent öz `components/<Ad>/README.md` qaydalarına riayət edir və testlə qorunur:

- `DataTable` — `permission` açarı olan sütun icazə yoxdursa **ümumiyyətlə render edilmir**;
- `LedgerTable` — işarə (`+` / `−`) həmişə görünür, sıfır cəmi yoxlaması sətri həmişə var;
- `BatchPicker` — FEFO/FIFO təklifi nişanlanır, `ACTIVE` olmayan partiya görünür, lakin seçilmir;
- `VarianceIndicator` — fərq var, səbəb kodu yoxdursa «Səbəb kodu yoxdur» nişanı çıxır;
- `Button` — `loading` zamanı eni dəyişmir, deaktiv düymə səbəbini `title` ilə daşıyır.

Hər iki tema (işıqlı və tünd) eyni komponent kodundan işləyir; seçim yuxarı paneldədir və
`localStorage`-da saxlanılır.

---

## Onluq intizamı (ADR-008)

Miqdar və məbləğ JSON-da **string**-dir. Client tərəfdə `decimal.js`:

```ts
import { Quantity, Money } from '@core/decimal';
import { formatNumber, formatMoney } from '@core/format';

const qty = Quantity.parse('2826.0870', 1, 'G');
formatNumber(qty, 4);               // "2 826,0870"   (U+202F dar boşluq, vergül)
formatNumber('-23.5', 4);           // "−23,5000"     (U+2212 mənfi işarəsi)
formatMoney(Money.parse('194.0217', 'AZN'), 2);  // "194,02 AZN"
```

`number` tipi miqdar üçün **qadağandır**. Bunu iki şey qoruyur:

1. `eslint-rules/no-number-for-decimal.mjs` — `qty`, `unitPrice`, `totalAmount`, `avgUnitCost`,
   `fxRate` kimi sahələr `number` (o cümlədən `string | number` birləşməsi) elan edilərsə
   `npm run lint` uğursuz olur;
2. `eslint-rules/__tests__/no-number-for-decimal.test.ts` — qaydanın özü test edilir.

Tarix `dd.MM.yyyy`, vaxt `dd.MM.yyyy HH:mm`. İnterfeys mətnində `toUpperCase()` qadağandır
(`i` → `I` çevrilməsi səhvdir) — bunu da ESLint qaydası tutur.

---

## Auth

`oidc-client-ts`, Authorization Code + PKCE (S256), public client `wms-web`:

- `/callback` — redirect URI (Keycloak-da `http://localhost:3000/*` və `:3001/*` icazəlidir);
- `silent-renew.html` — səssiz yenilənmə üçün ayrıca giriş nöqtəsi (tətbiq bundle-ını yükləmir);
- sessiya `localStorage`-da saxlanılır, səhifə yenilənəndə itmir;
- çıxış `post_logout_redirect_uri` ilə Keycloak SSO sessiyasını da bağlayır.

Token-dən `tenant_id` (**məcburi**), `preferred_username` və `realm_access.roles` oxunur.
Rollar icazələrə serverdəki ilə **eyni alqoritmlə** çevrilir
(`backend/src/BuildingBlocks/Wms.Common.Infrastructure/Tenancy/RolePermissionMap.cs` portu,
`src/auth/permissions.ts`).

`<RequirePermission>` deep link ilə keçilə bilmir: icazə yoxdursa ekran render edilmir, əvəzinə
səbəb və `FORBIDDEN` kodu göstərilir. Yeganə həqiqi yoxlama isə serverdədir (`x-permission`).

---

## i18n

`i18next` + `react-i18next`. Dillər: **az (default)**, `en`, `ru`. Dil seçimi istifadəçi
menyusundadır və `localStorage`-da saxlanılır. Emoji işlədilmir; interfeys mətni böyük hərflə
yazılmır. `src/i18n/i18n.test.ts` hər üç bundle-ın açarlarının üst-üstə düşdüyünü və bu iki
qaydanın pozulmadığını yoxlayır.

---

## Test

```bash
npm test
```

Əhatə: formatlaşdırma qaydaları, `Quantity`/`Money` arifmetikası, `problem+json` parse-ı,
`Idempotency-Key` və bearer token, səhifələmə zərfi, rol → icazə xəritəsi, route guard-ları,
naviqasiya filtri, CSV parse-ı, ESLint qaydasının özü, generasiya olunan `tokens.css`-in
köhnəlməməsi, `bundle.css`-in mənbə ilə eyni olması və 15 dizayn-sistem komponentinin davranış
qaydaları.

---

## Build və verilmə

```bash
npm run build     # dist/
npm run serve     # http://localhost:3000
```

Statik fayllar nginx ilə verilir (`deploy/docker/web.Dockerfile`). nginx iki şeyi etməlidir:
SPA fallback (bütün yollar → `index.html`) və `/api` yolunun gateway-ə ötürülməsi.
