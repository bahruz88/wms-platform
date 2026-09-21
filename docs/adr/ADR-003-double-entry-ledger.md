# ADR-003: İkili yazılışlı (double-entry) stok ledger-i

**Status:** Qəbul edilib
**Mənbə:** [SPEC §2 → ADR-003](../SPEC-Satinalma-Anbar-Platformasi.md#adr-003-i̇kili-yazılışlı-double-entry-stok-ledger-i), detallar [§12.3](../SPEC-Satinalma-Anbar-Platformasi.md#123-i̇kili-yazılış--hər-sənəd-sıfıra-balanslaşır)

## Kontekst

Mövcud Excel prosesində tullantı və AQTA nümunəsi hesablama düsturundan **kənarda** qalırdı;
qalıq artımlarının mənbəyi yox idi və `+510` kimi izahsız sabitlər düsturun içində yaşayırdı.
Yəni sistemin özünü yoxlaya biləcəyi heç bir mexanizm yox idi.

## Qərar

Hər sənəd bir `inv_movement_group` yaradır; hər hərəkət sətri **işarəli** `qty_base` daşıyır
(+ mədaxil, − məxaric); **hər qrupun cəmi sıfıra bərabər olmalıdır**. Qarşı tərəf həmişə
mövcuddur: Supplier, Waste, Sample, In-Transit və Adjustment virtual lokasiyalar kimi
modelləşdirilir (`master_location.is_virtual`).

## Nəticələr

- `SELECT group_id, SUM(qty_base) ... HAVING SUM(qty_base) <> 0` həmişə boş nəticə verməlidir —
  bu, `DoubleEntryCheck` gecə job-unun və integration testlərin invariantıdır (SPEC §15).
- Tullantı və nümunə ledger-in **bir hissəsidir**, ayrıca sütun deyil; beləliklə Excel-in
  əsas nasazlığı struktur səviyyəsində təkrarlana bilmir.
- Hər hərəkət `unit_cost` daşıdığı üçün tullantının və kəsirin manatla dəyəri hesablanır.
- Qarşılığında: hər əməliyyat ən azı iki sətir yazır — ledger həcmi iki dəfə böyükdür və
  `inv_movement` illik partisiyalarla saxlanılır.
- Virtual lokasiyalar tenant seed-inin məcburi hissəsidir; onlarsız heç bir sənəd post edilə bilməz.
