@Tags(['live'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

/// The mobile client against the **running** gateway.
///
/// The widget tests render screens from fixtures and the DTO tests parse captured payloads; neither
/// makes a request. That is exactly the gap this file closes, because the defect it guards against
/// was invisible to both: the DTOs disagreed with the wire, their fixtures agreed with the DTOs, and
/// 266 green tests said nothing while the client could not read a single response.
///
/// Opt-in. Without `WMS_LIVE_BASE_URL` the whole group is skipped, so a machine with no stack — CI,
/// a fresh checkout — is not failed by its absence:
///
///     WMS_LIVE_BASE_URL=http://localhost:5001/api/v1 \
///     WMS_LIVE_KEYCLOAK_URL=http://localhost:8180 \
///     flutter test test/live_gateway_test.dart
void main() {
  // The module APIs prepend only their own prefix (`/inventory`, …), so the base URL carries the
  // version segment — the same split `CONVENTIONS.md` documents.
  final configured = Platform.environment['WMS_LIVE_BASE_URL'];
  final baseUrl = configured == null
      ? null
      : (configured.contains('/api/v') ? configured : '${configured.replaceAll(RegExp(r'/+$'), '')}/api/v1');
  final keycloak = Platform.environment['WMS_LIVE_KEYCLOAK_URL'] ?? 'http://localhost:8180';

  group(
    'live gateway',
    skip: baseUrl == null
        ? 'set WMS_LIVE_BASE_URL to run against a running stack'
        : null,
    () {
      late WmsApiClient client;

      setUpAll(() async {
        final token = await _signIn(keycloak, 'admin', 'admin');
        client = WmsApiClient(
          baseUrl: baseUrl!,
          tokenProvider: StaticTokenProvider(token),
          enableLogging: false,
        );
      });

      tearDownAll(() => client.dio.close(force: true));

      test('identity answers who the caller is', () async {
        final me = await client.identity.me();
        expect(me.username, isNotEmpty);
        expect(me.permissions, isNotEmpty);
      });

      // One test per module, each parsing a real response through the real DTOs. A shape that drifts
      // fails here with the field that broke, rather than in a screen months later.
      test('inventory lists parse', () async {
        final balances = await client.inventory.listBalances(page: const PageRequest(size: 20));
        expect(balances.items, isNotEmpty);
        expect(balances.items.first.product.sku, isNotEmpty);
        expect(balances.items.first.location.code, isNotEmpty);

        final batches = await client.inventory.listBatches(page: const PageRequest(size: 10));
        for (final batch in batches.items) {
          expect(batch.product.id, greaterThan(0));
        }

        final receipts = await client.inventory.listGoodsReceipts(page: const PageRequest(size: 10));
        for (final receipt in receipts.items) {
          expect(receipt.docNo, isNotEmpty);
        }

        final issues = await client.inventory.listIssues(page: const PageRequest(size: 10));
        for (final issue in issues.items) {
          expect(issue.fromLocation.code, isNotEmpty);
          expect(issue.toLocation.code, isNotEmpty);
        }

        final counts = await client.inventory.listCounts(page: const PageRequest(size: 10));
        for (final count in counts.items) {
          expect(count.location.code, isNotEmpty);
        }

        final requests = await client.inventory.listStockRequests(page: const PageRequest(size: 10));
        for (final request in requests.items) {
          expect(request.fromLocation.code, isNotEmpty);
        }
      });

      test('reference data parses', () async {
        final products = await client.masterData.listProducts(page: const PageRequest(size: 20));
        expect(products.items, isNotEmpty);
        expect(products.items.first.sku, isNotEmpty);

        expect(await client.masterData.listCategories(), isNotEmpty);
        expect(await client.masterData.listUoms(), isNotEmpty);
        expect(await client.masterData.listLocations(), isNotEmpty);
        expect(await client.masterData.listReasonCodes(), isNotEmpty);

        final suppliers = await client.masterData.listSuppliers(page: const PageRequest(size: 10));
        expect(suppliers.items, isNotEmpty);
      });

      test('procurement lists parse', () async {
        final requisitions = await client.procurement.listRequisitions(page: const PageRequest(size: 10));
        for (final requisition in requisitions.items) {
          expect(requisition.requesterLocation.code, isNotEmpty);
        }

        final orders = await client.procurement.listPurchaseOrders(page: const PageRequest(size: 10));
        for (final order in orders.items) {
          expect(order.supplier.name, isNotEmpty);
          expect(order.deliveryLocation.code, isNotEmpty);
        }

        final rfqs = await client.procurement.listRfqs(page: const PageRequest(size: 10));
        for (final rfq in rfqs.items) {
          expect(rfq.docNo, isNotEmpty);
        }
      });

      test('the dashboard parses as a KPI list', () async {
        final dashboard = await client.reporting.getDashboard();
        expect(dashboard.kpis, isNotEmpty);
        // `admin` holds the cost permission, so at least one cost figure must come through.
        expect(dashboard.hasCostFigures, isTrue);
        for (final kpi in dashboard.kpis) {
          expect(kpi.key, isNotEmpty);
          expect(kpi.label, isNotEmpty);
        }

        expect(await client.reporting.listReports(), isNotEmpty);
      });

      test('the notification inbox and its badge parse', () async {
        final inbox = await client.notifications.list(page: const PageRequest(size: 20));
        for (final item in inbox.items) {
          expect(item.eventType, isNotEmpty);
          expect(item.severity, isIn(['INFO', 'WARNING', 'CRITICAL']));
        }

        final unread = await client.notifications.unreadCount();
        // The contract requires all three keys, zero included.
        for (final severity in ['INFO', 'WARNING', 'CRITICAL']) {
          expect(unread.bySeverity, containsPair(severity, isA<int>()));
        }
        expect(unread.total, unread.bySeverity.values.fold<int>(0, (a, b) => a + b));
      });
    },
  );
}

/// Password grant against the dev realm. The realm is not what is under test here.
Future<String> _signIn(String keycloak, String username, String password) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(
      Uri.parse('$keycloak/realms/wms/protocol/openid-connect/token'),
    );
    request.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
    request.write(
      'grant_type=password&client_id=wms-web&scope=openid'
      '&username=$username&password=$password',
    );
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      throw StateError('sign-in failed (${response.statusCode}): $body');
    }
    return (jsonDecode(body) as Map<String, Object?>)['access_token']! as String;
  } finally {
    client.close(force: true);
  }
}
