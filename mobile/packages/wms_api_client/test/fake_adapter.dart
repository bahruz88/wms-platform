import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Records requests and replays canned responses; no sockets involved.
class FakeAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  /// Header snapshots taken at fetch time (retries mutate the same
  /// [RequestOptions] instance, so [requests] alone cannot show the token
  /// used for each attempt).
  final List<Map<String, Object?>> headerSnapshots = [];

  /// Bodies actually put on the wire, in request order (empty for GET).
  final List<Uint8List> sentBodies = [];
  final List<ResponseBody Function(RequestOptions options)> _queue = [];

  void enqueueJson(
    Object? body, {
    int status = 200,
    String contentType = 'application/json',
  }) {
    _queue.add(
      (_) => ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [contentType],
        },
      ),
    );
  }

  void enqueueTimeout() {
    _queue.add(
      (options) => throw DioException.connectionTimeout(
        timeout: const Duration(seconds: 1),
        requestOptions: options,
      ),
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    headerSnapshots.add(Map<String, Object?>.from(options.headers));
    // Dio reports upload progress while the adapter drains the stream, so a
    // fake that ignores it would never exercise `onSendProgress`.
    sentBodies.add(await _drain(requestStream));
    if (_queue.isEmpty) {
      return ResponseBody.fromString(
        '{}',
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }
    return _queue.removeAt(0)(options);
  }

  @override
  void close({bool force = false}) {}

  static Future<Uint8List> _drain(Stream<Uint8List>? stream) async {
    if (stream == null) return Uint8List(0);
    final chunks = <int>[];
    await for (final chunk in stream) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }
}
