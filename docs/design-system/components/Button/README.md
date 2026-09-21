Sənəd əməliyyatlarını işə salan düymə; variantı əməliyyatın nəticəsi müəyyən edir, vizual üstünlüyü deyil.

## Nə vaxt

- `primary` — ekranın əsas nəticəsi: «Post et», «Təsdiqlə», «Yola sal». **Bir ekranda bir dənə.**
- `secondary` — paralel əməliyyatlar: «Qaralama saxla», «Çap et», «Excel-ə çıxar».
- `ghost` — cədvəl daxili və inline əməliyyatlar: «Sətir əlavə et», «Sil».
- `danger` — geri qaytarılmayan və ya ledger-ə toxunan destruktiv əməliyyat: «Storno et», «Ləğv et». Həmişə təsdiq modalı ilə cütləşir.

## Nəyi siz verirsiniz

`children` (əmr formasında qısa mətn), `onClick`, lazım olduqda `iconLeft`. Yüklənmə vəziyyətini `loading` ilə idarə edirsiniz — komponent özü sorğu göndərmir.

## Qaydalar

- Mətn əmr formasındadır: «Post et», «Təsdiqlə». «OK», «Bəli», «Ləğv» kimi ümumi sözlər işlədilmir.
- `loading` aktivdirsə düymə avtomatik `disabled` olur və `aria-busy` alır — ikiqat POST-un qarşısını alır. Server tərəfdə bunu `Idempotency-Key` qoruyur, interfeys onu təkrarlayır.
- Deaktiv düymənin **səbəbi** `title` ilə verilir: «Lokasiya sayım üçün dondurulub», «PO təsdiq gözləyir». Səbəbsiz deaktiv düymə buraxma.
- İkon tək başına düymə yaratma — bu komponent həmişə mətn tələb edir. İkonlu kompakt əməliyyat üçün `wms-iconbtn` sinfini işlət.
- Enini məcburi vermə; düymə məzmununa görə böyüyür, `loading` zamanı isə eni dəyişmir.
