# Ekran maketləri — WMS

Mənbə: Claude Artifact "WMS — ekran maketləri"
(https://claude.ai/artifact/M4fP1HuG1QNtVQqnPEKuXa), 21.09.2026-da güzgüləndi.

Beş artboard, hər biri 1440×960, `docs/design-system/` tokenləri və komponentləri ilə:

| Fayl | Ekran |
|---|---|
| `Main.dc.html` | Anbar paneli — KPI-lar, bitən partiyalar, təsdiq gözləyənlər |
| `Qebul.dc.html` | Anbara qəbul — sənəd başlığı, meta sahələr, sətir cədvəli, fərq göstəriciləri |
| `Mexaric.dc.html` | Filiala məxaric — partiya seçimi, FEFO xəbərdarlığı, ledger ön baxışı |
| `Sayim.dc.html` | Sayım və fərqlər — dondurma xəbərdarlığı, KPI-lar, fərq cədvəli |
| `PO-Tesdiq.dc.html` | Sifarişin təsdiqi — təsdiq zənciri |

## Layout qaydaları (hər beş ekrandan çıxarılıb)

- Kənar panel **248px**, `surface` fonu, sağda `border`. Qrup başlıqları `ink-subtle`,
  12px, 600 çəki. Aktiv bənd `accent-soft` fonu + `accent` mətn.
  Ən altda istifadəçi bloku: 32px dairəvi initial, ad, rol kodu.
- Başlıq zolağı: siyahı ekranlarında **72px**, sənəd ekranlarında **84px**.
  Sənəd ekranında breadcrumb, sonra sənəd nömrəsi (`wms-num`, 20px/600) +
  `DocStatusBadge` + kontekst nişanları. Sağda əməliyyat düymələri:
  ghost, secondary, primary — bu sıra ilə, ekranda **bir dənə primary**.
- Məzmun: `padding: 20px 32px`, bloklar arası `gap: 16px`.
- Sənəd səviyyəli xəbərdarlıq `Alert` ilə ən yuxarıda, `code` görünən şəkildə.
- KPI sırası: `grid-template-columns: repeat(4, minmax(0, 1fr))`, `gap: 12px`.
- İki sütunlu məzmun: `minmax(0, 1.45fr) minmax(0, 1fr)` (panel) və ya
  `minmax(0, 1fr) minmax(0, 1.05fr)` (məxaric).
- Kart: `surface` fonu, `border`, `radius-lg`. Başlıq zolağı `padding: 14px 16px`,
  altında `border`. Kart daxili `padding: 16px`.
- Cədvəl `wms-table wms-table--dense`, sticky başlıq, rəqəm sütunları `wms-td--num`.
  `tfoot` yalnız cəmlənə bilən sütunlar üçün.
- Redaktə olunan sətir `accent-soft` fonu ilə seçilir.

Bu fayllar `.dc.html` formatındadır və birbaşa işlədilmir — onlar React
tətbiqinin (`web/`) vizual mənbəyidir. Dəyərlər `docs/design-system/tokens.json`
faylından gəlir.
