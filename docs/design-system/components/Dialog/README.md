Modal pəncərə: təsdiq, səbəb tələbi, kiçik forma. Çox sətirli sənəd redaktəsi modalda yox, ayrıca səhifədə aparılır.

## Nə vaxt

- Destruktiv və ya geri qaytarılmayan əməliyyatın təsdiqi: storno, ləğv, sayımın dondurulması.
- Əməliyyatdan əvvəl məcburi sahənin alınması: səbəb kodu, fərq qeydi, təsdiq şərhi.
- Bir sətrin detalı — partiya seçimi, hərəkət tarixçəsi.

## Nəyi siz verirsiniz

`open` vəziyyəti, `title`, `children` (məzmun), `footer` (düymələr massivi), `onClose`. Komponent fokus idarəetməsini özü etmir — açılanda fokusu ilk interaktiv elementə yönəldin.

## Qaydalar

- `footer`-də düymələrin sırası: sağda təsdiq, solunda imtina. Təsdiq düyməsi əməliyyatın adını daşıyır («Storno et»), «OK» yox.
- Destruktiv əməliyyatda təsdiq düyməsi `variant="danger"` olur və **məcburi sahə doldurulana qədər `disabled` qalır**.
- Nəticəsi olan əməliyyat modal içində qısaca izah edilir: nə qədər dəyişəcək, hansı balansa toxunacaq.
- `size="lg"` yalnız cədvəl və ya yan-yana iki sütun məzmunu üçün.
- Modalın üstündə modal açma. İkinci qərar lazımdırsa birincini bağla.
- Scrim-ə klik `onClose` çağırır — məlumat itkisi riski varsa `onClose` vermə və yalnız footer düymələri qoy.
