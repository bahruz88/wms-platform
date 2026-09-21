Miqdar sahəsi ilə ölçü vahidi seçimini bir nəzarət elementində birləşdirir və base UoM ekvivalentini canlı göstərir. **Sistemdə miqdar daxil edilən hər yerdə bu komponent işlədilir.**

## Nəyi siz verirsiniz

`uoms` (`master_product_uom` sətirləri — base UoM də daxil, `factorToBase: 1` ilə), `baseUomCode`, `decimals` (`base_uom.decimals`), `qty` / `uomId` dəyərləri və `onQtyChange` / `onUomChange`.

## Qaydalar

- **Base ekvivalenti gizlətmə.** Seçilmiş vahid base-dən fərqlidirsə, sahənin altında `= <miqdar> <base kod> · əmsal <n>` göstərilir. Excel prosesində itən məhz bu addım idi: `1 QUTUDA` sütunu heç bir hesablamada iştirak etmirdi.
- Rəqəm sahəsi **sağa düzlənir və mono ailədədir** — sütun boyu onluqlar düzülür.
- `decimals` məhsulun base vahidindən gəlir, sabit yazılmır. Göstərilən dəyər kəsilmir, yuvarlaqlaşdırma `MidpointRounding.AwayFromZero` ilə serverdə olur.
- Mənfi miqdar daxil edilə bilməz. İşarə sənəd tipindən törəyir (məxaric mənfidir), istifadəçidən deyil.
- Mövcud qalıqdan çox miqdar üçün `error` göstər və **mövcud qalığı da yaz** — istifadəçi nə qədər düzəltməli olduğunu bilsin.
- Vahid dəyişdikdə miqdarı avtomatik çevirmə: istifadəçi «8 CASE» yazıbsa və `PCS`-ə keçirsə, rəqəm 8 qalır, base ekvivalenti dəyişir. Səssiz çevirmə səhv sənədin ən qısa yoludur.
