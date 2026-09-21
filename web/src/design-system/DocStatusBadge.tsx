import { Badge, type Tone } from './Badge';

/**
 * DocStatusBadge — docs/design-system/components/DocStatusBadge/README.md.
 *
 * The single place in the system where a document, batch, count, run, import or export status is
 * rendered. The ENUM arrives from the server untouched; the Azerbaijani name and the tone live
 * here, so the same value never reads two different ways on two screens.
 *
 * Tone rule: a finished positive outcome is `success`, anything waiting or needing attention is
 * `warning`, stopped or failed is `danger`, inert is `neutral`, in-flight is `accent`.
 * An unknown value is shown verbatim in the neutral tone — never an empty space.
 */
export interface DocStatusBadgeProps {
  /** The spec's ENUM value: DRAFT, PENDING_APPROVAL, POSTED, EXPIRED … */
  status: string;
  /** Replaces the standard Azerbaijani name. Only when genuinely necessary. */
  label?: string;
}

type StatusEntry = [string, Tone];

const statuses: Record<string, StatusEntry> = {
  // --- generic document lifecycle -------------------------------------------------------------
  DRAFT: ['Qaralama', 'neutral'],
  SUBMITTED: ['Göndərilib', 'accent'],
  PENDING_APPROVAL: ['Təsdiq gözləyir', 'warning'],
  PENDING: ['Gözləyir', 'warning'],
  APPROVED: ['Təsdiqlənib', 'success'],
  REJECTED: ['Rədd edilib', 'danger'],
  POSTED: ['Post edilib', 'success'],
  CANCELLED: ['Ləğv edilib', 'neutral'],
  CLOSED: ['Bağlanıb', 'neutral'],
  COMPLETED: ['Tamamlanıb', 'success'],
  REVERSED: ['Storno edilib', 'danger'],
  REVERSAL: ['Storno', 'danger'],
  ARCHIVED: ['Arxivlənib', 'neutral'],
  FAILED: ['Uğursuz', 'danger'],

  // --- inventory -------------------------------------------------------------------------------
  RECEIVED: ['Qəbul edilib', 'success'],
  PARTIALLY_RECEIVED: ['Qismən qəbul edilib', 'warning'],
  FULLY_RECEIVED: ['Tam qəbul edilib', 'success'],
  DISCREPANCY: ['Fərqli', 'danger'],
  IN_TRANSIT: ['Yoldadır', 'accent'],
  DISPATCHED: ['Yola salınıb', 'accent'],
  ISSUED: ['Məxaric edilib', 'success'],
  PARTIALLY_ISSUED: ['Qismən məxaric edilib', 'warning'],
  PICKING: ['Yığılır', 'accent'],
  ACCEPTED: ['Qəbul edilib', 'success'],
  PARTIALLY_ACCEPTED: ['Qismən qəbul edilib', 'warning'],
  SENT: ['Göndərilib', 'accent'],

  // --- batches ----------------------------------------------------------------------------------
  ACTIVE: ['Aktiv', 'success'],
  BLOCKED: ['Bloklanıb', 'danger'],
  EXPIRED: ['Vaxtı keçib', 'danger'],
  QUARANTINE: ['Karantində', 'warning'],

  // --- counts ------------------------------------------------------------------------------------
  FROZEN: ['Dondurulub', 'warning'],
  COUNTING: ['Sayılır', 'accent'],
  SCANNING: ['Skan edilir', 'accent'],
  REVIEW: ['Yoxlamada', 'warning'],

  // --- procurement --------------------------------------------------------------------------------
  IN_PROCUREMENT: ['Satınalmada', 'accent'],
  CONVERTED_TO_PO: ['PO-ya çevrilib', 'success'],
  SENT_TO_SUPPLIER: ['Təchizatçıya göndərilib', 'accent'],

  // --- consumption ----------------------------------------------------------------------------------
  CALCULATED: ['Hesablanıb', 'accent'],
  CONSUMED: ['İstehlak edilib', 'success'],

  // --- reporting / exports ----------------------------------------------------------------------------
  QUEUED: ['Növbədə', 'warning'],
  RUNNING: ['İşləyir', 'accent'],
  READY: ['Hazırdır', 'success'],
};

export function DocStatusBadge({ status, label }: DocStatusBadgeProps) {
  const entry = statuses[status];
  const text = label ?? entry?.[0] ?? status;
  const tone: Tone = entry?.[1] ?? 'neutral';
  // The raw ENUM stays reachable on hover for support and QA.
  return (
    <Badge tone={tone} dot title={status}>
      {text}
    </Badge>
  );
}

DocStatusBadge.statuses = statuses;
