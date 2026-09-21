import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// Inventory reads and document operations (spec §9, §13.1).
abstract interface class InventoryRepository {
  // --- Balances ---------------------------------------------------------
  Future<Result<Page<BalanceDto>>> balances({
    int? locationId,
    int? productId,
    String? search,
    PageRequest page,
  });

  // --- Goods receipts ---------------------------------------------------
  Future<Result<Page<GoodsReceiptDto>>> goodsReceipts({
    ReceiptStatus? status,
    int? locationId,
    PageRequest page,
  });

  Future<Result<GoodsReceiptDto>> goodsReceipt(int id);

  Future<Result<GoodsReceiptDto>> createGoodsReceipt(
    CreateGoodsReceiptRequest request,
  );

  /// Writes the ledger group; fails with `LOCATION_FROZEN` during a count.
  Future<Result<GoodsReceiptDto>> postGoodsReceipt(
    int id, {
    required int rowVersion,
  });

  // --- Stock requests ---------------------------------------------------
  Future<Result<StockRequestDto>> createStockRequest(
    CreateStockRequestRequest request,
  );

  // --- Issues / transfers ------------------------------------------------
  Future<Result<Page<IssueDto>>> issues({
    IssueStatus? status,
    int? toLocationId,
    PageRequest page,
  });

  Future<Result<IssueDto>> issue(int id);

  /// Source location → `IN_TRANSIT`.
  Future<Result<IssueDto>> dispatchIssue(int id, {required int rowVersion});

  /// `IN_TRANSIT` → destination (branch confirmation).
  Future<Result<IssueDto>> confirmIssue(int id, ConfirmIssueRequest request);

  // --- Counts -----------------------------------------------------------
  Future<Result<Page<CountDto>>> counts({
    CountStatus? status,
    PageRequest page,
  });

  Future<Result<CountDto>> count(int id);

  Future<Result<CountDto>> enterCounts(int id, EnterCountRequest request);

  // --- Waste / samples --------------------------------------------------
  Future<Result<Page<WasteDto>>> wasteDocuments({PageRequest page});

  Future<Result<WasteDto>> createWaste(CreateWasteRequest request);

  Future<Result<SampleDto>> createSample(CreateSampleRequest request);

  // --- Settings ---------------------------------------------------------
  /// `inv_setting` key/value list (SPEC §9.1); nothing is hard-coded client
  /// side (TOR §36).
  Future<Result<List<InventorySettingDto>>> settings();
}
