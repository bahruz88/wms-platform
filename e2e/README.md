# `e2e/` — uçdan-uca Playwright testləri

Bu qovluq **məhsulun həqiqətən işlədiyini** sübut edir: brauzer real Keycloak formasından keçir,
real gateway-ə sorğu göndərir və hər sənəd axını sonda **MySQL-də** yoxlanılır. Unit test deyil,
`curl` deyil — istifadəçinin gördüyü ekran və ledger-in saxladığı sətir.

Heç bir mock yoxdur. Testin keçməsi = sistemin işləməsi.

---

## Tez başlanğıc

```bash
cd e2e
npm ci                 # və ya: npm install
npm run e2e            # bütün suite
npm run e2e:report     # HTML hesabatı aç
```

Tək fayl və ya tək test:

```bash
npx playwright test tests/04-goods-receipt.spec.ts
npx playwright test -g "COUNT_ADJUST"
npx playwright test --headed --project=wms       # brauzeri gör
npx playwright show-trace test-results/<...>/trace.zip
```

---

## Nə tələb olunur

Suite **canlı stack-ə** qarşı işləyir. Hamısı qalxmış olmalıdır:

| Komponent | Ünvan | Qeyd |
|---|---|---|
| Veb tətbiq | `http://localhost:3000` | `/api` gateway-ə proxy edir |
| Gateway | `http://localhost:5001` | YARP |
| Keycloak | `http://localhost:8180` | realm `wms`, public client `wms-web`, PKCE S256 |
| MySQL | `localhost:3308` | baza `wms`, `root` / `wms_root` — **yalnız oxunur** |

```bash
make dev-up            # repo kökündən
cd web && npm run build && npm run serve
```

Dev istifadəçiləri (parol = istifadəçi adı): `admin`, `manager`, `procurement`, `keeper`,
`branch1`, `auditor`. Hamısı `tenant_id = 1`.

Ünvanlar mühit dəyişəni ilə əvəz olunur: `WMS_WEB_URL`, `WMS_API_URL`, `WMS_KEYCLOAK_URL`,
`WMS_DB_HOST`, `WMS_DB_PORT`, `WMS_DB_USER`, `WMS_DB_PASSWORD`, `WMS_DB_NAME`.

Brauzer artıq quraşdırılıbsa təkrar yüklənmir; yoxdursa:

```bash
npx playwright install chromium
```

---

## Suite nədən ibarətdir

```
e2e/
├── playwright.config.ts        HTML reporter, xəta anında trace + ekran şəkli
├── fixtures/
│   ├── auth.setup.ts           altı istifadəçi üçün real Keycloak girişi → .auth/*.json
│   └── wms.ts                  `as(user)` fixture-i + konsol/şəbəkə xətası toplayıcısı
├── helpers/
│   ├── users.ts                naviqasiya cədvəli, lokasiyalar, rol matrisi
│   ├── login.ts                Keycloak forması, `gotoApp`, sidebar köməkçiləri
│   ├── api.ts                  gateway-ə birbaşa müraciət — yalnız hazırlıq üçün
│   ├── db.ts                   MySQL oxu: balans, hərəkət qrupu, invariantlar
│   └── text.ts                 brend kitabının mətn qaydaları
└── tests/
    ├── 01-auth.spec.ts             giriş, sessiyanın sağ qalması, çıxış, səhv parol
    ├── 02-authorization.spec.ts    rol × naviqasiya, deep link rəddi, maya sütunları
    ├── 03-location-scoping.spec.ts filial yalnız öz lokasiyasını görür (SPEC §16)
    ├── 04-goods-receipt.spec.ts    qəbul: yarat → post → ledger + balans
    ├── 05-issue.spec.ts            məxaric: yola sal → IN_TRANSIT → filial təsdiqi
    ├── 06-count.spec.ts            sayım: dondur → LOCATION_FROZEN → SoD → COUNT_ADJUST
    ├── 07-waste.spec.ts            tullantı: təsdiqə göndər → özü təsdiqləyə bilməz → post
    ├── 08-return-to-vendor.spec.ts qaytarma: yarat → göndər → bağla
    ├── 09-reversal.spec.ts         storno: balans əvvəlki dəyərinə qayıdır
    ├── 10-invariants.spec.ts       SPEC §12 — bazadan yoxlanılır
    ├── 11-brand-book.spec.ts       vergül, U+202F, U+2212, emoji yox, RFC 7807 `code`
    └── 12-smoke-routes.spec.ts     bütün marşrutlar: konsol, şəbəkə, 4xx/5xx
```

### `setup` layihəsi

`fixtures/auth.setup.ts` hər altı istifadəçi üçün **bir dəfə** real Keycloak girişi edir və
sessiyanı `.auth/<user>.json` faylına yazır. Qalan testlər həmin vəziyyəti yükləyir — yəni hər
test üçün yenidən giriş edilmir, amma sessiya yenə də həqiqidir (PKCE ilə dəyişdirilmiş kod).

`.auth/` və `test-results/`, `playwright-report/` git-ignore edilir.

---

## Yazılış qaydaları

- **Selektor istifadəçinin gördüyüdür.** Rol, etiket, əlçatan ad. CSS sinfi yalnız dizayn
  sistemində semantik rolu olmayan element üçün (`.wms-num`, `.wms-header__docno`).
- **`waitForTimeout` yoxdur.** Gözləmə həmişə şərtə bağlıdır (`expect.poll`, `waitForURL`).
- **Hər test müstəqildir.** Lazım olan sənədi özü yaradır; miqdarlar millisaniyədən törədilir,
  ona görə təkrar işlədikdə toqquşmur.
- **Assertion zəiflədilmir.** Məhsulda defekt tapılırsa test qırmızı qalır və şərhində «DEFECT»
  yazılır — nəyin gözlənildiyi və nəyin baş verdiyi ilə.
- **Sənəd axını həmişə ledger ilə bitir.** «Post edildi» yazısı sübut deyil: `inv_movement`
  qrupu sıfıra balanslaşmalı, `inv_balance` tam gözlənilən qədər dəyişməlidir.

### Nə üçün bəzi addımlar API ilə gedir

Sayımda sətir girişi və tullantı sənədinin yaradılması **mobil** axındır
([ADR-013](../docs/adr/ADR-013-web-react-mobile-flutter.md),
[screen-map §3.8, §3.9](../docs/ux/screen-map.md)) — veb tətbiqində belə ekran yoxdur və ekranın
özü bunu yazır. Həmin iki addım mobil tətbiqin işlətdiyi endpoint ilə edilir; veb istifadəçisinin
gördüyü hər addım (yaratma, dondurma, təsdiqə göndərmə, təsdiq, post) brauzerdən keçir.

---

## Testin yaratdığı data

Suite real sənədlər yaradır və post edir — bu, dev bazasında qalır. Toqquşmaması üçün:

- miqdarlar unikaldır (`300.<ms>` formatı), ona görə iki icra bir-birini pozmur;
- sayım testi yalnız **BR-28M** lokasiyasında işləyir; başlamazdan əvvəl həmin lokasiyadakı açıq
  sayımları ləğv edir, çünki bir lokasiyada yalnız bir açıq sayım ola bilər;
- qəbul, məxaric, tullantı və qaytarma **WH-01 / BR-ELM** üzərində işləyir.

Bazanı təmizə çəkmək lazımdırsa seeder yenidən işlədilir (`make dev-seed`); suite bunu özü etmir,
çünki paralel işləyən başqa işi pozardı.
