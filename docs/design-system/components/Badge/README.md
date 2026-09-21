Qısa nişan: vəziyyət, kateqoriya, sayğac. Sənəd statusu üçün bunu birbaşa işlətmə — `DocStatusBadge` işlət.

## Nə vaxt

- `neutral` — məlumat nişanı, kateqoriya, seçilmiş filtr.
- `accent` — davam edən proses və ya sistem təklifi («FEFO təklifi»).
- `success` / `warning` / `danger` — vəziyyət siqnalı.
- `virtual` — yalnız virtual lokasiyalar üçün: `V_SUPPLIER`, `V_WASTE`, `V_SAMPLE`, `V_ADJUSTMENT`, `IN_TRANSIT`.
- `variant="solid"` — sayğac (oxunmamış bildiriş, sətir sayı).
- `variant="outline"` — parametr dəyəri, məs. ayırma strategiyası.

## Nəyi siz verirsiniz

`children` mətni və `tone`. Rəqəm nişanında mətn artıq formatlanmış olmalıdır.

## Qaydalar

- **Mətn məcburidir.** Rəng tək başına məna daşımır; boş rəngli nöqtə buraxma. `dot` yalnız mətnin yanında müşayiətçidir.
- Mətn 2–3 sözdən uzun olmamalıdır; uzun izah `caption` ilə yan sətirdə verilir.
- Nişan klik edilə bilən deyil. Filtr silmək kimi əməliyyat lazımdırsa `Button` `size="sm"` işlət.
- `virtual` tonu yalnız lokasiya tipi üçündür — başqa mənada işlədilməsi ledger oxunuşunu pozur.
