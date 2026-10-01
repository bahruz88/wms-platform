import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import 'fake_adapter.dart';

void main() {
  group('DTO JSON contract', () {
    // The payload below is the shape the live API actually returns, copied from a real
    // `GET /inventory/balances` response. The previous version of this test invented a flat
    // `productId`/`locationId` shape, agreed with the DTO that expected it, and stayed green while
    // the client could not parse a single balance row.
    test('BalanceDto parses the nested refs the API sends, and tolerates missing cost', () {
      final dto = BalanceDto.fromJson(const {
        'product': {
          'id': 10,
          'sku': 'CHK-001',
          'name': 'Toyuq döşü',
          'baseUomId': 3,
          'baseUomCode': 'KG',
        },
        'location': {'id': 3, 'code': 'WH-01', 'name': 'Mərkəzi anbar', 'isVirtual': false},
        'batch': {'id': 77, 'batchNo': 'CHK-2026A', 'expiryDate': '2026-10-01', 'status': 'ACTIVE'},
        'qtyOnHand': '45.0000',
        'qtyReserved': '5.5000',
        'qtyAvailable': '39.5000',
        'baseUomId': 3,
        'baseUomCode': 'KG',
        'isBelowMin': false,
      });

      expect(dto.product.sku, 'CHK-001');
      expect(dto.location.code, 'WH-01');
      expect(dto.batch?.batchNo, 'CHK-2026A');
      expect(dto.batch?.expiryDate, DateTime(2026, 10));
      expect(dto.qtyOnHand, Quantity.parse('45'));
      expect(dto.qtyAvailable, Quantity.parse('39.5'));
      expect(dto.avgUnitCost, isNull);
      expect(dto.hasCostInfo, isFalse);
      expect(dto.toJson()['qtyOnHand'], '45.0000');
    });

    test('BalanceDto has no batch when the row is not batch tracked', () {
      final dto = BalanceDto.fromJson(const {
        'product': {'id': 25, 'sku': 'DETERGENT', 'name': 'Yuyucu vasitə', 'baseUomId': 5, 'baseUomCode': 'L'},
        'location': {'id': 1, 'code': 'WH-01', 'name': 'Mərkəzi anbar'},
        'qtyOnHand': '12.0000',
        'qtyReserved': '0.0000',
      });

      expect(dto.batch, isNull);
      expect(dto.qtyAvailable, Quantity.parse('12'));
    });

    test('ProductDto reads the detail form', () {
      final detail = ProductDto.fromJson(const {
        'id': 1,
        'sku': 'CHK-001',
        'name': 'Chicken Strips',
        'productType': 'FOOD',
        'categoryId': 2,
        'categoryPath': 'Ət / Toyuq',
        'baseUomId': 1,
        'vatRate': '18.0000',
        'issueStrategy': 'FEFO',
        'audit': {
          'createdAt': '2026-09-01T08:00:00+00:00',
          'createdBy': 1,
          'rowVersion': 3,
        },
      });

      expect(detail.productType, ProductType.food);
      expect(detail.vatRate, Decimal.parse('18'));
      expect(detail.categoryLabel, 'Ət / Toyuq');
      // The update endpoints need the token, and it lives inside `audit`.
      expect(detail.rowVersion, 3);
    });

    test('ProductDto reads the list form, which omits the detail fields', () {
      // Copied from `GET /masterdata/products` on the running gateway.
      final row = ProductDto.fromJson(const {
        'id': 25,
        'sku': 'DETERGENT',
        'name': 'Yuyucu vasitə',
        'baseUomId': 5,
        'baseUomCode': 'L',
        'productType': 'NON_FOOD',
        'requiresBatch': false,
        'requiresExpiry': false,
        'isActive': true,
      });

      expect(row.productType, ProductType.nonFood);
      expect(row.categoryId, isNull);
      expect(row.vatRate, isNull);
      // No audit in the list form, so no row version — a list row cannot be submitted as an update.
      expect(row.rowVersion, isNull);
      expect(row.categoryLabel, '—');
    });

    test(
      'CreateGoodsReceiptRequest serialises enums, dates and quantities',
      () {
        final req = CreateGoodsReceiptRequest(
          docDate: DateTime(2026, 9, 20),
          supplierId: 4,
          locationId: 1,
          qualityStatus: QualityStatus.partiallyAccepted,
          temperatureC: Decimal.parse('4.5'),
          lines: [
            CreateGoodsReceiptLine(
              productId: 10,
              orderedQty: Quantity.parse('100'),
              receivedQty: Quantity.parse('97.5'),
              uomId: 1,
              batchNo: 'B-1',
              expiryDate: DateTime(2026, 12, 31),
              unitPrice: Money.parse('3.25'),
              currency: 'AZN',
              varianceNote: 'Qutu zədəli',
            ),
          ],
        );
        final json = req.toJson();
        expect(json['docDate'], '2026-09-20');
        expect(json['qualityStatus'], 'PARTIALLY_ACCEPTED');
        expect(json['temperatureC'], '4.5');
        final line = (json['lines']! as List).first as Map<String, Object?>;
        expect(line['receivedQty'], '97.5000');
        expect(line['unitPrice'], '3.2500');
        expect(line['expiryDate'], '2026-12-31');
      },
    );

    test('GoodsReceiptLineDto variance rules', () {
      final line = GoodsReceiptLineDto.fromJson(const {
        'lineNo': 1,
        'product': {'id': 1, 'sku': 'CHK-001', 'name': 'Toyuq döşü', 'baseUomId': 1, 'baseUomCode': 'G'},
        'receivedQty': '90',
        'orderedQty': '100',
        'rejectedQty': '0',
        'uomId': 1,
      });
      expect(line.variance, Quantity.parse('-10'));
      expect(line.requiresVarianceNote, isTrue);
      expect(
        line.copyWith(receivedQty: Quantity.parse('100')).requiresVarianceNote,
        isFalse,
      );
    });

    test('CountLineDto requires reason code when variance != 0', () {
      final line = CountLineDto.fromJson(const {
        'id': 1,
        'product': {'id': 1, 'sku': 'CHK-001', 'name': 'Toyuq döşü', 'baseUomId': 1, 'baseUomCode': 'G'},
        'bookQty': '10',
        'countedQty': '9.5',
        'variancePct': '-5.0000',
      });
      expect(line.requiresReasonCode, isTrue);
      expect(line.variancePct, Decimal.parse('-5'));
      expect(
        line.copyWith(countedQty: Quantity.parse('10')).requiresReasonCode,
        isFalse,
      );
    });

    test('PurchaseOrderDto money fields', () {
      final po = PurchaseOrderDto.fromJson(const {
        'id': 1,
        'docNo': 'PO-2026-00087',
        'docDate': '2026-09-01',
        'supplier': {'id': 1, 'code': 'SUP-001', 'name': 'Alfa MMC'},
        'currency': 'USD',
        'fxRate': '1.70000000',
        'subtotal': '100.0000',
        'vatAmount': '18.0000',
        'totalAmount': '118.0000',
        'totalAmountBase': '200.6000',
        'deliveryLocation': {'id': 1, 'code': 'WH-01', 'name': 'Mərkəzi anbar'},
        'status': 'PENDING_APPROVAL',
        'lines': [
          {
            'lineNo': 1,
            'productId': 1,
            'qty': '10',
            'uomId': 1,
            'unitPrice': '10',
            'vatRate': '18',
            'lineTotal': '100',
            'receivedQty': '4',
          },
        ],
      });
      expect(po.status.canApprove, isTrue);
      expect(po.totalAmountBase, Money.parse('200.6'));
      expect(po.lines.single.outstandingQty, Quantity.parse('6'));
    });

    test('DashboardSummaryDto reads the category breakdown, and its absence without cost', () {
      final withCost = DashboardSummaryDto.fromJson(const {
        'generatedAt': '2026-09-30T08:00:00Z',
        'kpis': <Object?>[],
        'alerts': <Object?>[],
        'series': <Object?>[],
        'categoryValues': [
          {'categoryId': 10, 'value': '1000.5000'},
          // A product the catalogue did not return: the value stays, the category is null.
          {'categoryId': null, 'value': '234.5678'},
        ],
      });
      expect(withCost.categoryValues, hasLength(2));
      expect(withCost.categoryValues!.first.categoryId, 10);
      expect(withCost.categoryValues!.last.categoryId, isNull);
      expect(withCost.categoryValues!.last.amount, Money.parse('234.5678'));

      final withoutCost = DashboardSummaryDto.fromJson(const {
        'generatedAt': '2026-09-30T08:00:00Z',
        'kpis': <Object?>[],
        'alerts': <Object?>[],
        'series': <Object?>[],
      });
      expect(withoutCost.categoryValues, isNull);
    });
  });

  group('Module APIs', () {
    test(
      'listBalances hits the spec route with query and parses Page',
      () async {
        final adapter = FakeAdapter();
        final client = WmsApiClient(
          baseUrl: 'http://localhost:5000',
          tokenProvider: StaticTokenProvider('t'),
          enableLogging: false,
        );
        client.dio.httpClientAdapter = adapter;
        adapter.enqueueJson({
          'items': [
            {
              'product': {'id': 1, 'sku': 'LETTUCE', 'name': 'Kahı', 'baseUomId': 1, 'baseUomCode': 'G'},
              'location': {'id': 2, 'code': 'WH-01', 'name': 'Mərkəzi anbar'},
              'qtyOnHand': '1.0000',
              'qtyReserved': '0.0000',
            },
          ],
          'page': 1,
          'size': 50,
          'total': 1,
        });
        final page = await client.inventory.listBalances(locationId: 2);
        final request = adapter.requests.single;
        expect(request.uri.path, '/api/v1/inventory/balances');
        expect(request.uri.queryParameters, {
          'locationId': '2',
          'page': '1',
          'size': '50',
        });
        expect(page.total, 1);
        expect(page.items.single.qtyOnHand, Quantity.fromInt(1));
      },
    );

    test('approvePurchaseOrder posts to /approve with body', () async {
      final adapter = FakeAdapter();
      final client = WmsApiClient(
        baseUrl: 'http://localhost:5000',
        tokenProvider: StaticTokenProvider('t'),
        enableLogging: false,
      );
      client.dio.httpClientAdapter = adapter;
      adapter.enqueueJson({
        'id': 9,
        'docNo': 'PO-2026-00001',
        'docDate': '2026-09-01',
        'supplier': {'id': 1, 'code': 'SUP-001', 'name': 'Alfa MMC'},
        'currency': 'AZN',
        'fxRate': '1',
        'subtotal': '1',
        'vatAmount': '0',
        'totalAmount': '1',
        'totalAmountBase': '1',
        'deliveryLocation': {'id': 1, 'code': 'WH-01', 'name': 'Mərkəzi anbar'},
        'status': 'APPROVED',
      });
      final po = await client.procurement.approvePurchaseOrder(
        9,
        const ApprovalDecisionRequest(rowVersion: 3, comment: 'ok'),
      );
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v1/procurement/purchase-orders/9/approve');
      expect(request.data, {'rowVersion': 3, 'comment': 'ok'});
      expect(po.status, PoStatus.approved);
    });

    test('enum query params use wire names', () async {
      final adapter = FakeAdapter();
      final client = WmsApiClient(
        baseUrl: 'http://localhost:5000',
        tokenProvider: StaticTokenProvider('t'),
        enableLogging: false,
      );
      client.dio.httpClientAdapter = adapter;
      adapter.enqueueJson({
        'items': <Object?>[],
        'page': 1,
        'size': 50,
        'total': 0,
      });
      await client.inventory.listIssues(status: IssueStatus.dispatched);
      expect(
        adapter.requests.single.uri.queryParameters['status'],
        'DISPATCHED',
      );
    });
  });
}
