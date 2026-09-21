Qapalı siyahıdan bir dəyərin seçimi: lokasiya, səbəb kodu, valyuta, ölçü vahidi, strategiya.

## Nəyi siz verirsiniz

`label`, `value`, `options` (`{value, label, disabled}`), `onChange`. `placeholder` boş vəziyyət üçün, `hint` / `error` `TextField`-dəki kimi.

## Qaydalar

- 12-dən çox variant varsa axtarışlı komponent (typeahead) işlət — native `select` uzun məhsul siyahısı üçün yaramır.
- Seçilə bilməyən variantı **siyahıdan çıxarma, `disabled` et və səbəbi etiketə yaz**: «Non-Food WH (qida qəbul etmir)». İstifadəçi variantın mövcud olduğunu, amma qadağan olduğunu bilməlidir.
- Lokasiya siyahısı `iam_user_location` ilə filtrlənir. Bunu `hint` ilə açıqla ki, istifadəçi «anbarım siyahıda yoxdur» deyə düşünməsin.
- Səbəb kodu siyahısı `reason_group`-a görə filtrlənir: tullantı sənədində yalnız `WASTE` qrupu görünür.
- Defolt dəyər varsa onu seçili göstər; boş `placeholder` yalnız həqiqətən seçim tələb olunanda işlədilir.
- Sıralama `name_sort_key` üzrədir — Azərbaycan əlifba sırası brauzerin öz müqayisəsindən fərqlidir.
