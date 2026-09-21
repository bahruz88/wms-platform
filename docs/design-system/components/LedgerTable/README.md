Bir `movement_group`-un hərəkət sətirlərini ikili yazılış məntiqi ilə göstərir və qrup cəminin sıfır olduğunu istifadəçinin gözü qarşısında yoxlayır.

## Nəyi siz verirsiniz

`lines` — `inv_movement` sətirləri (`lineNo`, `product`, `sku`, `batchNo`, `location`, `locationType`, işarəli `qtyBase`, `uom`, `unitCost`). `decimals` məhsulun base vahidindən. Maya sütunu üçün `showCost` — yalnız `master.product.view_cost` icazəsi varsa.

## Qaydalar

- **İşarə gizlədilmir.** Müsbət miqdar `+`, mənfi `−` ilə göstərilir və `ledger-in` / `ledger-out` rəngini alır. Rəng dublikatdır, işarə əsasdır.
- **Virtual lokasiyalar nişanlanır.** `V_SUPPLIER`, `V_WASTE`, `V_SAMPLE`, `V_ADJUSTMENT`, `IN_TRANSIT` — `virtual` tonunda badge alır ki, fiziki anbarla qarışmasın. Excel prosesində tullantı və AQTA nümunəsinin hesablamadan kənarda qalması məhz bu ayrılığın olmamasından idi.
- **Balans yoxlanışı sətri həmişə göstərilir.** Cəm sıfır deyilsə qırmızı və açıq mətnlə bildirilir: sənəd post edilə bilməz. Bu, gecə işləyən `DoubleEntryCheck` job-unun interfeysdəki əkizidir.
- Sətirlər redaktə olunmur. `inv_movement` append-only-dir; düzəliş yalnız `REVERSAL` qrupu ilə olur. Bu cədvəldə «Redaktə et» düyməsi olmamalıdır.
- Qrup başlığını (sənəd nömrəsi, tip, status, post edən, tarix) cədvəlin üstündə ayrıca ver — komponent yalnız sətirləri göstərir.
- Sənəd tipi `TRANSFER` olduqda sətirlər cütlüklər halında gəlir (mənbə −, `IN_TRANSIT` +). Sıranı serverdən gəldiyi kimi saxla — `line_no` sənədin öz sırasıdır.
