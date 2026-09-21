import 'package:json_annotation/json_annotation.dart';

/// `inv_goods_receipt.status`.
enum ReceiptStatus {
  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('POSTED')
  posted('POSTED'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED');

  const ReceiptStatus(this.wire);
  final String wire;
  bool get canPost => this == ReceiptStatus.draft;
}

/// `inv_goods_receipt.quality_status`.
enum QualityStatus {
  @JsonValue('ACCEPTED')
  accepted('ACCEPTED'),
  @JsonValue('PARTIALLY_ACCEPTED')
  partiallyAccepted('PARTIALLY_ACCEPTED'),
  @JsonValue('REJECTED')
  rejected('REJECTED');

  const QualityStatus(this.wire);
  final String wire;
}

/// `inv_stock_request.status`.
enum StockRequestStatus {
  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('SUBMITTED')
  submitted('SUBMITTED'),
  @JsonValue('PICKING')
  picking('PICKING'),
  @JsonValue('PARTIALLY_ISSUED')
  partiallyIssued('PARTIALLY_ISSUED'),
  @JsonValue('ISSUED')
  issued('ISSUED'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED'),
  @JsonValue('CLOSED')
  closed('CLOSED');

  const StockRequestStatus(this.wire);
  final String wire;
}

/// `inv_issue.issue_type`.
enum IssueType {
  @JsonValue('BRANCH_ISSUE')
  branchIssue('BRANCH_ISSUE'),
  @JsonValue('WH_TRANSFER')
  whTransfer('WH_TRANSFER'),
  @JsonValue('BRANCH_TRANSFER')
  branchTransfer('BRANCH_TRANSFER');

  const IssueType(this.wire);
  final String wire;
}

/// `inv_issue.status` - the IN_TRANSIT mechanism (spec §12.3).
enum IssueStatus {
  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('DISPATCHED')
  dispatched('DISPATCHED'),
  @JsonValue('RECEIVED')
  received('RECEIVED'),
  @JsonValue('DISCREPANCY')
  discrepancy('DISCREPANCY'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED');

  const IssueStatus(this.wire);
  final String wire;

  /// Goods are in the virtual IN_TRANSIT location awaiting branch confirm.
  bool get isInTransit => this == IssueStatus.dispatched;
  bool get canDispatch => this == IssueStatus.draft;
  bool get canConfirm => this == IssueStatus.dispatched;
}

/// `inv_count.count_type`.
enum CountType {
  @JsonValue('FULL')
  full('FULL'),
  @JsonValue('CYCLE')
  cycle('CYCLE'),
  @JsonValue('SPOT')
  spot('SPOT');

  const CountType(this.wire);
  final String wire;
}

/// `inv_waste.status`.
enum WasteStatus {
  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('PENDING_APPROVAL')
  pendingApproval('PENDING_APPROVAL'),
  @JsonValue('APPROVED')
  approved('APPROVED'),
  @JsonValue('POSTED')
  posted('POSTED'),
  @JsonValue('REJECTED')
  rejected('REJECTED');

  const WasteStatus(this.wire);
  final String wire;
  bool get canApprove => this == WasteStatus.pendingApproval;
}

/// `proc_requisition.status`.
enum RequisitionStatus {
  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('SUBMITTED')
  submitted('SUBMITTED'),
  @JsonValue('IN_PROCUREMENT')
  inProcurement('IN_PROCUREMENT'),
  @JsonValue('CONVERTED_TO_PO')
  convertedToPo('CONVERTED_TO_PO'),
  @JsonValue('REJECTED')
  rejected('REJECTED'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED'),
  @JsonValue('CLOSED')
  closed('CLOSED');

  const RequisitionStatus(this.wire);
  final String wire;
}

/// `proc_requisition.priority`.
enum Priority {
  @JsonValue('LOW')
  low('LOW'),
  @JsonValue('NORMAL')
  normal('NORMAL'),
  @JsonValue('HIGH')
  high('HIGH'),
  @JsonValue('URGENT')
  urgent('URGENT');

  const Priority(this.wire);
  final String wire;
}

/// `proc_rfq.status`.
enum RfqStatus {
  @JsonValue('DRAFT')
  draft('DRAFT'),
  @JsonValue('SENT')
  sent('SENT'),
  @JsonValue('CLOSED')
  closed('CLOSED'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED');

  const RfqStatus(this.wire);
  final String wire;
}

/// `proc_approval_instance.status` / `proc_approval_step.decision`.
enum ApprovalStatus {
  @JsonValue('PENDING')
  pending('PENDING'),
  @JsonValue('APPROVED')
  approved('APPROVED'),
  @JsonValue('REJECTED')
  rejected('REJECTED'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED');

  const ApprovalStatus(this.wire);
  final String wire;
}

/// `master_uom.uom_class`.
enum UomClass {
  @JsonValue('MASS')
  mass('MASS'),
  @JsonValue('VOLUME')
  volume('VOLUME'),
  @JsonValue('COUNT')
  count('COUNT');

  const UomClass(this.wire);
  final String wire;
}

/// `master_product.issue_strategy` (spec §12.4).
enum IssueStrategy {
  @JsonValue('FEFO')
  fefo('FEFO'),
  @JsonValue('FIFO')
  fifo('FIFO');

  const IssueStrategy(this.wire);
  final String wire;
}
