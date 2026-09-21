import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import 'fake_adapter.dart';

void main() {
  group('DTO JSON contract', () {
    test('BalanceDto parses string quantities and tolerates missing cost', () {
      final dto = BalanceDto.fromJson(const {
        'productId': 10,
        'locationId': 3,
        'batchId': 77,
        'qtyOnHand': '45.0000',
        'qtyReserved': '5.5000',
        'baseUomCode': 'KG',
        'expiryDate': '2026-10-01',
      });
      expect(dto.qtyOnHand, Quantity.parse('45'));
      expect(dto.qtyAvailable, Quantity.parse('39.5'));
      expect(dto.avgUnitCost, isNull);
      expect(dto.hasCostInfo, isFalse);
      expect(dto.expiryDate, DateTime(2026, 10));
      expect(dto.toJson()['qtyOnHand'], '45.0000');
      expect(dto.toJson()['expiryDate'], '2026-10-01');
    });

    test('ProductDto exposes cost only when the server sends it', () {
      final withoutCost = ProductDto.fromJson(const {
        'id': 1,
        'sku': 'CHK-001',
        'name': 'Chicken Strips',
        'categoryId': 2,
        'baseUomId': 1,
        'vatRate': '18.0000',
        'issueStrategy': 'FEFO',
      });
      expect(withoutCost.hasCostInfo, isFalse);
      expect(withoutCost.vatRate, Decimal.parse('18'));
      final withCost = withoutCost.copyWith(avgUnitCost: Money.parse('12.5'));
      expect(withCost.hasCostInfo, isTrue);
      expect(withCost.toJson()['avgUnitCost'], '12.5000');
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
        'productId': 1,
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
        'productId': 1,
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
        'supplierId': 1,
        'currency': 'USD',
        'fxRate': '1.70000000',
        'subtotal': '100.0000',
        'vatAmount': '18.0000',
        'totalAmount': '118.0000',
        'totalAmountBase': '200.6000',
        'deliveryLocationId': 1,
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
              'productId': 1,
              'locationId': 2,
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
        'supplierId': 1,
        'currency': 'AZN',
        'fxRate': '1',
        'subtotal': '1',
        'vatAmount': '0',
        'totalAmount': '1',
        'totalAmountBase': '1',
        'deliveryLocationId': 1,
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
