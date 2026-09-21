/**
 * WMS Enterprise design system — the React port of docs/design-system/.
 *
 * `components/bundle.css` is copied in verbatim (bundle.css); `tokens.css` is generated from
 * `tokens.json` by scripts/gen-tokens.mjs, so the two can never drift. The component API follows
 * `components/index.d.ts`; the behaviour rules come from the 14 `components/<Name>/README.md`
 * files and are cited in each module.
 *
 * Nothing here loads `window.Wms`: these are typed ESM React modules (ADR-013).
 */
import './styles.css';

export { Alert, type AlertProps } from './Alert';
export {
  ApprovalChain,
  resolveCurrentStep,
  type ApprovalChainProps,
  type ApprovalStep,
} from './ApprovalChain';
export { Badge, type BadgeProps, type Tone } from './Badge';
export {
  BatchPicker,
  isSelectableBatch,
  sortBatches,
  suggestedBatchId,
  type Batch,
  type BatchPickerProps,
} from './BatchPicker';
export { Button, type ButtonProps } from './Button';
export { DataTable, visibleColumns, type Column, type DataTableProps } from './DataTable';
export { Dialog, type DialogProps } from './Dialog';
export { DocStatusBadge, type DocStatusBadgeProps } from './DocStatusBadge';
export { Field, type FieldProps } from './Field';
export { Icons, type IconName } from './Icons';
export { KpiCard, type KpiCardProps } from './KpiCard';
export {
  LedgerTable,
  isVirtualLocationType,
  type LedgerLine,
  type LedgerTableProps,
} from './LedgerTable';
export { QtyUomInput, type ProductUom, type QtyUomInputProps } from './QtyUomInput';
export { Select, type SelectOption, type SelectProps } from './Select';
export { TextField, type TextFieldProps } from './TextField';
export {
  VarianceIndicator,
  computeVariance,
  type VarianceIndicatorProps,
  type VarianceResult,
} from './VarianceIndicator';
export { format, type WmsFormat } from './format';
