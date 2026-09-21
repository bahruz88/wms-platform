import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import '../domain/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(this._api);

  final InventoryApi _api;

  @override
  Future<Result<Page<BalanceDto>>> balances({
    int? locationId,
    int? productId,
    String? search,
    PageRequest page = const PageRequest(),
  }) => Result.guard(
    () => _api.listBalances(
      locationId: locationId,
      productId: productId,
      search: search,
      page: page,
    ),
  );

  @override
  Future<Result<Page<GoodsReceiptDto>>> goodsReceipts({
    ReceiptStatus? status,
    int? locationId,
    PageRequest page = const PageRequest(),
  }) => Result.guard(
    () => _api.listGoodsReceipts(
      status: status,
      locationId: locationId,
      page: page,
    ),
  );

  @override
  Future<Result<GoodsReceiptDto>> goodsReceipt(int id) =>
      Result.guard(() => _api.getGoodsReceipt(id));

  @override
  Future<Result<GoodsReceiptDto>> createGoodsReceipt(
    CreateGoodsReceiptRequest request,
  ) => Result.guard(() => _api.createGoodsReceipt(request));

  @override
  Future<Result<GoodsReceiptDto>> postGoodsReceipt(
    int id, {
    required int rowVersion,
  }) => Result.guard(() => _api.postGoodsReceipt(id, rowVersion: rowVersion));

  @override
  Future<Result<StockRequestDto>> createStockRequest(
    CreateStockRequestRequest request,
  ) => Result.guard(() => _api.createStockRequest(request));

  @override
  Future<Result<Page<IssueDto>>> issues({
    IssueStatus? status,
    int? toLocationId,
    PageRequest page = const PageRequest(),
  }) => Result.guard(
    () =>
        _api.listIssues(status: status, toLocationId: toLocationId, page: page),
  );

  @override
  Future<Result<IssueDto>> issue(int id) =>
      Result.guard(() => _api.getIssue(id));

  @override
  Future<Result<IssueDto>> dispatchIssue(int id, {required int rowVersion}) =>
      Result.guard(() => _api.dispatchIssue(id, rowVersion: rowVersion));

  @override
  Future<Result<IssueDto>> confirmIssue(int id, ConfirmIssueRequest request) =>
      Result.guard(() => _api.confirmIssue(id, request));

  @override
  Future<Result<Page<CountDto>>> counts({
    CountStatus? status,
    PageRequest page = const PageRequest(),
  }) => Result.guard(() => _api.listCounts(status: status, page: page));

  @override
  Future<Result<CountDto>> count(int id) =>
      Result.guard(() => _api.getCount(id));

  @override
  Future<Result<CountDto>> enterCounts(int id, EnterCountRequest request) =>
      Result.guard(() => _api.enterCounts(id, request));

  @override
  Future<Result<Page<WasteDto>>> wasteDocuments({
    PageRequest page = const PageRequest(),
  }) => Result.guard(() => _api.listWaste(page: page));

  @override
  Future<Result<WasteDto>> createWaste(CreateWasteRequest request) =>
      Result.guard(() => _api.createWaste(request));

  @override
  Future<Result<SampleDto>> createSample(CreateSampleRequest request) =>
      Result.guard(() => _api.createSample(request));

  @override
  Future<Result<List<InventorySettingDto>>> settings() =>
      Result.guard(_api.listSettings);
}
