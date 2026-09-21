Sənəd və partiya statusunu göstərən nişan: ENUM dəyərini Azərbaycanca ada və tona çevirir. **Sistemdə status göstərilən hər yerdə yalnız bu komponent işlədilir.**

## Nəyi siz verirsiniz

`status` — serverin qaytardığı ENUM dəyəri (`DRAFT`, `PENDING_APPROVAL`, `POSTED`, `EXPIRED` və s.), olduğu kimi. Tərcümə və rəng komponentin daxilindədir.

## Qaydalar

- **Öz status badge-ini yazma.** Eyni ENUM iki ekranda iki cür adlanırsa, istifadəçi sistemin iki sənədi olduğunu düşünür. Yeni status əlavə olunanda `DocStatusBadge.statuses` xəritəsini genişləndir.
- Ton qaydası: tamamlanmış müsbət nəticə `success`, gözləyən və ya diqqət tələb edən `warning`, dayandırılmış və ya uğursuz `danger`, hərəkətsiz vəziyyət `neutral`, davam edən proses `accent`.
- Nişan həmişə **söz** daşıyır — rəng köməkçidir. Nöqtə ilə rəng cütlüyü tək başına məna vermir.
- ENUM dəyəri `title` atributunda saxlanılır: dəstək və QA orijinal kodu hover ilə görə bilər.
- Naməlum status gəlirsə komponent dəyəri olduğu kimi neytral tonda göstərir — boş yer buraxmır. Belə hal görürsənsə xəritə köhnəlib.
- Sənəd tipi ilə birlikdə göstərmə lazımdırsa, tipi ayrıca `doc-no` stilində yanında yaz: `GR-2026-00311` · nişan.
