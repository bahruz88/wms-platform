# ADR-012 — Filial istehlakı modeli: resept əsaslı nəzəri məxaric

**Status:** Qəbul edildi — 21.09.2026
**Əvəz edir:** [SPEC §20.1](../SPEC-Satinalma-Anbar-Platformasi.md#201--filial-istehlakı-modeli--bloklayıcı) (bloklayıcı açıq qərar)
**Əlaqəli:** [ADR-002](ADR-002-inventory-not-split.md), [ADR-003](ADR-003-double-entry-ledger.md), [ADR-004](ADR-004-balance-as-projection.md)

## Kontekst

Platformanın indiki modelində filial stoku **yalnız artır**. Mərkəzi anbardan gələn
transfer onu artırır; yalnız tullantı, nümunə və filiallararası transfer azaldır.
Sendviç hazırlanarkən işlənən xammalın stokdan necə çıxacağı təyin edilməyib.

Nəticə: filial qalığı real vəziyyətlə heç vaxt üst-üstə düşmür, sayım hər dəfə böyük
fərq verir və bu fərqin **səbəbi** məlum olmur. SPEC §24-dəki həftəlik/aylıq istifadə
analitikası da bu boşluq ucbatından mənasız qalır.

SPEC üç variant təklif edirdi:

| Variant | Əlavə iş | Dəqiqlik |
|---|---|---|
| (a) Resept/BOM + POS inteqrasiyası | Yeni kontekst + POS adapteri | Yüksək |
| (b) Filialın günlük istehlak qeydiyyatı | Sadə forma | Orta |
| (c) Yalnız inventarizasiya fərqi | Minimal | Aşağı |

## Qərar

**Variant (a) seçilir: resept əsaslı nəzəri məxaric, fiziki sayımla tutuşdurulur.**

Lakin POS inteqrasiyası **bloklayıcı asılılıq deyil**. Satış məlumatı sistemə
`SalesImport` adlı tək bir giriş nöqtəsindən daxil olur və onun üç mənbəyi var:

1. `POS` — POS adapteri (avtomatik, Faza 4);
2. `CSV` — POS hesabatının fayl kimi yüklənməsi (Faza 1-dən işləyir);
3. `MANUAL` — filialın günlük menyu satışını əl ilə daxil etməsi (Faza 1-dən işləyir).

Hər üç mənbə eyni aşağı axına düşür. Beləliklə variant (b) **ayrıca model deyil**,
(a)-nın əl ilə qidalandırılan halıdır.

### Nə üçün (a)

**Restoran sənayesinin standart praktikası nəzəri/faktiki fərq analizidir.** Nəzəri
istehlak satılan menyu maddəsinin reseptə vurulmasından çıxır, faktiki istehlak isə
sayımdan. Aradakı fərq idarəetmə siqnalıdır: həddən artıq porsiya, qeydə alınmamış
tullantı, oğurluq, qəbulda səhv. Subway kimi standart reseptli şəbəkə üçün bu model
xüsusilə uyğundur, çünki hər sendviçin tərkibi sabitdir.

**Variant (c) itkini ölçür, səbəbini göstərmir.** Sayım «10 kq toyuq çatmır» deyir,
amma bunun porsiya səhvi, tullantı, yoxsa oğurluq olduğunu ayırd edə bilmir. Excel
prosesinin əsas problemi məhz bu idi və onu təkrarlamağın mənası yoxdur.

**Variant (b) ikiqat məlumat girişidir və səhvə açıqdır.** Filial işçisindən
«bu gün 3,4 kq toyuq işlətdim» soruşmaq təxminə dəvətdir. «Bu gün 120 ədəd Italian
BMT 15 sm satdım» isə kassa lentindən oxunan, yoxlanıla bilən rəqəmdir. Menyu
səviyyəsində giriş, inqrediyent səviyyəsində girişdən qat-qat dəqiqdir.

### Ledger-ə necə oturur

İstehlak **ayrıca sütun deyil, adi ikili yazılışlı sənəddir** (ADR-003):

| Əməliyyat | Sətir 1 | Sətir 2 |
|---|---|---|
| Günlük istehlak | `Elmlər` −12,5 | `V_CONSUMPTION` +12,5 |

Yeni virtual lokasiya tipi `V_CONSUMPTION` və yeni `doc_type = 'CONSUMPTION'` əlavə
olunur. Balansın yeganə mənbəyi yenə `inv_movement` qalır (ADR-004) — istehlak
mühərriki balansa birbaşa toxunmur, sənəd post edir.

### Yeni modul

Resept, satış feed-i və məxaric hesablaması **`Consumption` modulunda** (`cons` şeması)
birləşir. Ayrıca `Recipe` modulu açılmır: 3 nəfərlik komanda üçün iki yeni bounded
context əvəzinə bir dənəsi kifayətdir və resept burada yalnız məxarici hesablamağa
xidmət edir. Modul `MasterData`-dan məhsul və lokasiya, `Inventory`-dən sənəd post
etmə imkanı alır — hər ikisi `*.Contracts` vasitəsilə (ADR-001).

Bu, ADR-002-ni pozmur: `Consumption` balansa və partiyaya toxunmur, o yalnız
`Inventory`-yə «bu sənədi post et» deyir; post etmə əməliyyatı bütövlükdə Inventory-nin
tək tranzaksiyasında qalır.

## Nəticələr

**Müsbət.**

- Filial qalığı ilk dəfə real dəyərə yaxınlaşır; sayım fərqi idarə oluna bilən ölçüyə düşür.
- Nəzəri/faktiki fərq hesabatı yaranır — itkinin manatla dəyəri və səbəbi görünür.
- SPEC §24 istifadə analitikası işlək olur.
- POS inteqrasiyası gecikərsə də sistem işləyir; adapter sonradan eyni giriş nöqtəsinə qoşulur.
- Menyu mühəndisliyi və maya dəyəri hesabatları üçün baza hazır olur.

**Mənfi və risklər.**

- **Resept master-i qurulmalıdır.** Hər menyu maddəsi üçün tərkib, porsiya miqdarı və
  itki faizi toplanmalıdır. Bu, Faza 0 data migration işinin həcmini artırır və
  müştərinin əməliyyat komandasından vaxt tələb edir. Reseptsiz menyu maddəsi satılarsa
  həmin satış məxaric yaratmır — sistem bunu «resepti olmayan satış» kimi xəbərdarlıq edir.
- **Resept versiyalanmalıdır.** Tərkib dəyişdikdə keçmiş hesablamalar toxunulmaz qalmalıdır;
  bu, `master_product_uom`-dakı `valid_from`/`valid_to` nümunəsinin təkrarıdır.
- **Mənfi qalıq riski.** Qəbul qeyd olunmayıbsa nəzəri məxaric qalığı sıfırın altına
  aparmaq istəyir. SPEC §12.1 mənfi qalığı qadağan edir, ona görə mühərrik **mövcud
  qədərini çıxarır və çatışmayan hissəni `ConsumptionShortfall` kimi qeyd edir**.
  Çatışmazlıq gizlədilmir — o, qəbulun qeyd olunmadığının ən erkən siqnalıdır.
- **Nəzəri rəqəm həqiqət deyil.** O, sayımı əvəz etmir; sayım yenə yeganə fiziki həqiqətdir.
  Model ikisini qarşılaşdırmaq üçündür, birini digəri ilə əvəz etmək üçün deyil.

**Geri dönmə.** Əgər resept master-i vaxtında qurula bilməsə, `MANUAL` mənbəyi
inqrediyent səviyyəsində girişə açıla bilər (faktiki olaraq variant (b)) — sxem
dəyişmir, yalnız `cons_sales_line` əvəzinə birbaşa `cons_run_line` doldurulur.
Variant (c) isə heç bir halda seçilmir: sayım onsuz da sistemin bir hissəsidir.
