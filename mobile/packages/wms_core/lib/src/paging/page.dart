import 'package:meta/meta.dart';

/// Paged API response: `{ items, page, size, total }` (spec §13.4).
@immutable
class Page<T> {
  const Page({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
  });

  const Page.empty({this.page = 1, this.size = defaultSize})
    : items = const [],
      total = 0;

  factory Page.fromJson(
    Map<String, Object?> json,
    T Function(Object? item) fromJsonT,
  ) {
    final rawItems = json['items'];
    return Page<T>(
      items: rawItems is List
          ? List<T>.unmodifiable(rawItems.map(fromJsonT))
          : const [],
      page: (json['page'] as num?)?.toInt() ?? 1,
      size: (json['size'] as num?)?.toInt() ?? defaultSize,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  static const int defaultSize = 50;

  /// Backend hard limit (spec §13.4).
  static const int maxSize = 200;

  final List<T> items;

  /// 1-based page index.
  final int page;
  final int size;
  final int total;

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get totalPages => size == 0 ? 0 : (total + size - 1) ~/ size;
  bool get hasNext => page < totalPages;
  bool get hasPrevious => page > 1;

  Page<R> map<R>(R Function(T item) transform) => Page<R>(
    items: List<R>.unmodifiable(items.map(transform)),
    page: page,
    size: size,
    total: total,
  );

  Map<String, Object?> toJson(Object? Function(T item) toJsonT) => {
    'items': items.map(toJsonT).toList(),
    'page': page,
    'size': size,
    'total': total,
  };

  @override
  String toString() =>
      'Page<$T>(page: $page, size: $size, total: $total, items: ${items.length})';
}

/// Query parameters for a paged request.
@immutable
class PageRequest {
  const PageRequest({this.page = 1, this.size = Page.defaultSize})
    : assert(page >= 1, 'page is 1-based'),
      assert(size >= 1 && size <= Page.maxSize, 'size must be 1..200');

  final int page;
  final int size;

  PageRequest next() => PageRequest(page: page + 1, size: size);

  Map<String, Object?> toQuery() => {'page': page, 'size': size};
}
