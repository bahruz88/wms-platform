Sənədin təsdiq zəncirini addım-addım göstərir: kim, hansı rolla, nə vaxt, hansı şərhlə qərar verib və indi kim gözlənilir.

## Nəyi siz verirsiniz

`steps` — `proc_approval_step` sətirləri (`stepNo`, `role`, `user`, `decision`, `decidedAt`, `comment`, `delegatedFrom`). `currentStep` verilməzsə ilk `PENDING` addım cari sayılır.

## Qaydalar

- **Bütün addımlar göstərilir**, hələ çatmamışlar da. İstifadəçi sənədin daha neçə mərhələ keçəcəyini əvvəlcədən bilməlidir; gözlənilən addımlar `opacity-pending` ilə sönükdür.
- Cari addım `warning` tonlu saat ikonu ilə nişanlanır — rəng tək deyil, ikon və status nişanı da var.
- **Delegasiya gizlədilmir.** Qərarı əvəzedici veribsə, kimin adından verildiyi «Delegasiya: <ad>» nişanı ilə yazılır. Audit üçün bu, adın özü qədər vacibdir.
- Rədd edilmiş addımdan sonrakılar gözlənilən kimi qalır, zəncir kəsilmir — sənəd yenidən təqdim olunduqda eyni zəncir işə düşür.
- Şərh varsa göstər. Xüsusilə ən ucuz təklif seçilmədikdə `selection_note` bu sahədə görünməlidir.
- Təsdiq və rədd düymələri komponentin daxilində deyil — onları sənəd toolbar-ında, istifadəçinin `proc.po.approve` icazəsi və cari addımın sahibi olmasına görə göstər.
- Rol kodları böyük hərflə gəlir (`PROCUREMENT_MANAGER`); onları olduğu kimi göstərmək qəsdəndir — icazə modelində eyni kodla axtarılır.
