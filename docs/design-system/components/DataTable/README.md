Sistemin əsas data səthi: qalıqlar, sənəd sətirləri, hesabat nəticələri. Sticky başlıq, sıx sətirlər, sağa düzlənmiş rəqəm sütunları və icazəyə bağlı sütun gizlətməsi ilə.

## Nəyi siz verirsiniz

`columns` (`{key, header, numeric, decimals, width, align, render, permission}`), `rows`, `rowKey`. İxtiyari: `permissions` (istifadəçinin icazə kodları), `dense`, `footer`, `maxHeight`, `empty`, `onRowClick`, `selectedKey`.

Səhifələmə, sıralama və filtr komponentdən kənardadır — server `{items, page, size, total}` qaytarır, siz idarə edirsiniz.

## Qaydalar

- **Rəqəm sütununa `numeric: true` ver.** Bu, sütunu sağa düzləndirir və mono + tabular rəqəmlərə keçirir. `decimals` məhsulun base vahidindən gəlir.
- **Qiymət sütununa `permission: "master.product.view_cost"` ver.** İcazə yoxdursa sütun ümumiyyətlə render edilmir — boş xana və ya `***` göstərmək icazə modelinin sızmasıdır. Server də həmin sahələri JSON-dan çıxarır; interfeys bunu təkrarlayır, əvəz etmir.
- `empty` mətni səbəbi və növbəti addımı deyir: «Bu lokasiyada qalıq yoxdur. Qəbul sənədi yaradın.»
- `footer` yalnız cəmlənə bilən sütunlar üçündür. Orta qiymət və faiz cəmlənmir — onları footer-ə yazma.
- Sətir klik edilə biləndirsə (`onRowClick`) həmin əməliyyat klaviatura ilə də əlçatan olmalıdır — sətir daxilində bir fokuslana bilən element saxla.
- `dense` sənəd sətirləri və qalıq siyahıları üçün defoltdur; geniş sətir yalnız çox sətirli məzmunda işlədilir.
- 200-dən çox sətir göstərmə — server `size` limiti 200-dür, virtualizasiya lazımdırsa bu komponentdən kənarda həll et.
