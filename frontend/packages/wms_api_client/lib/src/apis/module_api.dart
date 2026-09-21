import 'package:dio/dio.dart';
import 'package:wms_core/wms_core.dart';

/// JSON object as decoded by Dio.
typedef JsonMap = Map<String, Object?>;

/// Base class for per-module APIs. Centralises response decoding and the
/// conversion of [DioException] into [AppException] so that callers only
/// deal with one exception type (and `Result.guard` maps it to `Err`).
abstract class ModuleApi {
  ModuleApi(this.dio, this.prefix);

  final Dio dio;

  /// Route prefix, e.g. `/inventory` (CONVENTIONS.md, base URL already has
  /// `/api/v1`).
  final String prefix;

  String path(String relative) =>
      relative.startsWith('/') ? '$prefix$relative' : '$prefix/$relative';

  Future<T> getObject<T>(
    String relative, {
    required T Function(JsonMap json) fromJson,
    Map<String, Object?>? query,
    CancelToken? cancelToken,
  }) => _run(() async {
    final response = await dio.get<Object?>(
      path(relative),
      queryParameters: _clean(query),
      cancelToken: cancelToken,
    );
    return fromJson(asJsonMap(response.data));
  });

  Future<List<T>> getList<T>(
    String relative, {
    required T Function(JsonMap json) fromJson,
    Map<String, Object?>? query,
    CancelToken? cancelToken,
  }) => _run(() async {
    final response = await dio.get<Object?>(
      path(relative),
      queryParameters: _clean(query),
      cancelToken: cancelToken,
    );
    return asJsonList(response.data).map(fromJson).toList();
  });

  Future<Page<T>> getPage<T>(
    String relative, {
    required T Function(JsonMap json) fromJson,
    PageRequest page = const PageRequest(),
    Map<String, Object?>? query,
    CancelToken? cancelToken,
  }) => _run(() async {
    final response = await dio.get<Object?>(
      path(relative),
      queryParameters: _clean({...?query, ...page.toQuery()}),
      cancelToken: cancelToken,
    );
    return Page<T>.fromJson(
      asJsonMap(response.data),
      (item) => fromJson(asJsonMap(item)),
    );
  });

  Future<T> postObject<T>(
    String relative, {
    required T Function(JsonMap json) fromJson,
    Object? body,
    Map<String, Object?>? query,
    CancelToken? cancelToken,
  }) => _run(() async {
    final response = await dio.post<Object?>(
      path(relative),
      data: body,
      queryParameters: _clean(query),
      cancelToken: cancelToken,
    );
    return fromJson(asJsonMap(response.data));
  });

  /// `multipart/form-data` POST (CSV upload). [fields] are sent as plain
  /// form values; [files] as file parts.
  Future<T> postMultipart<T>(
    String relative, {
    required T Function(JsonMap json) fromJson,
    required Map<String, Object?> fields,
    required Map<String, MultipartFile> files,
    CancelToken? cancelToken,
  }) => _run(() async {
    final form = FormData();
    _clean(fields)?.forEach((key, value) {
      form.fields.add(MapEntry(key, '$value'));
    });
    files.forEach((key, file) {
      form.files.add(MapEntry(key, file));
    });
    final response = await dio.post<Object?>(
      path(relative),
      data: form,
      cancelToken: cancelToken,
    );
    return fromJson(asJsonMap(response.data));
  });

  Future<void> postVoid(
    String relative, {
    Object? body,
    Map<String, Object?>? query,
    CancelToken? cancelToken,
  }) => _run(() async {
    await dio.post<Object?>(
      path(relative),
      data: body,
      queryParameters: _clean(query),
      cancelToken: cancelToken,
    );
  });

  Future<T> putObject<T>(
    String relative, {
    required T Function(JsonMap json) fromJson,
    Object? body,
    CancelToken? cancelToken,
  }) => _run(() async {
    final response = await dio.put<Object?>(
      path(relative),
      data: body,
      cancelToken: cancelToken,
    );
    return fromJson(asJsonMap(response.data));
  });

  Future<void> deleteVoid(String relative, {CancelToken? cancelToken}) =>
      _run(() async {
        await dio.delete<Object?>(path(relative), cancelToken: cancelToken);
      });

  /// Runs [body], rethrowing transport errors as [AppException].
  static Future<T> _run<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e, st) {
      final error = e.error;
      if (error is AppException) throw error;
      throw AppException.from(e, st);
    } on AppException {
      rethrow;
    } on FormatException catch (e, st) {
      throw AppException(
        UnexpectedFailure(
          message: 'Malformed response: ${e.message}',
          error: e,
          stackTrace: st,
        ),
      );
    }
  }

  static JsonMap asJsonMap(Object? data) {
    if (data is Map) return data.map((k, v) => MapEntry(k.toString(), v));
    throw FormatException('Expected JSON object, got ${data.runtimeType}');
  }

  static List<JsonMap> asJsonList(Object? data) {
    if (data is List) return data.map(asJsonMap).toList();
    if (data is Map && data['items'] is List) {
      return asJsonList(data['items']);
    }
    throw FormatException('Expected JSON array, got ${data.runtimeType}');
  }

  /// Drops `null` query parameters and stringifies enums/dates.
  static Map<String, Object?>? _clean(Map<String, Object?>? query) {
    if (query == null) return null;
    final out = <String, Object?>{};
    query.forEach((key, value) {
      if (value == null) return;
      out[key] = switch (value) {
        Enum(:final name) => _wireOf(value) ?? name,
        DateTime() => value.toIso8601String().substring(0, 10),
        _ => value,
      };
    });
    return out.isEmpty ? null : out;
  }

  static String? _wireOf(Enum value) => switch (value) {
    AttachmentEntityType(:final wire) => wire,
    AttachmentType(:final wire) => wire,
    AttachmentStatus(:final wire) => wire,
    DocType(:final wire) => wire,
    BatchStatus(:final wire) => wire,
    PoStatus(:final wire) => wire,
    CountStatus(:final wire) => wire,
    LocationType(:final wire) => wire,
    ProductType(:final wire) => wire,
    ReasonGroup(:final wire) => wire,
    ReceiptStatus(:final wire) => wire,
    StockRequestStatus(:final wire) => wire,
    IssueStatus(:final wire) => wire,
    IssueType(:final wire) => wire,
    WasteStatus(:final wire) => wire,
    RequisitionStatus(:final wire) => wire,
    RfqStatus(:final wire) => wire,
    RecipeStatus(:final wire) => wire,
    ComponentType(:final wire) => wire,
    SalesSource(:final wire) => wire,
    SalesImportStatus(:final wire) => wire,
    ConsumptionRunStatus(:final wire) => wire,
    _ => null,
  };
}
