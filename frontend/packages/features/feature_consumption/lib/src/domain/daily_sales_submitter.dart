import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_core/wms_core.dart';

import 'consumption_repository.dart';
import 'daily_sales_draft.dart';

/// Turns «Satışı təsdiqlə» into the right pair of API calls.
///
/// `(location, businessDate)` is unique, so the screen cannot just `POST`:
/// a second call for the same day answers `409 DUPLICATE_BUSINESS_DATE`.
/// The day's document is looked up first and the path chosen from its
/// status (see [planDailySales]); only then is it submitted.
class DailySalesSubmitter {
  const DailySalesSubmitter(this._repository);

  final ConsumptionRepository _repository;

  /// Returns the submitted import, or the failure that stopped it.
  ///
  /// A day that is already `SUBMITTED`/`CONSUMED`/`CANCELLED` is not an
  /// exception: it comes back as a [ConflictFailure] carrying
  /// `DUPLICATE_BUSINESS_DATE`, so the screen shows it through `WmsAlert`
  /// with the code, like any other server conflict.
  Future<Result<SalesImportDto>> submit({
    required int locationId,
    required DateTime businessDate,
    required DailySalesDraft draft,
    SalesImportDto? existing,
  }) async {
    if (draft.isEmpty) {
      return Result.err(
        ValidationFailure(
          ProblemDetails.local(
            code: ProblemCodes.validationError,
            title: 'Satış sətri yoxdur',
            detail: 'Ən azı bir menyu maddəsi üçün satılan sayı yazın.',
            status: 422,
          ),
        ),
      );
    }

    final action = planDailySales(existing);
    final saved = switch (action) {
      CreateAndSubmit() => await _create(locationId, businessDate, draft),
      ReplaceAndSubmit(:final importId, :final rowVersion) => await _replace(
        importId,
        rowVersion,
        draft,
      ),
      DailySalesBlocked(:final status) => Result<_Handle>.err(
        ConflictFailure(
          ProblemDetails.local(
            code: ProblemCodes.duplicateBusinessDate,
            title: 'Bu günün satışı artıq təsdiqlənib',
            detail:
                'Sənədin statusu ${status.wire}. Bir gün üçün bir sənəd olur; '
                'düzəliş yalnız storno ilə mümkündür.',
            status: 409,
          ),
        ),
      ),
    };

    return switch (saved) {
      Err<_Handle>(:final failure) => Result.err(failure),
      Ok<_Handle>(:final value) => await _repository.submitSalesImport(
        value.id,
        rowVersion: value.rowVersion,
      ),
    };
  }

  Future<Result<_Handle>> _create(
    int locationId,
    DateTime businessDate,
    DailySalesDraft draft,
  ) async {
    final result = await _repository.createSalesImport(
      CreateSalesImportRequest(
        locationId: locationId,
        businessDate: businessDate,
        source: SalesSource.manual,
        lines: draft.toLines(),
      ),
    );
    return result.map((dto) => _Handle(dto.id, dto.rowVersion));
  }

  Future<Result<_Handle>> _replace(
    int importId,
    int rowVersion,
    DailySalesDraft draft,
  ) async {
    final result = await _repository.updateSalesImport(
      importId,
      UpdateSalesImportRequest(rowVersion: rowVersion, lines: draft.toLines()),
    );
    return result.map((dto) => _Handle(dto.id, dto.rowVersion));
  }
}

/// Just enough of the saved document to submit it.
class _Handle {
  const _Handle(this.id, this.rowVersion);

  final int id;
  final int rowVersion;
}
