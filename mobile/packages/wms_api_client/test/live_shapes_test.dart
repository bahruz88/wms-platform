import 'package:test/test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// Every payload below was copied verbatim from the running gateway (responses on 2026-09-28,
/// request bodies on 2026-09-29).
///
/// It is the guard the hand-written fixtures could not be: those were invented to match the DTOs,
/// so a DTO that disagreed with the wire had a test that agreed with the DTO. These do not — if a
/// contract shape changes and a DTO does not follow, one of these fails.
void main() {
  group('inventory DTOs against real gateway responses', () {
  test('GoodsReceiptDto parses the live response', () {
    const payload = {
      'id': 87,
      'docNo': 'GR-2026-00087',
      'docDate': '2026-09-28',
      'supplierId': 1,
      'supplierName': 'Baku Food Supply',
      'locationId': 1,
      'locationName': 'Mərkəzi anbar',
      'qualityStatus': 'ACCEPTED',
      'status': 'POSTED',
      'hasVariance': false,
      'lineCount': 1,
      'rowVersion': 2,
      'movementGroupId': 334,
      'postedAt': '2026-09-28T14:45:23.916+00:00',
      'lines': [
        {
          'id': 90,
          'lineNo': 1,
          'product': {
            'id': 6,
            'sku': 'ONION',
            'name': 'Soğan',
            'baseUomId': 1,
            'baseUomCode': 'G',
            'requiresBatch': false,
            'requiresExpiry': false,
          },
          'receivedQty': '21.3589',
          'rejectedQty': '0.0000',
          'uomId': 1,
          'uomCode': 'G',
          'acceptedQtyBase': '21.3589',
        },
      ],
      'attachmentIds': <Object?>[],
      'audit': {
        'createdAt': '2026-09-28T14:45:23.744+00:00',
        'createdBy': 4,
        'updatedAt': '2026-09-28T14:45:23.923+00:00',
        'updatedBy': 4,
        'rowVersion': 2,
      },
    };

    final dto = GoodsReceiptDto.fromJson(payload);
    expect(dto.docNo, isNotEmpty);
    expect(dto.lines, isNotEmpty);
  });

  test('IssueDto parses the live response', () {
    const payload = {
      'id': 111,
      'docNo': 'IS-2026-00108',
      'docDate': '2026-09-28',
      'issueType': 'BRANCH_ISSUE',
      'fromLocation': {
        'id': 1,
        'code': 'WH-01',
        'name': 'Mərkəzi anbar',
        'isVirtual': false,
      },
      'toLocation': {
        'id': 2,
        'code': 'BR-ELM',
        'name': 'Elmlər filialı',
        'isVirtual': false,
      },
      'status': 'DISPATCHED',
      'dispatchedAt': '2026-09-28T14:45:19.148+00:00',
      'lineCount': 1,
      'rowVersion': 2,
      'dispatchGroupId': 329,
      'lines': [
        {
          'id': 117,
          'lineNo': 1,
          'product': {
            'id': 2,
            'sku': 'CHICKEN',
            'name': 'Toyuq',
            'baseUomId': 1,
            'baseUomCode': 'G',
            'requiresBatch': false,
            'requiresExpiry': false,
          },
          'qty': '12.8827',
          'uomId': 1,
          'uomCode': 'G',
          'qtyBase': '12.8827',
          'batch': {
            'id': 15,
            'batchNo': 'CHICKEN-2026C',
            'expiryDate': '2026-10-16',
            'status': 'ACTIVE',
          },
          'suggestedBatch': {
            'id': 15,
            'batchNo': 'CHICKEN-2026C',
            'expiryDate': '2026-10-16',
            'status': 'ACTIVE',
          },
          'unitCost': '0.0182',
        },
      ],
      'audit': {
        'createdAt': '2026-09-28T14:45:18.984+00:00',
        'createdBy': 4,
        'updatedAt': '2026-09-28T14:45:19.155+00:00',
        'updatedBy': 4,
        'rowVersion': 2,
      },
    };

    final dto = IssueDto.fromJson(payload);
    expect(dto.docNo, isNotEmpty);
    expect(dto.lines, isNotEmpty);
  });

  test('WasteDto parses the live response', () {
    const payload = {
      'id': 56,
      'docNo': 'WS-2026-00056',
      'docDate': '2026-09-28',
      'location': {
        'id': 1,
        'code': 'WH-01',
        'name': 'Mərkəzi anbar',
        'isVirtual': false,
      },
      'reasonCodeId': 6,
      'reasonCodeName': 'Zədələnmiş',
      'status': 'DRAFT',
      'totalValue': '0',
      'lineCount': 1,
      'rowVersion': 1,
      'note': 'e2e — zədələnmiş qablaşdırma',
      'lines': [
        {
          'id': 56,
          'lineNo': 1,
          'product': {
            'id': 4,
            'sku': 'TOMATO',
            'name': 'Pomidor',
            'baseUomId': 1,
            'baseUomCode': 'G',
            'requiresBatch': true,
            'requiresExpiry': true,
          },
          'batch': {
            'id': 5,
            'batchNo': 'TOMATO-2026B',
            'expiryDate': '2026-09-25',
            'status': 'EXPIRED',
          },
          'qty': '4.2466',
          'uomId': 1,
          'uomCode': 'G',
          'qtyBase': '0.0000',
        },
      ],
      'attachmentIds': <Object?>[],
      'audit': {
        'createdAt': '2026-09-28T14:45:22.474+00:00',
        'createdBy': 4,
        'rowVersion': 1,
      },
    };

    final dto = WasteDto.fromJson(payload);
    expect(dto.docNo, isNotEmpty);
    expect(dto.lines, isNotEmpty);
  });

  test('CountDto parses the live response', () {
    const payload = {
      'id': 85,
      'docNo': 'IC-2026-00087',
      'location': {
        'id': 906,
        'code': 'BR-GNC',
        'name': 'Gənclik filialı',
        'isVirtual': false,
      },
      'countType': 'FULL',
      'status': 'CANCELLED',
      'requiresApproval': false,
      'lineCount': 0,
      'countedLineCount': 0,
      'varianceLineCount': 0,
      'rowVersion': 2,
      'totalVarianceValue': '0',
      'lines': <Object?>[],
      'audit': {
        'createdAt': '2026-09-28T14:45:29.016+00:00',
        'createdBy': 4,
        'updatedAt': '2026-09-28T14:45:29.354+00:00',
        'updatedBy': 1,
        'rowVersion': 2,
      },
    };

    final dto = CountDto.fromJson(payload);
    expect(dto.docNo, isNotEmpty);
    // This count was frozen with no lines entered yet, so an empty list is the real answer.
    expect(dto.lines, isEmpty);
    // `CountSummary` embeds a LocationRef, unlike `GoodsReceiptSummary`'s flat ids.
    expect(dto.location.code, 'BR-GNC');
  });

  test('StockRequestDto parses the live response', () {
    const payload = {
      'id': 9,
      'docNo': 'SR-2026-00006',
      'docDate': '2026-09-22',
      'fromLocation': {
        'id': 1,
        'code': 'WH-01',
        'name': 'Mərkəzi anbar',
        'isVirtual': false,
      },
      'toLocation': {
        'id': 904,
        'code': 'BR-NIZ',
        'name': 'Nizami filialı',
        'isVirtual': false,
      },
      'status': 'CANCELLED',
      'lineCount': 1,
      'rowVersion': 2,
      'lines': [
        {
          'id': 14,
          'lineNo': 1,
          'product': {
            'id': 2,
            'sku': 'CHICKEN',
            'name': 'Toyuq',
            'baseUomId': 1,
            'baseUomCode': 'G',
            'requiresBatch': false,
            'requiresExpiry': false,
          },
          'qty': '10.0000',
          'uomId': 1,
          'uomCode': 'G',
          'issuedQty': '0.0000',
        },
      ],
      'issueIds': <Object?>[],
      'audit': {
        'createdAt': '2026-09-22T16:24:31.727+00:00',
        'createdBy': 5,
        'updatedAt': '2026-09-22T16:24:44.921+00:00',
        'updatedBy': 5,
        'rowVersion': 2,
      },
    };

    final dto = StockRequestDto.fromJson(payload);
    expect(dto.docNo, isNotEmpty);
    expect(dto.lines, isNotEmpty);
  });
  });

  group('request bodies against what the gateway accepts', () {
    // These four bodies were rejected before this test existed. The gateway either refused to bind
    // them (`Failed to read parameter ... as JSON`, HTTP 400) or bound them to nothing and failed
    // validation, so waste, samples, count entry and receipt confirmation could not be submitted
    // from the app at all. Each expectation below is the exact JSON a POST answered 201 with.
    test('CreateWasteRequest nests the quantity with its unit', () {
      final body = CreateWasteRequest(
        docDate: DateTime.utc(2026, 9, 29),
        locationId: 1,
        reasonCodeId: 6,
        lines: [
          CreateWasteLine(
            productId: 6,
            quantity: QuantityInput(value: Quantity.parse('1'), uomId: 1),
          ),
        ],
      ).toJson();

      expect(body['lines'], [
        {'productId': 6, 'quantity': {'value': '1.0000', 'uomId': 1}, 'batchId': null, 'note': null},
      ]);
      // A flat `qty` beside a `uomId` is what the DTO used to send, and the server cannot read it.
      expect((body['lines']! as List).first, isNot(contains('qty')));
    });

    test('CreateSampleRequest nests the quantity too', () {
      final body = CreateSampleRequest(
        docDate: DateTime.utc(2026, 9, 29),
        locationId: 1,
        lines: [
          CreateSampleLine(
            productId: 6,
            quantity: QuantityInput(value: Quantity.parse('0.5'), uomId: 1),
          ),
        ],
      ).toJson();

      expect(((body['lines']! as List).first as Map)['quantity'], {
        'value': '0.5000',
        'uomId': 1,
      });
    });

    test('EnterCountRequest addresses the line by product, not by line id', () {
      final body = EnterCountRequest(
        rowVersion: 2,
        lines: [
          EnterCountLine(
            productId: 6,
            countedQuantity: QuantityInput(value: Quantity.parse('12'), uomId: 1),
            reasonCodeId: 9,
          ),
        ],
      ).toJson();

      final line = (body['lines']! as List).first as Map;
      expect(line['productId'], 6);
      expect(line['countedQuantity'], {'value': '12.0000', 'uomId': 1});
      // `lineId` and `countedQty` are what this used to send; the server binds neither.
      expect(line, isNot(contains('lineId')));
      expect(line, isNot(contains('countedQty')));
    });

    test('ConfirmIssueRequest identifies the line by id and carries the reason', () {
      final body = ConfirmIssueRequest(
        rowVersion: 2,
        lines: [
          ConfirmIssueLine(
            lineId: 117,
            receivedQty: Quantity.parse('11'),
            reasonCodeId: 4,
            note: 'bir qutu çatışmır',
          ),
        ],
      ).toJson();

      final line = (body['lines']! as List).first as Map;
      expect(line['lineId'], 117);
      expect(line['receivedQty'], '11.0000');
      // Mandatory whenever the received quantity differs from the dispatched one.
      expect(line['reasonCodeId'], 4);
      expect(line, isNot(contains('lineNo')));
    });
  });
}
