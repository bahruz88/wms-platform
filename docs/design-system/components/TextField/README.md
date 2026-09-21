Bir sətirlik mətn sahəsi etiket, izah və xəta ilə. Miqdar üçün bunu işlətmə — `QtyUomInput` işlət.

## Nəyi siz verirsiniz

`label`, `value`, `onChange`. İxtiyari: `hint` (sahənin qaydası), `error` (validasiya nəticəsi), `required`, `mono` (SKU, barkod, sənəd nömrəsi), `align="right"`.

## Qaydalar

- Etiket həmişə görünür. Placeholder etiketi əvəz etmir; placeholder yalnız format nümunəsi göstərir.
- `mono` — identifikator daşıyan hər sahə üçün: SKU, barkod, partiya nömrəsi, VÖEN, sənəd nömrəsi. Səbəb: simvol-simvol müqayisə bu sahələrdə adi haldır.
- `error` verildikdə `hint` gizlənir — ikisi eyni anda göstərilmir. Xəta mətni nə edilməli olduğunu deyir: «Bu barkod artıq CHS-0042 məhsuluna bağlıdır».
- Məcburi sahə `required` ilə ulduz alır; ulduzu əl ilə etiketə yazma.
- Yalnız oxunan dəyər üçün `readOnly` işlət, `disabled` yox — `disabled` sahə klaviatura ilə seçilə bilmir və dəyər kopyalana bilmir.
- Sahə bazada `TRIM` edilirsə, bunu `hint` ilə de — istifadəçi boşluğun itməsinə hazır olsun.
