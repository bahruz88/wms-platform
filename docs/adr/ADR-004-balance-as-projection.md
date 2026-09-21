# ADR-004: Balans yalnız proyeksiyadır

**Status:** Qəbul edilib
**Mənbə:** [SPEC §2 → ADR-004](../SPEC-Satinalma-Anbar-Platformasi.md#adr-004-balans-yalnız-proyeksiyadır), icra qaydası [§12.2](../SPEC-Satinalma-Anbar-Platformasi.md#122-balans-yalnız-ledger-dən-törəyir)

## Kontekst

Excel-də qalıq birbaşa redaktə olunurdu: dörd sətirdə düstur əl ilə rəqəmlə əvəzlənmişdi.
Nəticədə qalığın mənbəyi yox idi və səhvi aşkar etmək mümkün deyildi. Eyni risk
verilənlər bazasında da var: `UPDATE inv_balance SET qty_on_hand = ...` yazan bir sətir kod
bütün auditi mənasızlaşdırır.

## Qərar

`inv_balance` **törəmə cədvəldir** (proyeksiya). O, yalnız `inv_movement` sətri yazılan
tranzaksiyada və yalnız `SELECT ... FOR UPDATE` ilə kilidlənmiş sətir üzərində yenilənir.
Heç bir kod yolu balansı birbaşa təyin edə bilməz — belə kod **buq sayılır**.

## Nəticələr

- Yeganə icazəli ardıcıllıq: `FOR UPDATE` → movement INSERT → balance UPDATE → outbox INSERT → COMMIT.
- Gecə `BalanceReconciliation` job-u `SUM(inv_movement.qty_base)` ilə `inv_balance.qty_on_hand`-i
  tutuşdurur; fərq **kritik alert** deməkdir — bu, tranzaksiya buqunun siqnalıdır (SPEC §15).
- Arxitektura testi `inv_balance`-a birbaşa `SaveChanges` yolunun olmamasını yoxlayır (SPEC §17.4).
- İnterfeysdə heç bir ekranda qalıq **input** kimi göstərilmir (dizayn sistemi qaydası) —
  dəyişiklik yalnız sənədlə olur.
- Qarşılığında: `FOR UPDATE` sətir kilidi paralel məxariclərdə gözləmə yaradır; buna görə
  partiya ayırması `SKIP LOCKED` ilə işləyir və kilid müddəti minimal saxlanılır.
