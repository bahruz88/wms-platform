import 'package:feature_consumption/feature_consumption.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import 'fake_consumption_repository.dart';

final _draft = const DailySalesDraft()
    .withQuantity(1, Quantity.fromInt(120))
    .withQuantity(2, Quantity.fromInt(35));

final _businessDate = DateTime(2026, 9, 21);

SalesImportDto _existing(SalesImportStatus status, {int rowVersion = 3}) =>
    SalesImportDto(
      id: 42,
      locationId: 1,
      businessDate: _businessDate,
      source: SalesSource.manual,
      status: status,
      rowVersion: rowVersion,
    );

void main() {
  test('a free day is created as MANUAL and then submitted', () async {
    final repository = FakeConsumptionRepository();
    final result = await DailySalesSubmitter(repository)
        .submit(locationId: 1, businessDate: _businessDate, draft: _draft);

    expect(result.isOk, isTrue);
    expect(repository.createdImports, hasLength(1));
    final created = repository.createdImports.single;
    expect(created.source, SalesSource.manual);
    expect(created.locationId, 1);
    expect(created.businessDate, _businessDate);
    expect(created.lines, hasLength(2));
    // DRAFT → SUBMITTED is the whole point of the button.
    expect(repository.submitted, [501]);
    expect(result.valueOrNull!.status, SalesImportStatus.submitted);
  });

  test(
    'an existing DRAFT is replaced with its row version, then submitted',
    () async {
      final repository = FakeConsumptionRepository();
      final result = await DailySalesSubmitter(repository).submit(
        locationId: 1,
        businessDate: _businessDate,
        draft: _draft,
        existing: _existing(SalesImportStatus.draft),
      );

      expect(result.isOk, isTrue);
      expect(repository.createdImports, isEmpty);
      expect(repository.updatedImports.single.rowVersion, 3);
      expect(repository.submitted, [42]);
    },
  );

  test(
    'a submitted day is refused with DUPLICATE_BUSINESS_DATE, not a POST',
    () async {
      final repository = FakeConsumptionRepository();
      final result = await DailySalesSubmitter(repository).submit(
        locationId: 1,
        businessDate: _businessDate,
        draft: _draft,
        existing: _existing(SalesImportStatus.submitted),
      );

      expect(result.isErr, isTrue);
      final failure = result.failureOrNull! as ConflictFailure;
      expect(failure.code, ProblemCodes.duplicateBusinessDate);
      expect(failure.problem.detail, contains('SUBMITTED'));
      expect(repository.createdImports, isEmpty);
      expect(repository.updatedImports, isEmpty);
      expect(repository.submitted, isEmpty);
    },
  );

  test('an empty draft never reaches the server', () async {
    final repository = FakeConsumptionRepository();
    final result = await DailySalesSubmitter(repository).submit(
      locationId: 1,
      businessDate: _businessDate,
      draft: const DailySalesDraft(),
    );

    expect(result.isErr, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(repository.createdImports, isEmpty);
    expect(repository.submitted, isEmpty);
  });

  test('a failed save is not followed by a submit', () async {
    final repository = FakeConsumptionRepository(
      failure: const NetworkFailure(),
    );
    final result = await DailySalesSubmitter(repository)
        .submit(locationId: 1, businessDate: _businessDate, draft: _draft);

    expect(result.isErr, isTrue);
    expect(repository.submitted, isEmpty);
  });
}
