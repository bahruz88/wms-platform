// WMS Enterprise — komponent API-si. Sənədləşdirmə üçündür, tip yoxlamasına daxil deyil.
// Qlobal: window.Wms (classic script, React 18 tələb olunur).

import type { ReactNode, ChangeEvent } from "react";

export type Tone = "neutral" | "accent" | "success" | "warning" | "danger" | "virtual";

export interface ButtonProps {
  /** Ekranda yalnız bir `primary` olur. `danger` yalnız geri qaytarılmayan əməliyyat üçün. */
  variant?: "primary" | "secondary" | "ghost" | "danger";
  size?: "md" | "sm";
  disabled?: boolean;
  /** Düymə enini saxlayır, mətnin yanında spinner göstərilir. */
  loading?: boolean;
  iconLeft?: ReactNode;
  type?: "button" | "submit" | "reset";
  title?: string;
  onClick?: (e: unknown) => void;
  children?: ReactNode;
}
export function Button(p: ButtonProps): JSX.Element;

export interface BadgeProps {
  tone?: Tone;
  variant?: "soft" | "solid" | "outline";
  /** Rəngin yanında kiçik nöqtə — status siyahılarında oxunuşu artırır. */
  dot?: boolean;
  icon?: ReactNode;
  title?: string;
  children?: ReactNode;
}
export function Badge(p: BadgeProps): JSX.Element;

export interface DocStatusBadgeProps {
  /** Spesifikasiyanın ENUM dəyəri: DRAFT, PENDING_APPROVAL, POSTED, EXPIRED … */
  status: string;
  /** Standart Azərbaycanca adı əvəz edir. Yalnız zəruri halda. */
  label?: string;
}
export function DocStatusBadge(p: DocStatusBadgeProps): JSX.Element;
export namespace DocStatusBadge {
  /** ENUM → [Azərbaycanca ad, tone] xəritəsi. */
  const statuses: Record<string, [string, Tone]>;
}

export interface AlertProps {
  tone?: "info" | "success" | "warning" | "danger";
  title?: ReactNode;
  /** RFC 7807 `code` — dəstək bu kodla işləyir, gizlətmə. */
  code?: string;
  traceId?: string;
  onClose?: () => void;
  children?: ReactNode;
}
export function Alert(p: AlertProps): JSX.Element;

export interface FieldProps {
  label?: ReactNode;
  htmlFor?: string;
  required?: boolean;
  hint?: ReactNode;
  /** Verilibsə `hint` gizlənir və sərhəd `danger`-ə keçir. */
  error?: ReactNode;
  children?: ReactNode;
}
export function Field(p: FieldProps): JSX.Element;

export interface TextFieldProps extends FieldProps {
  id?: string;
  name?: string;
  type?: string;
  value?: string | number;
  onChange?: (e: ChangeEvent<HTMLInputElement>) => void;
  placeholder?: string;
  disabled?: boolean;
  readOnly?: boolean;
  maxLength?: number;
  /** SKU, barkod, sənəd nömrəsi üçün mono ailə. */
  mono?: boolean;
  align?: "left" | "right";
}
export function TextField(p: TextFieldProps): JSX.Element;

export interface SelectOption { value: string | number; label: string; disabled?: boolean }
export interface SelectProps extends FieldProps {
  id?: string;
  name?: string;
  value?: string | number;
  options: SelectOption[];
  placeholder?: string;
  onChange?: (e: ChangeEvent<HTMLSelectElement>) => void;
  disabled?: boolean;
}
export function Select(p: SelectProps): JSX.Element;

export interface ProductUom { id: string | number; code: string; factorToBase: number }
export interface QtyUomInputProps extends FieldProps {
  id?: string;
  name?: string;
  qty?: string | number;
  uomId?: string | number;
  /** `master_product_uom` sətirləri. Base UoM də siyahıda olmalıdır (factor = 1). */
  uoms: ProductUom[];
  baseUomCode?: string;
  /** `base_uom.decimals` — base ekvivalenti bu qədər onluqla göstərilir. */
  decimals?: number;
  onQtyChange?: (value: string, e: ChangeEvent<HTMLInputElement>) => void;
  onUomChange?: (uomId: string, e: ChangeEvent<HTMLSelectElement>) => void;
  disabled?: boolean;
  placeholder?: string;
}
export function QtyUomInput(p: QtyUomInputProps): JSX.Element;

export interface Column<R = any> {
  key: string;
  header: ReactNode;
  width?: string;
  align?: "left" | "center" | "right";
  /** Sağa düzlənir, mono + tabular rəqəmlərlə göstərilir. */
  numeric?: boolean;
  decimals?: number;
  render?: (row: R, index: number) => ReactNode;
  /** Verilibsə sütun yalnız bu icazə `permissions`-də olduqda render edilir. */
  permission?: string;
}
export interface DataTableProps<R = any> {
  columns: Column<R>[];
  rows: R[];
  /** İstifadəçinin icazə kodları, məs. ["master.product.view_cost"]. */
  permissions?: string[];
  rowKey?: (row: R, index: number) => string | number;
  dense?: boolean;
  caption?: ReactNode;
  label?: string;
  /** Boş vəziyyət mətni — səbəbi və növbəti addımı yaz. */
  empty?: ReactNode;
  footer?: Record<string, ReactNode | number>;
  maxHeight?: string;
  selectedKey?: string | number;
  onRowClick?: (row: R, index: number) => void;
}
export function DataTable<R = any>(p: DataTableProps<R>): JSX.Element;

export interface KpiCardProps {
  label: ReactNode;
  value: number | string;
  decimals?: number;
  unit?: string;
  /** Əvvəlki dövrə görə dəyişmə. İşarə avtomatik əlavə olunur. */
  delta?: number;
  deltaUnit?: string;
  deltaDecimals?: number;
  deltaTone?: "up" | "down" | "flat";
  badge?: ReactNode;
  hint?: ReactNode;
}
export function KpiCard(p: KpiCardProps): JSX.Element;

export interface LedgerLine {
  lineNo: number;
  product: string;
  sku?: string;
  batchNo?: string;
  location: string;
  /** CENTRAL_WAREHOUSE, RESTAURANT, IN_TRANSIT, V_SUPPLIER, V_WASTE, V_SAMPLE, V_ADJUSTMENT */
  locationType?: string;
  /** İşarəli miqdar: + mədaxil, − məxaric. */
  qtyBase: number;
  uom?: string;
  unitCost?: number;
}
export interface LedgerTableProps {
  lines: LedgerLine[];
  decimals?: number;
  /** `master.product.view_cost` icazəsi olmadıqda verilmə. */
  showCost?: boolean;
  /** Qrup cəminin sıfır olması yoxlanışını gizlətmək üçün false. */
  showBalanceCheck?: boolean;
  label?: string;
}
export function LedgerTable(p: LedgerTableProps): JSX.Element;

export interface Batch {
  id: string | number;
  batchNo: string;
  expiryDate?: string;
  receivedAt?: string;
  available: number;
  /** ACTIVE | BLOCKED | EXPIRED | QUARANTINE — ACTIVE olmayan seçilə bilməz. */
  status?: string;
}
export interface BatchPickerProps {
  batches: Batch[];
  /** `master_product.issue_strategy`. Təklif olunan partiya bu qaydaya görə nişanlanır. */
  strategy?: "FEFO" | "FIFO";
  value?: string | number;
  onChange?: (id: string | number, batch: Batch) => void;
  requiredQty?: number;
  uom?: string;
  decimals?: number;
  /** `inv_setting.expiry_warning_days` / `expiry_critical_days`. */
  warningDays?: number;
  criticalDays?: number;
  /** Test üçün bugünkü tarix (ISO). */
  today?: string;
}
export function BatchPicker(p: BatchPickerProps): JSX.Element;

export interface ApprovalStep {
  stepNo: number;
  role: string;
  user?: string;
  decision?: "PENDING" | "APPROVED" | "REJECTED";
  decidedAt?: string;
  comment?: string;
  delegatedFrom?: string;
}
export interface ApprovalChainProps {
  steps: ApprovalStep[];
  /** `proc_approval_instance.current_step`. Verilməzsə ilk PENDING addım cari sayılır. */
  currentStep?: number;
}
export function ApprovalChain(p: ApprovalChainProps): JSX.Element;

export interface VarianceIndicatorProps {
  /** Dondurma anındakı sistem qalığı. */
  book: number;
  counted: number;
  uom?: string;
  decimals?: number;
  /** `inv_setting.count_variance_approval_threshold_pct`. */
  thresholdPct?: number;
  /** Seçilmiş səbəb kodu. Fərq varsa və bu boşdursa xəbərdarlıq nişanı çıxır. */
  reasonCode?: string;
}
export function VarianceIndicator(p: VarianceIndicatorProps): JSX.Element;

export interface DialogProps {
  open: boolean;
  title?: ReactNode;
  subtitle?: ReactNode;
  size?: "md" | "lg";
  /** Verilməzsə modal yalnız footer düymələri ilə bağlanır. */
  onClose?: () => void;
  footer?: ReactNode;
  children?: ReactNode;
}
export function Dialog(p: DialogProps): JSX.Element;

export const Icons: Record<"chevron" | "close" | "check" | "warn" | "info" | "clock" | "arrow", (size?: number) => JSX.Element>;

export const format: {
  /** 1234.5 → "1 234,5000" (dar boşluq + vergül). */
  number(value: number | string | null, decimals?: number): string;
  /** İşarəli: "+12,0000" / "−12,0000". */
  signed(value: number, decimals?: number): string;
  /** ISO → "dd.MM.yyyy". */
  date(value?: string): string;
  /** ISO → "dd.MM.yyyy HH:mm". */
  dateTime(value?: string): string;
};
