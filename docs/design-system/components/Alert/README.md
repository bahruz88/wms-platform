Blok səviyyəsində mesaj: server xətası, əməliyyat bloku, uğur təsdiqi. Sahə səviyyəli validasiya xətası buraya yox, `TextField`-in `error` sahəsinə gedir.

## Nə vaxt

- `danger` — sorğu rədd edildi və istifadəçi davam edə bilmir: `INSUFFICIENT_STOCK`, `STALE_VERSION`, `LOCATION_FROZEN`.
- `warning` — əməliyyat mümkündür, amma əlavə addım tələb edir: PO toleransı aşıldı, expiry yaxınlaşır, FEFO təklifindən kənar seçim.
- `success` — post, təsdiq, göndərmə tamamlandı. Sənəd nömrəsini başlıqda ver.
- `info` — kontekst məlumatı, blok deyil.

## Nəyi siz verirsiniz

`title` (bir cümlə), `children` (detal), `code` və `traceId` server cavabından. `onClose` yalnız `info` üçün verilir.

## Qaydalar

- **RFC 7807 cavabını olduğu kimi köçür:** `title` → `title`, `detail` → `children`, `code` → `code`, `traceId` → `traceId`. Mesajı öz sözlərinlə yenidən yazma — dəstək komandası eyni mətni görməlidir.
- `code` gizlədilmir. O, istifadəçi üçün deyil, dəstək üçündür və `ink-muted` ilə kiçik göstərilir.
- `danger` tonu `role="alert"` alır və ekran oxuyucuya dərhal elan edilir; digər tonlar `role="status"`.
- Xəta sahəyə aiddirsə (bir sətrin miqdarı), sahənin özündə göstər; `Alert` yalnız sənəd səviyyəli problem üçündür.
- Bir ekranda ikidən çox `Alert` yığılmır — üçüncüsü çıxırsa siyahı halına gətir.
