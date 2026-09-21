import 'package:feature_notifications/feature_notifications.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';
import 'package:wms_l10n/wms_l10n.dart';

class _FakeNotificationsRepository implements NotificationsRepository {
  _FakeNotificationsRepository(this.items);

  List<NotificationDto> items;
  int markAllCalls = 0;

  @override
  Future<Result<Page<NotificationDto>>> list({
    bool? unreadOnly,
    PageRequest page = const PageRequest(),
  }) async {
    final filtered = unreadOnly ?? false
        ? items.where((n) => !n.isRead).toList()
        : items;
    return Result.ok(
      Page<NotificationDto>(
        items: filtered,
        page: 1,
        size: 50,
        total: filtered.length,
      ),
    );
  }

  @override
  Future<Result<int>> unreadCount() async =>
      Result.ok(items.where((n) => !n.isRead).length);

  @override
  Future<Result<void>> markRead(int id) async {
    items = [
      for (final n in items)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> markAllRead() async {
    markAllCalls++;
    items = [for (final n in items) n.copyWith(isRead: true)];
    return const Result.ok(null);
  }
}

final _items = [
  NotificationDto(
    id: 1,
    type: 'PO_APPROVED',
    title: 'PO-2026-00087 təsdiqləndi',
    body: 'Alfa MMC sifarişi təsdiqləndi.',
    createdAt: DateTime(2026, 9, 20, 10, 15),
    docType: 'PO',
  ),
  NotificationDto(
    id: 2,
    type: 'EXPIRY',
    title: 'Partiya vaxtı yaxınlaşır',
    createdAt: DateTime(2026, 9, 19, 8),
    isRead: true,
  ),
];

Widget host(NotificationsRepository repository) => ProviderScope(
  overrides: [notificationsRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(
    theme: WmsTheme.light(),
    locale: WmsL10n.defaultLocale,
    supportedLocales: WmsL10n.supportedLocales,
    localizationsDelegates: WmsL10n.delegates,
    home: const NotificationListScreen(),
  ),
);

void main() {
  testWidgets('lists notifications and shows the unread badge', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeNotificationsRepository([..._items]);
    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    expect(find.text('PO-2026-00087 təsdiqləndi'), findsOneWidget);
    expect(find.text('Partiya vaxtı yaxınlaşır'), findsOneWidget);
    expect(find.text('1 oxunmamış bildiriş'), findsOneWidget);
    expect(find.text('20.09.2026 10:15'), findsOneWidget);
  });

  testWidgets('mark all read clears the badge', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FakeNotificationsRepository([..._items]);
    await tester.pumpWidget(host(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hamısını oxunmuş et'));
    await tester.pumpAndSettle();
    expect(repository.markAllCalls, 1);
    expect(find.text('1 oxunmamış bildiriş'), findsNothing);
  });

  test('unread count falls back to 0 on failure', () async {
    final container = ProviderContainer(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(_FailingRepository()),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(unreadCountProvider.future), 0);
  });
}

class _FailingRepository implements NotificationsRepository {
  @override
  Future<Result<Page<NotificationDto>>> list({
    bool? unreadOnly,
    PageRequest page = const PageRequest(),
  }) async => const Result.err(NetworkFailure());

  @override
  Future<Result<int>> unreadCount() async => const Result.err(NetworkFailure());

  @override
  Future<Result<void>> markRead(int id) async =>
      const Result.err(NetworkFailure());

  @override
  Future<Result<void>> markAllRead() async =>
      const Result.err(NetworkFailure());
}
