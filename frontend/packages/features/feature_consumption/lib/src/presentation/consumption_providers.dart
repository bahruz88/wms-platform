import 'package:feature_identity/feature_identity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wms_api_client/wms_api_client.dart';
import 'package:wms_auth/wms_auth.dart';
import 'package:wms_core/wms_core.dart';

import '../data/consumption_repository_impl.dart';
import '../domain/consumption_repository.dart';
import '../domain/csv_file_picker.dart';
import '../domain/daily_sales_draft.dart';

final consumptionRepositoryProvider = Provider<ConsumptionRepository>(
  (ref) => ConsumptionRepositoryImpl(ref.watch(apiClientProvider).consumption),
);

/// Overridden by the web app with an `<input type="file">` implementation.
final csvFilePickerProvider = Provider<CsvFilePicker>(
  (ref) => const UnsupportedCsvFilePicker(),
);

/// Today at midnight, local time — the default business date everywhere.
DateTime todayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// The day the branch looks at in «İstehlak nəticəsi»: yesterday, because
/// `ConsumptionRunner` calculates the previous working day at 03:00.
DateTime yesterdayDate() => todayDate().subtract(const Duration(days: 1));

/// The branch the mobile screens work with: the first location on the
/// session (`iam_user_location`). `null` when the user has none, which the
/// screens explain instead of failing.
final branchLocationIdProvider = Provider<int?>((ref) {
  final locations = ref.watch(sessionProvider)?.locationIds ?? const <int>[];
  return locations.isEmpty ? null : locations.first;
});

// ---------------------------------------------------------------------------
// Menu items / recipes
// ---------------------------------------------------------------------------

/// Free-text filter of the menu item lists.
final menuItemSearchProvider = NotifierProvider<MenuItemSearchNotifier, String>(
  MenuItemSearchNotifier.new,
);

class MenuItemSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  // ignore: use_setters_to_change_properties
  void setSearch(String value) => state = value;
}

/// Sellable menu items (no sub-recipes) for the daily sales screen.
final sellableMenuItemsProvider = FutureProvider<Page<MenuItemDto>>((
  ref,
) async {
  final search = ref.watch(menuItemSearchProvider);
  final result = await ref
      .watch(consumptionRepositoryProvider)
      .menuItems(
        search: search.isEmpty ? null : search,
        isActive: true,
        isSubRecipe: false,
        page: const PageRequest(size: Page.maxSize),
      );
  return result.getOrThrow();
});

/// Catalogue filter: all items, only the ones with a recipe, or only the
/// ones without.
enum RecipeFilter { all, withRecipe, withoutRecipe }

@immutable
class MenuItemCatalogFilter {
  const MenuItemCatalogFilter({
    this.search = '',
    this.recipe = RecipeFilter.all,
    this.subRecipesOnly = false,
  });

  final String search;
  final RecipeFilter recipe;
  final bool subRecipesOnly;

  bool? get hasActiveRecipe => switch (recipe) {
    RecipeFilter.all => null,
    RecipeFilter.withRecipe => true,
    RecipeFilter.withoutRecipe => false,
  };

  MenuItemCatalogFilter copyWith({
    String? search,
    RecipeFilter? recipe,
    bool? subRecipesOnly,
  }) => MenuItemCatalogFilter(
    search: search ?? this.search,
    recipe: recipe ?? this.recipe,
    subRecipesOnly: subRecipesOnly ?? this.subRecipesOnly,
  );

  @override
  bool operator ==(Object other) =>
      other is MenuItemCatalogFilter &&
      other.search == search &&
      other.recipe == recipe &&
      other.subRecipesOnly == subRecipesOnly;

  @override
  int get hashCode => Object.hash(search, recipe, subRecipesOnly);
}

final menuItemCatalogFilterProvider =
    NotifierProvider<MenuItemCatalogFilterNotifier, MenuItemCatalogFilter>(
      MenuItemCatalogFilterNotifier.new,
    );

class MenuItemCatalogFilterNotifier extends Notifier<MenuItemCatalogFilter> {
  @override
  MenuItemCatalogFilter build() => const MenuItemCatalogFilter();

  // ignore: use_setters_to_change_properties
  void setFilter(MenuItemCatalogFilter filter) => state = filter;

  void setSearch(String value) => state = state.copyWith(search: value);

  void setRecipeFilter(RecipeFilter value) =>
      state = state.copyWith(recipe: value);

  void setSubRecipesOnly({required bool value}) =>
      state = state.copyWith(subRecipesOnly: value);
}

final menuItemCatalogProvider = FutureProvider<Page<MenuItemDto>>((ref) async {
  final filter = ref.watch(menuItemCatalogFilterProvider);
  final result = await ref
      .watch(consumptionRepositoryProvider)
      .menuItems(
        search: filter.search.isEmpty ? null : filter.search,
        isSubRecipe: filter.subRecipesOnly ? true : null,
        hasActiveRecipe: filter.hasActiveRecipe,
        page: const PageRequest(size: Page.maxSize),
      );
  return result.getOrThrow();
});

/// Menu items usable as a `SUB_RECIPE` component.
final subRecipeMenuItemsProvider = FutureProvider<List<MenuItemDto>>((
  ref,
) async {
  final result = await ref
      .watch(consumptionRepositoryProvider)
      .menuItems(
        isActive: true,
        isSubRecipe: true,
        page: const PageRequest(size: Page.maxSize),
      );
  return result.getOrThrow().items;
});

final recipeVersionsProvider =
    FutureProvider.family<List<RecipeSummaryDto>, int>((ref, menuItemId) async {
      final result = await ref
          .watch(consumptionRepositoryProvider)
          .recipeVersions(menuItemId);
      return result.getOrThrow();
    });

final recipeProvider = FutureProvider.family<RecipeDto, int>((ref, id) async {
  final result = await ref.watch(consumptionRepositoryProvider).recipe(id);
  return result.getOrThrow();
});

/// Arguments of the server side BOM explosion preview.
@immutable
class ExplosionRequest {
  const ExplosionRequest({required this.recipeId, required this.portions});

  final int recipeId;
  final Quantity portions;

  @override
  bool operator ==(Object other) =>
      other is ExplosionRequest &&
      other.recipeId == recipeId &&
      other.portions == portions;

  @override
  int get hashCode => Object.hash(recipeId, portions);
}

final recipeExplosionProvider =
    FutureProvider.family<RecipeExplosionDto, ExplosionRequest>((
      ref,
      request,
    ) async {
      final result = await ref
          .watch(consumptionRepositoryProvider)
          .explodeRecipe(request.recipeId, portions: request.portions);
      return result.getOrThrow();
    });

// ---------------------------------------------------------------------------
// Daily sales (mobile)
// ---------------------------------------------------------------------------

/// The business date the branch is entering sales for (default: today).
final salesBusinessDateProvider =
    NotifierProvider<SalesBusinessDateNotifier, DateTime>(
      SalesBusinessDateNotifier.new,
    );

class SalesBusinessDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => todayDate();

  // ignore: use_setters_to_change_properties
  void setDate(DateTime value) =>
      state = DateTime(value.year, value.month, value.day);
}

/// What the user has typed so far; survives scrolling and search changes.
final dailySalesDraftProvider =
    NotifierProvider<DailySalesDraftNotifier, DailySalesDraft>(
      DailySalesDraftNotifier.new,
    );

class DailySalesDraftNotifier extends Notifier<DailySalesDraft> {
  @override
  DailySalesDraft build() => const DailySalesDraft();

  void setQuantity(int menuItemId, Quantity? qty) =>
      state = state.withQuantity(menuItemId, qty);

  // ignore: use_setters_to_change_properties
  void seed(DailySalesDraft draft) => state = draft;

  void clear() => state = const DailySalesDraft();
}

/// The `(location, businessDate)` sales document, if one already exists.
/// `null` means the day is still free.
final dailySalesImportProvider = FutureProvider<SalesImportDto?>((ref) async {
  final locationId = ref.watch(branchLocationIdProvider);
  if (locationId == null) return null;
  final date = ref.watch(salesBusinessDateProvider);
  final result = await ref
      .watch(consumptionRepositoryProvider)
      .salesImports(
        locationId: locationId,
        dateFrom: date,
        dateTo: date,
        page: const PageRequest(size: 1),
      );
  final page = result.getOrThrow();
  return page.items.isEmpty ? null : page.items.first;
});

// ---------------------------------------------------------------------------
// Consumption runs
// ---------------------------------------------------------------------------

/// Yesterday's run for the branch, or `null` when it has not been made yet.
final branchRunOfDayProvider =
    FutureProvider.family<ConsumptionRunDto?, DateTime>((ref, date) async {
      final locationId = ref.watch(branchLocationIdProvider);
      if (locationId == null) return null;
      final result = await ref
          .watch(consumptionRepositoryProvider)
          .runs(
            locationId: locationId,
            dateFrom: date,
            dateTo: date,
            page: const PageRequest(size: 1),
          );
      final page = result.getOrThrow();
      return page.items.isEmpty ? null : page.items.first;
    });

final consumptionRunProvider =
    FutureProvider.family<ConsumptionRunDetailDto, int>((ref, id) async {
      final result = await ref.watch(consumptionRepositoryProvider).run(id);
      return result.getOrThrow();
    });

/// Journal filters (branch × day).
@immutable
class RunJournalFilter {
  const RunJournalFilter({
    this.locationId,
    this.dateFrom,
    this.dateTo,
    this.status,
    this.shortfallOnly = false,
  });

  final int? locationId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ConsumptionRunStatus? status;
  final bool shortfallOnly;

  bool? get hasShortfall => shortfallOnly ? true : null;

  RunJournalFilter copyWith({
    int? locationId,
    DateTime? dateFrom,
    DateTime? dateTo,
    ConsumptionRunStatus? status,
    bool? shortfallOnly,
    bool clearLocation = false,
    bool clearStatus = false,
  }) => RunJournalFilter(
    locationId: clearLocation ? null : (locationId ?? this.locationId),
    dateFrom: dateFrom ?? this.dateFrom,
    dateTo: dateTo ?? this.dateTo,
    status: clearStatus ? null : (status ?? this.status),
    shortfallOnly: shortfallOnly ?? this.shortfallOnly,
  );

  @override
  bool operator ==(Object other) =>
      other is RunJournalFilter &&
      other.locationId == locationId &&
      other.dateFrom == dateFrom &&
      other.dateTo == dateTo &&
      other.status == status &&
      other.shortfallOnly == shortfallOnly;

  @override
  int get hashCode =>
      Object.hash(locationId, dateFrom, dateTo, status, shortfallOnly);
}

final runJournalFilterProvider =
    NotifierProvider<RunJournalFilterNotifier, RunJournalFilter>(
      RunJournalFilterNotifier.new,
    );

class RunJournalFilterNotifier extends Notifier<RunJournalFilter> {
  @override
  RunJournalFilter build() => const RunJournalFilter();

  // ignore: use_setters_to_change_properties
  void setFilter(RunJournalFilter filter) => state = filter;

  void setLocation(int? locationId) => state = state.copyWith(
    locationId: locationId,
    clearLocation: locationId == null,
  );

  void setStatus(ConsumptionRunStatus? status) =>
      state = state.copyWith(status: status, clearStatus: status == null);

  void setShortfallOnly({required bool value}) =>
      state = state.copyWith(shortfallOnly: value);

  void setRange(DateTime? from, DateTime? to) =>
      state = state.copyWith(dateFrom: from, dateTo: to);
}

final runJournalProvider = FutureProvider<Page<ConsumptionRunDto>>((ref) async {
  final filter = ref.watch(runJournalFilterProvider);
  final result = await ref
      .watch(consumptionRepositoryProvider)
      .runs(
        locationId: filter.locationId,
        dateFrom: filter.dateFrom,
        dateTo: filter.dateTo,
        status: filter.status,
        hasShortfall: filter.hasShortfall,
      );
  return result.getOrThrow();
});

// ---------------------------------------------------------------------------
// Sales imports (manager)
// ---------------------------------------------------------------------------

final salesImportListProvider = FutureProvider<Page<SalesImportDto>>((
  ref,
) async {
  final result = await ref.watch(consumptionRepositoryProvider).salesImports();
  return result.getOrThrow();
});

final salesImportDetailProvider =
    FutureProvider.family<SalesImportDetailDto, int>((ref, id) async {
      final result = await ref
          .watch(consumptionRepositoryProvider)
          .salesImport(id);
      return result.getOrThrow();
    });

// ---------------------------------------------------------------------------
// Variance
// ---------------------------------------------------------------------------

/// Period of the variance report; both ends are mandatory on the server.
@immutable
class VarianceFilter {
  const VarianceFilter({
    required this.periodFrom,
    required this.periodTo,
    this.locationId,
    this.productId,
  });

  /// Last 30 days — long enough to span two counts in most branches.
  factory VarianceFilter.lastMonth() {
    final to = todayDate();
    return VarianceFilter(
      periodFrom: to.subtract(const Duration(days: 30)),
      periodTo: to,
    );
  }

  final DateTime periodFrom;
  final DateTime periodTo;
  final int? locationId;
  final int? productId;

  bool get isValid => !periodFrom.isAfter(periodTo);

  VarianceFilter copyWith({
    DateTime? periodFrom,
    DateTime? periodTo,
    int? locationId,
    int? productId,
    bool clearLocation = false,
    bool clearProduct = false,
  }) => VarianceFilter(
    periodFrom: periodFrom ?? this.periodFrom,
    periodTo: periodTo ?? this.periodTo,
    locationId: clearLocation ? null : (locationId ?? this.locationId),
    productId: clearProduct ? null : (productId ?? this.productId),
  );

  @override
  bool operator ==(Object other) =>
      other is VarianceFilter &&
      other.periodFrom == periodFrom &&
      other.periodTo == periodTo &&
      other.locationId == locationId &&
      other.productId == productId;

  @override
  int get hashCode => Object.hash(periodFrom, periodTo, locationId, productId);
}

final varianceFilterProvider =
    NotifierProvider<VarianceFilterNotifier, VarianceFilter>(
      VarianceFilterNotifier.new,
    );

class VarianceFilterNotifier extends Notifier<VarianceFilter> {
  @override
  VarianceFilter build() => VarianceFilter.lastMonth();

  // ignore: use_setters_to_change_properties
  void setFilter(VarianceFilter filter) => state = filter;

  void setLocation(int? locationId) => state = state.copyWith(
    locationId: locationId,
    clearLocation: locationId == null,
  );

  void setPeriod(DateTime from, DateTime to) =>
      state = state.copyWith(periodFrom: from, periodTo: to);
}

final varianceReportProvider = FutureProvider<ConsumptionVariancePageDto>((
  ref,
) async {
  final filter = ref.watch(varianceFilterProvider);
  final result = await ref
      .watch(consumptionRepositoryProvider)
      .variance(
        periodFrom: filter.periodFrom,
        periodTo: filter.periodTo,
        locationId: filter.locationId,
        productId: filter.productId,
      );
  return result.getOrThrow();
});

final portionComplianceProvider =
    FutureProvider<Page<PortionComplianceLineDto>>((ref) async {
      final filter = ref.watch(varianceFilterProvider);
      final result = await ref
          .watch(consumptionRepositoryProvider)
          .portionCompliance(
            periodFrom: filter.periodFrom,
            periodTo: filter.periodTo,
            locationId: filter.locationId,
          );
      return result.getOrThrow();
    });
