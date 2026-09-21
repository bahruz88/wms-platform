import 'package:dio/dio.dart';
import 'package:wms_core/wms_core.dart';

import '../dto/inventory/inventory_dtos.dart';
import 'module_api.dart';

/// `/api/v1/inventory/*` (spec §13.1, §9.6).
class InventoryApi extends ModuleApi {
  InventoryApi(Dio dio) : super(dio, '/inventory');

  // --- Balances ---------------------------------------------------------

  /// `GET /inventory/balances?locationId=&productId=&page=&size=`
  Future<Page<BalanceDto>> listBalances({
    int? locationId,
    int? productId,
    String? search,
    bool? includeZero,
    PageRequest page = const PageRequest(),
    CancelToken? cancelToken,
  }) => getPage(
    'balances',
    fromJson: BalanceDto.fromJson,
    page: page,
    query: {
      'locationId': locationId,
      'productId': productId,
      'search': search,
      'includeZero': includeZero,
    },
    cancelToken: cancelToken,
  );

  /// `GET /inventory/batches?productId=&status=`
  Future<Page<BatchDto>> listBatches({
    int? productId,
    BatchStatus? status,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'batches',
    fromJson: BatchDto.fromJson,
    page: page,
    query: {'productId': productId, 'status': status},
  );

  // --- Goods receipts ---------------------------------------------------

  /// `GET /inventory/goods-receipts`
  Future<Page<GoodsReceiptDto>> listGoodsReceipts({
    ReceiptStatus? status,
    int? locationId,
    int? supplierId,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'goods-receipts',
    fromJson: GoodsReceiptDto.fromJson,
    page: page,
    query: {
      'status': status,
      'locationId': locationId,
      'supplierId': supplierId,
    },
  );

  /// `GET /inventory/goods-receipts/{id}`
  Future<GoodsReceiptDto> getGoodsReceipt(int id) =>
      getObject('goods-receipts/$id', fromJson: GoodsReceiptDto.fromJson);

  /// `POST /inventory/goods-receipts` (draft).
  Future<GoodsReceiptDto> createGoodsReceipt(CreateGoodsReceiptRequest body) =>
      postObject(
        'goods-receipts',
        body: body.toJson(),
        fromJson: GoodsReceiptDto.fromJson,
      );

  /// `POST /inventory/goods-receipts/{id}/post` - writes the ledger group.
  Future<GoodsReceiptDto> postGoodsReceipt(int id, {required int rowVersion}) =>
      postObject(
        'goods-receipts/$id/post',
        body: VersionedActionRequest(rowVersion: rowVersion).toJson(),
        fromJson: GoodsReceiptDto.fromJson,
      );

  // --- Stock requests ---------------------------------------------------

  /// `GET /inventory/stock-requests`
  Future<Page<StockRequestDto>> listStockRequests({
    StockRequestStatus? status,
    int? toLocationId,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'stock-requests',
    fromJson: StockRequestDto.fromJson,
    page: page,
    query: {'status': status, 'toLocationId': toLocationId},
  );

  /// `GET /inventory/stock-requests/{id}`
  Future<StockRequestDto> getStockRequest(int id) =>
      getObject('stock-requests/$id', fromJson: StockRequestDto.fromJson);

  /// `POST /inventory/stock-requests`
  Future<StockRequestDto> createStockRequest(CreateStockRequestRequest body) =>
      postObject(
        'stock-requests',
        body: body.toJson(),
        fromJson: StockRequestDto.fromJson,
      );

  /// `POST /inventory/stock-requests/{id}/submit`
  Future<StockRequestDto> submitStockRequest(
    int id, {
    required int rowVersion,
  }) => postObject(
    'stock-requests/$id/submit',
    body: VersionedActionRequest(rowVersion: rowVersion).toJson(),
    fromJson: StockRequestDto.fromJson,
  );

  // --- Issues / transfers ------------------------------------------------

  /// `GET /inventory/issues`
  Future<Page<IssueDto>> listIssues({
    IssueStatus? status,
    IssueType? issueType,
    int? fromLocationId,
    int? toLocationId,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'issues',
    fromJson: IssueDto.fromJson,
    page: page,
    query: {
      'status': status,
      'issueType': issueType,
      'fromLocationId': fromLocationId,
      'toLocationId': toLocationId,
    },
  );

  /// `GET /inventory/issues/{id}`
  Future<IssueDto> getIssue(int id) =>
      getObject('issues/$id', fromJson: IssueDto.fromJson);

  /// `POST /inventory/issues`
  Future<IssueDto> createIssue(CreateIssueRequest body) =>
      postObject('issues', body: body.toJson(), fromJson: IssueDto.fromJson);

  /// `POST /inventory/issues/{id}/dispatch` - source → IN_TRANSIT.
  Future<IssueDto> dispatchIssue(int id, {required int rowVersion}) =>
      postObject(
        'issues/$id/dispatch',
        body: VersionedActionRequest(rowVersion: rowVersion).toJson(),
        fromJson: IssueDto.fromJson,
      );

  /// `POST /inventory/issues/{id}/confirm` - IN_TRANSIT → destination.
  Future<IssueDto> confirmIssue(int id, ConfirmIssueRequest body) => postObject(
    'issues/$id/confirm',
    body: body.toJson(),
    fromJson: IssueDto.fromJson,
  );

  // --- Counts -----------------------------------------------------------

  /// `GET /inventory/counts`
  Future<Page<CountDto>> listCounts({
    CountStatus? status,
    int? locationId,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'counts',
    fromJson: CountDto.fromJson,
    page: page,
    query: {'status': status, 'locationId': locationId},
  );

  /// `GET /inventory/counts/{id}`
  Future<CountDto> getCount(int id) =>
      getObject('counts/$id', fromJson: CountDto.fromJson);

  /// `POST /inventory/counts`
  Future<CountDto> createCount(CreateCountRequest body) =>
      postObject('counts', body: body.toJson(), fromJson: CountDto.fromJson);

  /// `POST /inventory/counts/{id}/freeze` - snapshots `book_qty`, blocks the
  /// location (spec §12.7).
  Future<CountDto> freezeCount(int id, {required int rowVersion}) => postObject(
    'counts/$id/freeze',
    body: VersionedActionRequest(rowVersion: rowVersion).toJson(),
    fromJson: CountDto.fromJson,
  );

  /// `POST /inventory/counts/{id}/lines` - enter counted quantities.
  Future<CountDto> enterCounts(int id, EnterCountRequest body) => postObject(
    'counts/$id/lines',
    body: body.toJson(),
    fromJson: CountDto.fromJson,
  );

  /// `POST /inventory/counts/{id}/approve` (`inv.adjustment.approve`).
  Future<CountDto> approveCount(
    int id, {
    required int rowVersion,
    String? comment,
  }) => postObject(
    'counts/$id/approve',
    body: VersionedActionRequest(
      rowVersion: rowVersion,
      comment: comment,
    ).toJson(),
    fromJson: CountDto.fromJson,
  );

  // --- Waste ------------------------------------------------------------

  /// `GET /inventory/waste`
  Future<Page<WasteDto>> listWaste({
    WasteStatus? status,
    int? locationId,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'waste',
    fromJson: WasteDto.fromJson,
    page: page,
    query: {'status': status, 'locationId': locationId},
  );

  /// `GET /inventory/waste/{id}`
  Future<WasteDto> getWaste(int id) =>
      getObject('waste/$id', fromJson: WasteDto.fromJson);

  /// `POST /inventory/waste`
  Future<WasteDto> createWaste(CreateWasteRequest body) =>
      postObject('waste', body: body.toJson(), fromJson: WasteDto.fromJson);

  /// `POST /inventory/waste/{id}/approve` (`inv.waste.approve`).
  Future<WasteDto> approveWaste(
    int id, {
    required int rowVersion,
    String? comment,
  }) => postObject(
    'waste/$id/approve',
    body: VersionedActionRequest(
      rowVersion: rowVersion,
      comment: comment,
    ).toJson(),
    fromJson: WasteDto.fromJson,
  );

  // --- Samples ----------------------------------------------------------

  /// `GET /inventory/samples`
  Future<Page<SampleDto>> listSamples({
    int? locationId,
    PageRequest page = const PageRequest(),
  }) => getPage(
    'samples',
    fromJson: SampleDto.fromJson,
    page: page,
    query: {'locationId': locationId},
  );

  /// `POST /inventory/samples`
  Future<SampleDto> createSample(CreateSampleRequest body) =>
      postObject('samples', body: body.toJson(), fromJson: SampleDto.fromJson);

  // --- Settings ---------------------------------------------------------

  /// `GET /inventory/settings` - `inv_setting` key/value list (SPEC §9.1).
  Future<List<InventorySettingDto>> listSettings() =>
      getList('settings', fromJson: InventorySettingDto.fromJson);

  /// `PUT /inventory/settings/{key}` (`inv.settings.manage`).
  Future<InventorySettingDto> updateSetting(
    String key,
    UpdateInventorySettingRequest body,
  ) => putObject(
    'settings/$key',
    body: body.toJson(),
    fromJson: InventorySettingDto.fromJson,
  );
}
