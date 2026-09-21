# ADR-002: Inventory bölünmür

**Status:** Qəbul edilib
**Mənbə:** [SPEC §2 → ADR-002](../SPEC-Satinalma-Anbar-Platformasi.md#adr-002-inventory-bölünmür)

## Kontekst

Mikroservis instinkti Receiving, Issue, Transfer, Waste, Sample, Count, Batch və Balance-i
ayrı servislərə bölməyi təklif edir. Lakin bu əməliyyatların hamısı **eyni** cədvəllərə
toxunur: `inv_balance`, `inv_batch`, `inv_movement`. Bölgü halında ən sadə məxaric belə
paylanmış tranzaksiyaya (saga + kompensasiya) çevrilir; kompensasiya uğursuz olduqda
balans səhv qalır və bunu yalnız gecə reconciliation aşkar edir.

## Qərar

Inventory **tək servis, tək cədvəl prefiksi (`inv_`), tək ACID tranzaksiya** olaraq qalır.
Bir sənədin post edilməsi — partiya, ledger sətirləri, balans yeniləməsi və outbox qeydi —
hamısı bir MySQL tranzaksiyasında baş verir.

## Nəticələr

- Stok invariantları (mənfi qalıq yoxdur, qrup cəmi sıfırdır) **kod səviyyəsində** deyil,
  tranzaksiya səviyyəsində təmin olunur.
- Inventory ən çox yüklənən moduldur; cloud profilində 3 replika ilə horizontal scale olunur
  (SPEC §18.1) — bölgüsüz də scale mümkündür, çünki darboğaz DB-dir, kod deyil.
- Qarşılığında: Inventory ən böyük moduldur və onun daxili strukturu (feature qovluqları,
  aggregate sərhədləri) xüsusi diqqət tələb edir.
- Bu qərar tenderdə müdafiə olunmalıdır: "anbar əməliyyatları bir consistency sərhədidir"
  arqumenti texniki, ideoloji deyil.
