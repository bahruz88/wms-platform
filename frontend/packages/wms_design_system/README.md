# wms_design_system

«WMS Enterprise» dizayn sisteminin Flutter tətbiqi (`docs/design-system/`).
Tokenlər `tokens.json`-dan, komponent ölçüləri `components/bundle.css`-dən hərfi köçürülüb.

- `WmsTheme.light()` / `WmsTheme.dark()` — Material 3 `ThemeData`; rənglər `WmsColors` extension-dadır.
- `WmsFormat` — vergül onluq, dar boşluq (U+202F) min ayırıcı, U+2212 mənfi işarə.
- Komponentlər: `WmsButton`, `WmsBadge`, `WmsDocStatusBadge`, `WmsAlert`, `WmsTextField`, `WmsSelect`,
  `WmsQtyUomInput`, `WmsDataTable`, `WmsLedgerTable`, `WmsBatchPicker`, `WmsApprovalChain`,
  `WmsVarianceIndicator`, `WmsKpiCard`, `WmsDialog`, `WmsEmptyState`.
