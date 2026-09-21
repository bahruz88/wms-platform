Satınalma və Anbar İdarəetmə Platformasının interfeys sistemi. Multi-tenant SaaS olduğu üçün palitra brenddən asılı deyil: ilk müştəri Subway-dir, lakin heç bir token restoran brendinə bağlanmayıb — yeni şəbəkəyə satışda yalnız `accent` ailəsi dəyişdirilir.

Sistem üç şeyi struktur səviyyəsində daşıyır: **rəqəm dəqiqliyi** (hər miqdar tabular mono ilə, sağa düzlənmiş), **sənəd izlənəbilirliyi** (hər status, hər təsdiq addımı görünür) və **sıxlıq** (anbardar bir ekranda 40 sətir görməlidir).

## Prinsiplər

- **Rəqəm heç vaxt tək qalmır.** Hər miqdarın yanında vahid kodu göstər; base UoM-dan fərqli vahid daxil edilibsə, altında `figure-sm` ilə base ekvivalentini ver.
- **Rəng tək başına məna daşımır.** Status rəngi həmişə söz və ya işarə ilə müşayiət olunur — `+`/`−`, status adı, ikon. Anbar işığında və rəng görmə fərqində interfeys işləməlidir.
- **Sənəd statusu hər yerdə eyni görünür.** `DocStatusBadge`-dən kənarda status üçün öz badge-ini yazma.
- **Boş yerdənsə sıxlıq.** Cədvəl xanası `space-2` / `space-3` padding ilə; `space-5`-dən yuxarı boşluq yalnız səhifə bölmələri arasında.

## Dil və mətn

- İnterfeys dili **Azərbaycan dilidir**. Sistem sözləri (SKU, FEFO, PO, batch) tərcümə edilmir, olduğu kimi qalır; izah lazımdırsa `caption` ilə altına yazılır.
- İstifadəçiyə **siz** deyə müraciət et: «Partiya seçin», «Fərqin səbəbini göstərin».
- Düymə mətni əmr formasındadır və qısadır: «Post et», «Təsdiqlə», «Rədd et», «Qaytar». «OK» və «Ləğv» əvəzinə əməliyyatın adını yaz.
- **Böyük hərflə yazma.** `text-transform: uppercase` bu sistemdə qadağandır: `i` hərfi `I`-yə çevrilir, `İ` alınmır. `label` stili bu səbəbdən 600 çəki + hərf aralığı ilə vurğulanır.
- Onluq ayırıcısı **vergül**, min ayırıcısı **dar boşluq**: `1 284,5000`. Miqdar `base_uom.decimals` qədər onluqla göstərilir, kəsilmir.
- Tarix `dd.MM.yyyy`, vaxt `dd.MM.yyyy HH:mm`. Saxlama UTC-dədir, göstərmə `tenant.timezone` ilə.
- Əlifba sırası tələb olunan siyahılarda `name_sort_key` sütununa görə sırala — brauzerin `localeCompare`-i `ə` hərfini düzgün yerləşdirmir.
- Emoji işlədilmir.

## Rəng

- Səhifə fonu `surface-canvas`, məzmun bloku `surface`, üst qat (modal, dropdown) `surface-raised`.
- Mətn: əsas `ink`, ikinci dərəcəli `ink-muted`, placeholder `ink-subtle`. Bundan açıq rəng yoxdur.
- Əsas əməliyyat `accent` fonu + `on-accent` mətn. Bir ekranda yalnız bir primary düymə olur.
- Status rəngləri: `success` təsdiqlənmiş/post edilmiş, `warning` gözləyən və ya xəbərdarlıq, `danger` rədd edilmiş/xəta/vaxtı keçmiş. Neytral vəziyyətlər (DRAFT) `ink-muted` qalır.
- Ledger işarəsi: müsbət `qty_base` üçün `ledger-in`, mənfi üçün `ledger-out`. Bu tokenlər `success`/`danger`-in aliaslarıdır — mədaxil «yaxşı», məxaric «pis» demək deyil, ona görə də işarə (`+` / `−`) həmişə yazılır.
- Virtual lokasiyalar (`V_SUPPLIER`, `V_WASTE`, `V_SAMPLE`, `V_ADJUSTMENT`, `IN_TRANSIT`) `virtual-location` / `virtual-location-soft` nişanı ilə göstərilir ki, fiziki anbarla qarışmasın.
- Hər iki tema eyni komponent kodundan işləyir. Tünd temada `accent` açılır, ona görə üzərindəki mətn `on-accent` tokenindən gəlir, sabit ağ deyil.

## Tipoqrafiya

- Mətn `sans` ailəsi ilə: standart `body`, vurğulu xana `body-strong`, başlıq `title` / `title-lg`, səhifə başlığı `display`.
- **Bütün rəqəmlər `mono` ailəsi ilə.** Cədvəldə `figure`, KPI-da `figure-lg`, ikinci dərəcəli `figure-sm`, sənəd nömrəsi və SKU üçün `doc-no`. Səbəb: 1 000 sətirlik ledger-də onluq nöqtələr bir sütunda düzülməlidir.
- Forma etiketi `label`, sahə izahı və xəta mətni `caption`.

## Məsafə, sərhəd, radius

- Sıx cədvəl sətri `space-2`, standart cədvəl sətri `space-3` şaquli padding alır.
- Kart və panel `radius-lg` + `border`; düymə və input `radius-md`; badge `radius-sm`.
- **Ayırma sərhədlə edilir, kölgə ilə deyil.** `shadow-sm` sticky başlıq üçün, `shadow-md` dropdown üçün, `shadow-overlay` yalnız modal üçün.
- Nəzarət elementinin sərhədi `border-control`-dur (`border` yox) — hüdud məna daşıyır və 3:1 kontrast tələb edir.

## Vəziyyətlər

- Fokus: `2px solid var(--focus-ring)`, `2px` offset. Heç bir yerdə `outline: none` yazma.
- Deaktiv: `opacity-disabled` + `cursor: not-allowed`. Deaktiv düymənin səbəbini `title` və ya yan qeyd kimi göstər.
- Yüklənmə: düymə öz enini saxlayır, mətn yerində spinner göstərilir — düymə «sıçramır».
- Xəta: sahənin altında `caption` ölçüsündə `danger` mətn; sahə sərhədi `danger`-ə keçir. Server xətası (RFC 7807) `Alert` ilə göstərilir və `code` sahəsi (`INSUFFICIENT_STOCK`, `LOCATION_FROZEN`, `STALE_VERSION`) mütləq görünür — dəstək bu kodla işləyir.
- Boş cədvəl: səbəbi və növbəti addımı yaz («Bu lokasiyada qalıq yoxdur. Qəbul sənədi yaradın.»), sadəcə «Məlumat yoxdur» yazma.

## İkonoqrafiya

Sistemin öz ikon kitabxanası yoxdur. Komponentlərə daxil olan ikonlar (chevron, bağla, xəbərdarlıq üçbucağı, təsdiq işarəsi) bundle içində inline SVG-dir, `stroke="currentColor"` ilə işləyir və mətn rəngini miras alır. Əlavə ikon lazım olduqda **konturlu, 1.5px qalınlıqda, 16px şəbəkəli** dəst seç və eyni `currentColor` qaydasına riayət et; ikon tək başına əməliyyatı bildirirsə, `aria-label` məcburidir.

## Domen qaydaları

Bu qaydalar spesifikasiyanın invariantlarından gəlir və interfeysdə pozulmamalıdır:

- **Balans birbaşa redaktə olunmur.** Heç bir ekranda qalıq sahəsi input kimi göstərilmir. Dəyişiklik yalnız sənəd (qəbul, məxaric, sayım, tullantı) vasitəsilə olur.
- **Düzəlişin səbəbi məcburidir.** Sayım fərqi, təklif olunandan fərqli partiya seçimi, PO-dan az/çox qəbul — hamısında `reason_code_id` seçimi və ya `variance_note` sahəsi forma səviyyəsində məcburi işarələnir.
- **FEFO təklifi görünür olmalıdır.** `BatchPicker` sistemin təklif etdiyi partiyanı nişanla göstərir; istifadəçi başqasını seçərsə səbəb sahəsi açılır.
- **Qiymət icazəyə bağlıdır.** `master.product.view_cost` icazəsi olmayan istifadəçiyə `unit_cost`, `avg_unit_cost`, `total_value` sütunları **göstərilmir** — boş xana və ya `***` yazmaq yox, sütun tamamilə render edilmir. `DataTable`-da bu sütunlara `permission` açarı verilir.
- **Dondurulmuş lokasiya.** `inv_count.status = FROZEN` olduqda həmin lokasiyanın əməliyyat düymələri deaktiv edilir və səbəb `Alert` ilə yazılır.
- **Storno geri qaytarma deyil.** Post edilmiş sənəddə «Redaktə et» düyməsi olmur; yalnız «Storno et» olur və o, yeni sənəd yaradır.
- **Sənəd nömrəsi `doc-no` stili ilə**, həmişə tam formatda: `GR-2026-00311`.

## Əlçatanlıq

- Bütün mətn cütləri hər iki temada ən azı 4.5:1 kontrast saxlayır; 24px-dən böyük və ya qalın 19px mətn, sərhədlər, fokus halqası və məna daşıyan ikonlar üçün minimum 3:1.
- Cədvəllər real `table` markup ilə qurulur, başlıqlar `th` + `scope`. Sətir-bazlı əməliyyatlar klaviatura ilə əlçatan olur.
- Status yalnız rənglə deyil, sözlə də bildirilir.
- `prefers-reduced-motion` aktivdirsə keçidlər söndürülür — bundle.css bunu öz üzərinə götürür.
