import 'package:feature_inventory/feature_inventory.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// In-memory [InventoryRepository] for widget tests.
class FakeInventoryRepository implements InventoryRepository {
  FakeInventoryRepository({
    this.balanceRows = const [],
    this.receipts = const [],
    this.issueList = const [],
    this.countList = const [],
    this.wasteList = const [],
    this.settingList = const [],
    this.failure,
  });

  final List<BalanceDto> balanceRows;
  final List<GoodsReceiptDto> receipts;
  final List<IssueDto> issueList;
  final List<CountDto> countList;
  final List<WasteDto> wasteList;
  final List<InventorySettingDto> settingList;
  final Failure? failure;

  /// Records the confirmations performed through the fake.
  final List<ConfirmIssueRequest> confirmations = [];

  /// Records the waste documents created through the fake.
  final List<CreateWasteRequest> createdWaste = [];

  Result<T> _ok<T>(T value) =>
      failure == null ? Result<T>.ok(value) : Result<T>.err(failure!);

  Page<T> _page<T>(List<T> items) =>
      Page<T>(items: items, page: 1, size: 50, total: items.length);

  @override
  Future<Result<Page<BalanceDto>>> balances({
    int? locationId,
    int? productId,
    String? search,
    PageRequest page = const PageRequest(),
  }) async => _ok(_page(balanceRows));

  @override
  Future<Result<Page<GoodsReceiptDto>>> goodsReceipts({
    ReceiptStatus? status,
    int? locationId,
    PageRequest page = const PageRequest(),
  }) async => _ok(_page(receipts));

  @override
  Future<Result<GoodsReceiptDto>> goodsReceipt(int id) async =>
      _ok(receipts.firstWhere((r) => r.id == id));

  @override
  Future<Result<GoodsReceiptDto>> createGoodsReceipt(
    CreateGoodsReceiptRequest request,
  ) async => _ok(receipts.first);

  @override
  Future<Result<GoodsReceiptDto>> postGoodsReceipt(
    int id, {
    required int rowVersion,
  }) async => _ok(receipts.firstWhere((r) => r.id == id));

  @override
  Future<Result<StockRequestDto>> createStockRequest(
    CreateStockRequestRequest request,
  ) async => throw UnimplementedError();

  @override
  Future<Result<Page<IssueDto>>> issues({
    IssueStatus? status,
    int? toLocationId,
    PageRequest page = const PageRequest(),
  }) async => _ok(_page(issueList));

  @override
  Future<Result<IssueDto>> issue(int id) async =>
      _ok(issueList.firstWhere((i) => i.id == id));

  @override
  Future<Result<IssueDto>> dispatchIssue(
    int id, {
    required int rowVersion,
  }) async => _ok(issueList.firstWhere((i) => i.id == id));

  @override
  Future<Result<IssueDto>> confirmIssue(
    int id,
    ConfirmIssueRequest request,
  ) async {
    confirmations.add(request);
    final issue = issueList.firstWhere((i) => i.id == id);
    return _ok(issue.copyWith(status: IssueStatus.received));
  }

  @override
  Future<Result<Page<CountDto>>> counts({
    CountStatus? status,
    PageRequest page = const PageRequest(),
  }) async => _ok(_page(countList));

  @override
  Future<Result<CountDto>> count(int id) async =>
      _ok(countList.firstWhere((c) => c.id == id));

  @override
  Future<Result<CountDto>> enterCounts(
    int id,
    EnterCountRequest request,
  ) async => _ok(countList.firstWhere((c) => c.id == id));

  @override
  Future<Result<Page<WasteDto>>> wasteDocuments({
    PageRequest page = const PageRequest(),
  }) async => _ok(_page(wasteList));

  @override
  Future<Result<WasteDto>> createWaste(CreateWasteRequest request) async {
    createdWaste.add(request);
    return _ok(
      WasteDto(
        id: 1,
        docNo: 'WS-2026-00001',
        docDate: request.docDate,
        locationId: request.locationId,
        reasonCodeId: request.reasonCodeId,
        status: WasteStatus.pendingApproval,
        attachmentIds: request.attachmentIds,
      ),
    );
  }

  @override
  Future<Result<SampleDto>> createSample(CreateSampleRequest request) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<InventorySettingDto>>> settings() async =>
      _ok(settingList);
}
