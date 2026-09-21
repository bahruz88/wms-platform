import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_core/wms_core.dart';
import 'package:wms_design_system/wms_design_system.dart';

Widget host(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? WmsTheme.light(),
  home: Scaffold(
    body: Center(child: SingleChildScrollView(child: child)),
  ),
);

void main() {
  group('WmsButton', () {
    testWidgets('loading disables the button and keeps its width', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        host(WmsButton.primary(label: 'Post et', onPressed: () => taps++)),
      );
      final idleWidth = tester.getSize(find.byType(WmsButton)).width;
      await tester.tap(find.text('Post et'));
      expect(taps, 1);

      await tester.pumpWidget(
        host(
          WmsButton.primary(
            label: 'Post et',
            loading: true,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.pump();
      expect(tester.getSize(find.byType(WmsButton)).width, idleWidth);
      expect(find.byType(WmsSpinner), findsOneWidget);
      await tester.tap(find.byType(WmsButton));
      expect(taps, 1, reason: 'loading button must not fire again');
    });

    testWidgets('disabled button explains why via tooltip', (tester) async {
      await tester.pumpWidget(
        host(
          const WmsButton(
            label: 'Post et',
            onPressed: null,
            enabled: false,
            disabledReason: 'Lokasiya sayım üçün dondurulub',
          ),
        ),
      );
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip).first);
      expect(tooltip.message, 'Lokasiya sayım üçün dondurulub');
    });

    testWidgets('meets the 34px / 28px min heights from bundle.css', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WmsButton(label: 'Orta', onPressed: null),
              WmsButton(
                label: 'Kiçik',
                size: WmsButtonSize.sm,
                onPressed: null,
              ),
            ],
          ),
        ),
      );
      double heightOf(String label) => tester
          .getSize(
            find
                .ancestor(
                  of: find.text(label),
                  matching: find.byType(Container),
                )
                .first,
          )
          .height;
      expect(heightOf('Orta'), greaterThanOrEqualTo(34));
      expect(heightOf('Kiçik'), greaterThanOrEqualTo(28));
    });
  });

  group('WmsDocStatusBadge', () {
    testWidgets('maps the ENUM to an Azerbaijani label and keeps the code', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const WmsDocStatusBadge(status: 'PENDING_APPROVAL')),
      );
      expect(find.text('Təsdiq gözləyir'), findsOneWidget);
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'PENDING_APPROVAL');
    });

    testWidgets('unknown status is shown verbatim in the neutral tone', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const WmsDocStatusBadge(status: 'SOME_NEW_STATE')),
      );
      expect(find.text('SOME_NEW_STATE'), findsOneWidget);
      expect(WmsDocStatusBadge.resolve('SOME_NEW_STATE').$2, WmsTone.neutral);
    });

    test('never upper-cases the Azerbaijani labels (i/İ rule)', () {
      for (final entry in WmsDocStatusBadge.statuses.entries) {
        final label = entry.value.$1;
        if (label == entry.key) continue; // verbatim ENUM fallbacks
        expect(
          label,
          isNot(equals(label.toUpperCase())),
          reason: '${entry.key} label must not be upper-case',
        );
      }
    });
  });

  group('WmsAlert', () {
    testWidgets('copies an RFC 7807 problem verbatim and shows the code', (
      tester,
    ) async {
      const problem = ProblemDetails(
        type: 'https://wms/errors/insufficient-stock',
        title: 'Kifayət qədər stok yoxdur',
        status: 409,
        code: 'INSUFFICIENT_STOCK',
        detail: 'Chicken Strips: mövcud 45.0000 KG, tələb olunan 60.0000 KG',
        traceId: '00-abc',
      );
      await tester.pumpWidget(host(WmsAlert.fromProblem(problem)));
      expect(find.text('Kifayət qədər stok yoxdur'), findsOneWidget);
      expect(find.textContaining('mövcud 45.0000 KG'), findsOneWidget);
      expect(find.textContaining('INSUFFICIENT_STOCK'), findsOneWidget);
      expect(find.textContaining('00-abc'), findsOneWidget);
      final semantics = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.byType(Container),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.properties.liveRegion, isTrue);
    });

    testWidgets('network failures become a danger alert with a code', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(WmsAlert.fromFailure(const NetworkFailure(isTimeout: true))),
      );
      expect(find.text('Server cavab vermədi'), findsOneWidget);
      expect(find.textContaining(ProblemCodes.timeout), findsOneWidget);
    });
  });

  group('WmsQtyUomInput', () {
    final uoms = [
      WmsProductUom(id: 1, code: 'PCS', factorToBase: Decimal.one),
      WmsProductUom(id: 2, code: 'CASE', factorToBase: Decimal.fromInt(12)),
    ];

    testWidgets('shows the base equivalent and does not convert the number', (
      tester,
    ) async {
      var uomId = 2;
      Quantity? qty;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => WmsQtyUomInput(
              uoms: uoms,
              baseUomCode: 'PCS',
              decimals: 0,
              uomId: uomId,
              onQtyChanged: (v) => qty = v,
              onUomChanged: (id) => setState(() => uomId = id),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '8');
      await tester.pump();
      expect(qty, Quantity.fromInt(8));
      expect(find.text('= 96 PCS · əmsal 12'), findsOneWidget);

      // Switching to the base unit keeps the typed number and drops the line.
      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PCS').last);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '8'), findsOneWidget);
      expect(find.byKey(const ValueKey('wms-qty-base')), findsNothing);
    });

    testWidgets('rejects negative quantities', (tester) async {
      Quantity? qty = Quantity.fromInt(1);
      await tester.pumpWidget(
        host(
          WmsQtyUomInput(
            uoms: uoms,
            baseUomCode: 'PCS',
            onQtyChanged: (v) => qty = v,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '-5');
      await tester.pump();
      // The formatter strips '-', so the value can never become negative.
      expect(
        qty,
        isNot(isA<Quantity>().having((q) => q.isNegative, 'isNegative', true)),
      );
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('exceeding the available stock shows the available figure', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          WmsQtyUomInput(
            uoms: uoms,
            baseUomCode: 'PCS',
            decimals: 0,
            uomId: 1,
            available: Quantity.fromInt(45),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '60');
      await tester.pump();
      expect(find.textContaining('Mövcud qalıqdan çoxdur'), findsOneWidget);
      expect(find.textContaining('45'), findsWidgets);
    });
  });

  group('WmsDataTable', () {
    final rows = [
      (sku: 'CHS-0042', qty: Quantity.parse('45.5'), cost: Money.parse('12.5')),
      (sku: 'BRD-0001', qty: Quantity.parse('-3'), cost: Money.parse('2')),
    ];
    List<WmsColumn<({String sku, Quantity qty, Money cost})>> columns() => [
      WmsColumn(key: 'sku', header: 'SKU', cell: (r) => r.sku),
      WmsColumn(
        key: 'qty',
        header: 'Miqdar',
        numeric: true,
        cell: (r) => WmsFormat.quantity(r.qty),
      ),
      WmsColumn(
        key: 'cost',
        header: 'Maya',
        numeric: true,
        permission: Permissions.productViewCost,
        cell: (r) => WmsFormat.money(r.cost),
      ),
    ];

    testWidgets('renders a permission-gated column only with the permission', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(WmsDataTable(columns: columns(), rows: rows)),
      );
      expect(find.text('SKU'), findsOneWidget);
      expect(find.text('Maya'), findsNothing);
      expect(find.textContaining('12,50'), findsNothing);
      expect(find.textContaining('***'), findsNothing);

      await tester.pumpWidget(
        host(
          WmsDataTable(
            columns: columns(),
            rows: rows,
            permissions: const {Permissions.productViewCost},
          ),
        ),
      );
      expect(find.text('Maya'), findsOneWidget);
      expect(
        find.text('12,50'),
        findsOneWidget,
        reason: 'money uses 2 decimals',
      );
    });

    testWidgets('empty state states the reason and the next step', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          WmsDataTable<({String sku, Quantity qty, Money cost})>(
            columns: columns(),
            rows: const [],
            emptyReason: 'Bu lokasiyada qalıq yoxdur.',
            emptyNextStep: 'Qəbul sənədi yaradın.',
          ),
        ),
      );
      expect(find.text('Bu lokasiyada qalıq yoxdur.'), findsOneWidget);
      expect(find.text('Qəbul sənədi yaradın.'), findsOneWidget);
      expect(find.text('Məlumat yoxdur'), findsNothing);
    });
  });

  group('WmsLedgerTable', () {
    final lines = [
      WmsLedgerLine(
        lineNo: 1,
        product: 'Chicken Strips',
        sku: 'CHS-0042',
        location: 'V_SUPPLIER',
        locationType: LocationType.vSupplier,
        qtyBase: Quantity.parse('-100'),
        uom: 'KG',
      ),
      WmsLedgerLine(
        lineNo: 2,
        product: 'Chicken Strips',
        sku: 'CHS-0042',
        location: 'Food WH',
        locationType: LocationType.centralWarehouse,
        qtyBase: Quantity.parse('100'),
        uom: 'KG',
      ),
    ];

    testWidgets('shows signs, badges virtual locations and confirms zero sum', (
      tester,
    ) async {
      await tester.pumpWidget(host(WmsLedgerTable(lines: lines, decimals: 0)));
      expect(find.text('−100'), findsOneWidget);
      expect(find.text('+100'), findsOneWidget);
      expect(find.text('V_SUPPLIER'), findsWidgets);
      expect(find.text(WmsLedgerTable.balancedText), findsOneWidget);
      expect(find.text('Maya'), findsNothing, reason: 'cost needs showCost');
    });

    testWidgets('unbalanced group is flagged as not postable', (tester) async {
      final broken = [lines.first];
      await tester.pumpWidget(host(WmsLedgerTable(lines: broken, decimals: 0)));
      expect(find.textContaining('sıfır deyil'), findsOneWidget);
      expect(find.textContaining('post edilə bilməz'), findsOneWidget);
      final table = WmsLedgerTable(lines: broken);
      expect(table.isBalanced, isFalse);
      expect(table.total, Quantity.parse('-100'));
    });
  });

  group('WmsVarianceIndicator', () {
    testWidgets('flags a missing reason code and required approval', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          WmsVarianceIndicator(
            book: Quantity.parse('100'),
            counted: Quantity.parse('97'),
            uom: 'KG',
            thresholdPct: Decimal.fromInt(2),
          ),
        ),
      );
      expect(find.textContaining('−3,000'), findsOneWidget);
      expect(find.textContaining('−3,00'), findsWidgets);
      expect(find.text(WmsVarianceIndicator.missingReasonText), findsOneWidget);
      expect(find.text(WmsVarianceIndicator.approvalText), findsOneWidget);
    });

    testWidgets('zero variance is neutral and needs nothing', (tester) async {
      await tester.pumpWidget(
        host(
          WmsVarianceIndicator(
            book: Quantity.parse('10'),
            counted: Quantity.parse('10'),
            thresholdPct: Decimal.fromInt(2),
          ),
        ),
      );
      expect(find.text(WmsVarianceIndicator.missingReasonText), findsNothing);
      expect(find.text(WmsVarianceIndicator.approvalText), findsNothing);
    });

    test('book = 0 counts as 100% and always requires approval', () {
      final indicator = WmsVarianceIndicator(
        book: Quantity.zero,
        counted: Quantity.parse('5'),
        thresholdPct: Decimal.fromInt(50),
        reasonCode: 'ADJ-01',
      );
      expect(indicator.variancePct, Decimal.fromInt(100));
      expect(indicator.requiresApproval, isTrue);
      expect(indicator.missingReason, isFalse);
    });
  });

  group('WmsBatchPicker', () {
    final today = DateTime(2026, 9, 20);
    final batches = [
      WmsBatchOption(
        id: 1,
        batchNo: 'B-NEW',
        available: Quantity.fromInt(50),
        expiryDate: DateTime(2027, 2),
      ),
      WmsBatchOption(
        id: 2,
        batchNo: 'B-OLD',
        available: Quantity.fromInt(20),
        expiryDate: DateTime(2026, 9, 25),
      ),
      WmsBatchOption(
        id: 3,
        batchNo: 'B-EXPIRED',
        available: Quantity.fromInt(42),
        expiryDate: DateTime(2026, 9),
        status: BatchStatus.expired,
      ),
    ];

    testWidgets(
      'badges the FEFO suggestion and keeps expired batches visible',
      (tester) async {
        await tester.pumpWidget(
          host(
            WmsBatchPicker(
              batches: batches,
              today: today,
              decimals: 0,
              uom: 'KG',
            ),
          ),
        );
        expect(find.text(WmsBatchPicker.suggestionLabelFefo), findsOneWidget);
        expect(find.text('B-EXPIRED'), findsOneWidget);
        expect(find.text('19 gün keçib'), findsOneWidget);
        expect(find.text('5 gün qalıb'), findsOneWidget);
      },
    );

    testWidgets('selecting another batch raises the reason warning', (
      tester,
    ) async {
      WmsBatchOption? offSuggestion;
      var selected = 2;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => WmsBatchPicker(
              batches: batches,
              today: today,
              value: selected,
              onChanged: (b) => setState(() => selected = b.id),
              onOffSuggestion: (b) => offSuggestion = b,
            ),
          ),
        ),
      );
      expect(
        find.byKey(const ValueKey('wms-batch-off-suggestion')),
        findsNothing,
      );
      await tester.tap(find.text('B-NEW'));
      await tester.pumpAndSettle();
      expect(offSuggestion?.batchNo, 'B-NEW');
      expect(
        find.byKey(const ValueKey('wms-batch-off-suggestion')),
        findsOneWidget,
      );
    });

    test(
      'sorts ACTIVE, QUARANTINE, BLOCKED, EXPIRED and suggests by strategy',
      () {
        final picker = WmsBatchPicker(
          batches: [
            ...batches,
            WmsBatchOption(
              id: 4,
              batchNo: 'B-QUAR',
              available: Quantity.fromInt(1),
              status: BatchStatus.quarantine,
              expiryDate: DateTime(2026, 9, 21),
            ),
          ],
          today: today,
        );
        expect(picker.sorted.map((b) => b.batchNo).toList(), [
          'B-OLD',
          'B-NEW',
          'B-QUAR',
          'B-EXPIRED',
        ]);
        expect(picker.suggested?.batchNo, 'B-OLD');
        final fifo = WmsBatchPicker(
          batches: [
            WmsBatchOption(
              id: 1,
              batchNo: 'B-1',
              available: Quantity.fromInt(5),
              expiryDate: DateTime(2027),
              receivedAt: DateTime(2026),
            ),
            WmsBatchOption(
              id: 2,
              batchNo: 'B-2',
              available: Quantity.fromInt(5),
              expiryDate: DateTime(2026, 10),
              receivedAt: DateTime(2026, 6),
            ),
          ],
          strategy: IssueStrategy.fifo,
        );
        expect(fifo.suggested?.batchNo, 'B-1');
      },
    );
  });

  group('WmsApprovalChain', () {
    testWidgets('shows every step, the current one and the delegation', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          WmsApprovalChain(
            steps: [
              WmsApprovalStep(
                stepNo: 1,
                role: 'PROCUREMENT_OFFICER',
                user: 'Nigar',
                decision: ApprovalStatus.approved,
                decidedAt: DateTime(2026, 9, 18, 10, 30),
                delegatedFrom: 'Rəşad',
              ),
              const WmsApprovalStep(
                stepNo: 2,
                role: 'PROCUREMENT_MANAGER',
                user: 'Elçin',
              ),
              const WmsApprovalStep(stepNo: 3, role: 'ADMIN'),
            ],
          ),
        ),
      );
      expect(find.text('PROCUREMENT_OFFICER'), findsOneWidget);
      expect(
        find.text('ADMIN'),
        findsOneWidget,
        reason: 'future steps stay visible',
      );
      expect(find.text('Təsdiqlənib'), findsOneWidget);
      expect(find.text('Qərar gözlənilir'), findsOneWidget);
      expect(find.text('Gözləyir'), findsOneWidget);
      expect(
        find.text('${WmsApprovalChain.delegationPrefix}Rəşad'),
        findsOneWidget,
      );
      expect(find.text('18.09.2026 10:30'), findsOneWidget);
    });

    test('current step defaults to the first pending one', () {
      const chain = WmsApprovalChain(
        steps: [
          WmsApprovalStep(
            stepNo: 1,
            role: 'A',
            decision: ApprovalStatus.approved,
          ),
          WmsApprovalStep(stepNo: 2, role: 'B'),
          WmsApprovalStep(stepNo: 3, role: 'C'),
        ],
      );
      expect(chain.effectiveCurrentStep, 2);
    });
  });

  group('WmsKpiCard', () {
    testWidgets('renders the figure with unit, delta and hint', (tester) async {
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 260,
            child: WmsKpiCard(
              label: 'Anbar dəyəri',
              value: Decimal.parse('1284.5'),
              decimals: 2,
              unit: 'AZN',
              delta: Decimal.parse('-3.2'),
              hint: 'Keçən aya nisbətən',
            ),
          ),
        ),
      );
      expect(find.text('Anbar dəyəri'), findsOneWidget);
      expect(find.text('1 284,50'), findsOneWidget);
      expect(find.text('AZN'), findsOneWidget);
      expect(find.text('−3,2 %'), findsOneWidget);
      expect(find.text('Keçən aya nisbətən'), findsOneWidget);
    });

    test('deltaTone can be overridden (falling waste is good)', () {
      final auto = WmsKpiCard(
        label: 'Tullantı',
        value: Decimal.fromInt(3),
        delta: Decimal.parse('-10'),
        hint: 'Keçən həftəyə nisbətən',
      );
      expect(auto.effectiveDeltaTone, WmsDeltaTone.down);
      final overridden = WmsKpiCard(
        label: 'Tullantı',
        value: Decimal.fromInt(3),
        delta: Decimal.parse('-10'),
        hint: 'Keçən həftəyə nisbətən',
        deltaTone: WmsDeltaTone.up,
      );
      expect(overridden.effectiveDeltaTone, WmsDeltaTone.up);
    });

    test('money KPI is not rendered without the permission', () {
      expect(
        WmsKpiCard.permitted(
          hasPermission: false,
          build: () => const SizedBox.shrink(),
        ),
        isNull,
      );
      expect(
        WmsKpiCard.permitted(
          hasPermission: true,
          build: () => const SizedBox.shrink(),
        ),
        isNotNull,
      );
    });
  });

  group('WmsDialog', () {
    testWidgets(
      'destructive confirm stays disabled until the field is filled',
      (tester) async {
        await tester.pumpWidget(
          host(
            const WmsConfirmDialog(
              title: 'Storno et',
              message:
                  'Bu sənəd ləğv ediləcək və yeni REVERSAL qrupu yaradılacaq.',
              confirmLabel: 'Storno et',
              destructive: true,
              confirmEnabled: false,
              disabledReason: 'Səbəb kodu seçilməyib',
            ),
          ),
        );
        expect(find.text('Storno et'), findsWidgets);
        expect(find.text('İmtina'), findsOneWidget);
        final confirm = tester.widget<WmsButton>(
          find.widgetWithText(WmsButton, 'Storno et'),
        );
        expect(confirm.isDisabled, isTrue);
        expect(confirm.variant, WmsButtonVariant.danger);
      },
    );
  });

  group('WmsAdaptiveScaffold', () {
    const destinations = [
      WmsDestination(label: 'Anbar', icon: Icons.inventory_2_outlined),
      WmsDestination(label: 'Sənədlər', icon: Icons.description_outlined),
      WmsDestination(
        label: 'Bildirişlər',
        icon: Icons.notifications_outlined,
        badgeCount: 3,
      ),
    ];

    Widget scaffold(Size size) => MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        theme: WmsTheme.light(),
        home: WmsAdaptiveScaffold(
          destinations: destinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          body: const Text('body'),
        ),
      ),
    );

    testWidgets('bottom navigation below 600px', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(scaffold(const Size(400, 800)));
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('3'), findsOneWidget, reason: 'unread badge');
    });

    testWidgets('navigation rail at 1280px', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(scaffold(const Size(1280, 900)));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });
  });
}
