# Yük testi — SPEC §17.3

Spesifikasiyanın yeganə rəqəmli qəbul meyarı:

> 100 eyni vaxtlı istifadəçi, 2 000 hərəkət/saat, 1 000 000 mövcud `inv_movement` sətri ilə.
> Hədəf: **p95 < 2 san**.

## İşlətmək

```bash
scripts/load-test.sh                      # dev stack-ə qarşı, tam ssenari
scripts/load-test.sh --vus 20 --duration 2m   # daha yüngül sınaq
scripts/load-test.sh --base http://gateway:8080
```

Skript k6-nı Docker-dən işlədir — yerli quraşdırma lazım deyil.

## Ssenarilər

İki ssenari paralel işləyir, çünki meyar ikisini birlikdə tələb edir:

| ssenari | nə edir | niyə |
|---|---|---|
| `browse` | 100 VU, oxu sorğuları: qalıqlar, məhsullar, sənəd siyahıları, panel | «100 eyni vaxtlı istifadəçi» — p95 bu ssenariyə görə ölçülür |
| `post` | sabit sürətlə qəbul sənədi yaradır və post edir | «2 000 hərəkət/saat» — hər sətir ikitərəfli yazılışda 2 hərəkət verir, yəni 1 000 sətir/saat |

`post` ssenarisi qəsdən p95 hədəfindən kənardadır: sənəd post etmək mühasibat
yazılışıdır, siyahı açmaq deyil, və onları bir eşiyə yığmaq ölçünü mənasız edərdi.
Onun öz eşiyi var və uğursuzluq nisbəti sıfır olmalıdır.

## 1 000 000 sətir

Meyar mövcud ledger ölçüsünü tələb edir, çünki sorğuların planı sətir sayından
asılıdır. Ledger yalnız əlavə olunandır (ADR-003) və balans onun proyeksiyasıdır
(ADR-004), ona görə sətirləri əl ilə yazmaq balansı da yenidən hesablamağı tələb
edir — əks halda §12.2 invarianti (hər balans sətri öz ledger sətirlərinin cəmidir)
qırılır.

`scripts/seed-ledger.py` bunu edir: balanslaşdırılmış cütlər yazır və sonra
`inv_balance`-ı onlardan yenidən hesablayır. **Yalnız sınaq mühitində** işlədilir.

```bash
scripts/seed-ledger.py --target 1000000        # nə qədər lazımdırsa əlavə edir
scripts/seed-ledger.py --target 1000000 --check   # yalnız hesabat, yazmır
```

## Ölçülmüş nəticə

Dev stack-ə qarşı, 2026-09-28:

| | dəyər | hədəf |
|---|---|---|
| eyni vaxtlı istifadəçi | 100 VU | 100 |
| müddət | 3 dəq | — |
| **p95 (browse)** | **9,18 ms** | < 2 000 ms |
| p95 (sənəd post) | 35,99 ms | (öz eşiyi: 10 s) |
| uğursuz sorğu | 0 / 18 070 | < 1 % |
| hərəkət sürəti | 2 023/saat | 2 000/saat |
| mövcud `inv_movement` | **1 204** | **1 000 000** |

Son sətir meyarın hələ tam ödənmədiyini bildirir: ölçmə kiçik ledger üzərində
aparılıb. `inv_movement` üzrə sorğuların planı sətir sayından asılıdır —
`ix_mv_balance` indeksi min sətirdə fərqli, milyonda fərqli davranır. Ona görə
9 ms rəqəmi alətin işlədiyini və 100 istifadəçinin platformanı yormadığını
göstərir, §17.3-ün ödəndiyini isə yox.

Tam meyar üçün əvvəlcə `scripts/seed-ledger.py --target 1000000`, sonra yenidən
ölçmə lazımdır. Toxumlama geri qaytarılmır (ledger yalnız əlavə olunandır,
ADR-003), ona görə alət açıq təsdiq tələb edir.
