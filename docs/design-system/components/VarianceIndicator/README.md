Sayım sətrində sistem qalığı ilə sayılan miqdar arasındakı fərqi, faizini və bu fərqin hansı prosedur tələb etdiyini göstərir.

## Nəyi siz verirsiniz

`book` (dondurma anındakı `book_qty`), `counted`, `uom`, `decimals`. Hədd `inv_setting.count_variance_approval_threshold_pct`-dən `thresholdPct` kimi ötürülür. Seçilmiş səbəb kodu `reasonCode`.

## Qaydalar

- Fərq həmişə **işarəli** göstərilir: `+6,000` artıqlıq, `−2 600,000` kəsir. Faiz onun yanında `figure-sm` ilə.
- `thresholdPct`-dən yuxarı fərq «Təsdiq tələb edir» nişanı alır. Bu nişan göründükdə sənəd birbaşa post edilə bilməz — `inv.adjustment.approve` icazəsi olan istifadəçidən keçir.
- **Fərq varsa və səbəb kodu yoxdursa «Səbəb kodu yoxdur» nişanı çıxır.** Bu, forma validasiyasının vizual əkizidir: `reason_code_id` sıfırdan fərqli variance üçün məcburidir. Excel-dəki izahsız `+510` sabitinin bu sistemdə qarşılığı yoxdur.
- Sıfır fərq neytral rəngdədir — «yaxşı» kimi yaşıllanmır. Sayımda sıfır fərq gözlənilən nəticədir, nailiyyət deyil.
- Fərqin manatla dəyəri lazımdırsa onu ayrıca sütunda ver və `master.product.view_cost` icazəsinə bağla.
- `book = 0` olduqda faiz 100% kimi göstərilir; bu, «sistemdə olmayan mal sayıldı» halıdır və həmişə təsdiq tələb edir.
