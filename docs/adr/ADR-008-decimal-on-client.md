# ADR-008: Client tərəfdə decimal — JSON-da string, Dart-da `decimal` paketi

**Status:** Qəbul edilib
**Əlaqəli:** [SPEC §1.4](../SPEC-Satinalma-Anbar-Platformasi.md#14-mövcud-vəziyyətdən-çıxarılan-dərslər), [SPEC §6.3](../SPEC-Satinalma-Anbar-Platformasi.md#63-tip-qaydaları--məcburi), [CONVENTIONS → API](../CONVENTIONS.md), [ADR-007](ADR-007-contract-first-openapi.md)

## Kontekst

Mövcud Excel faylında `−23.50999999999999` dəyəri var — ikili float artefaktı. Spesifikasiya
buna görə DB səviyyəsində `DECIMAL(18,4)` tələb edir və `FLOAT`/`DOUBLE`-u qadağan edir (§6.3).
Lakin zəncirin ən zəif həlqəsi client-dir:

- **Dart-da yerli `decimal` tipi yoxdur.** `double` IEEE-754 ikili floatdır: `0.1 + 0.2` →
  `0.30000000000000004`. `num` da eyni problemi daşıyır.
- **JSON `number` tipi də kifayət deyil:** `dart:convert` JSON rəqəmini `double` kimi parse edir
  (böyük tam ədədlər istisna), yəni server düzgün `12.5000` göndərsə belə, client onu float-a çevirir.
  JavaScript hədəfində (Flutter web) bütün rəqəmlər onsuz da `double`-dır.

Yəni server tərəfdəki bütün dəqiqlik zəhməti client-də bir `jsonDecode` çağırışı ilə itə bilər.

## Qərar

**Bütün miqdar, məbləğ, məzənnə, conversion əmsalı və faiz sahələri JSON-da `string` kimi
ötürülür** və client-də `decimal` paketi ilə parse edilir.

```yaml
# contracts/openapi/common.v1.yaml
Decimal:
  type: string
  pattern: '^-?\d+(\.\d{1,8})?$'
```

- Kontraktda bu sahələr `$ref`-lə `Decimal`-a bağlanır → generator onları Dart `String` kimi çıxarır.
- `wms_api_client`-dəki mapping qatı `String` → `Decimal.parse(...)` → `wms_core` tiplərinə
  (`Quantity {Decimal value, int uomId}`, `Money {Decimal amount, String currency}`) çevirir.
  Generasiya olunmuş model birbaşa UI-ya verilmir.
- Geri istiqamətdə: `Decimal.toString()`, heç bir `toStringAsFixed(2)` yuvarlaqlaşdırması yoxdur.
- Backend tərəfdə `decimal` → string serializasiyası `JsonConverter` ilə mərkəzləşdirilir.
- Göstərmə formatı ayrı məsələdir: `WmsFormat.number()` vergül onluq ayırıcısı və dar boşluq
  min ayırıcısı ilə formatlayır (`1 284,5000`), mənfi işarə U+2212 — bu, dizayn sisteminin qaydasıdır.

## Nəticələr

- `double` bütün zəncirdə yoxdur: DB `DECIMAL` → C# `decimal` → JSON `string` → Dart `Decimal`.
- Analizator qaydası: Dart tərəfdə pul/miqdar üçün `double` istifadəsi review-də rədd edilir;
  C# tərəfdə `BannedSymbols.txt` `double`/`float` üçün analizator xətası verir.
- Hesablamalar (`qty × unitCost`, cəmlər) **serverdədir**; client yalnız göstərir. Client-də
  hesablama lazım olduqda (məs. sətir cəmi önizləməsi) `Decimal` operatorları işlədilir,
  nəticə sonda serverin qaytardığı dəyərlə əvəz olunur.
- Miqdar heç vaxt kəsilmir: onluq sayı `base_uom.decimals`-dən gəlir (`DECIMAL(18,4)` → 4-ə qədər).
- Qarşılığında: sahələr string olduğu üçün JSON-a baxan üçüncü tərəf inteqrasiyası (1C)
  `"12.5000"` görür — bu, sənədləşdirilib və `Decimal` sxeminin `pattern`-i ilə maşın üçün oxunaqlıdır.
- Sıralama və müqayisə string üzərində aparılmır — həmişə `Decimal`-a çevrildikdən sonra.
