import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';

void main() {
  test('raw PATCH rejects queued account switch', () async {
    final api = GeneratedApiClient.create(baseUrl: 'http://localhost/api/v1');

    api.setAccessToken('fake-account-A-token');

    final adapter = _CountingAdapter();
    api.client.dio.httpClientAdapter = adapter;

    final entered = Completer<void>();
    final release = Completer<void>();

    api.client.dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!entered.isCompleted) entered.complete();
          release.future.then((_) => handler.next(options));
        },
      ),
    );

    final pending = api.patchJsonAuthenticated<Object?>(
      path: '/security-test',
      data: {'value': 1},
    );

    await entered.future.timeout(const Duration(seconds: 5));

    api.setAccessToken('fake-account-B-token');
    release.complete();

    try {
      await pending;
    } catch (_) {
      // A rejected stale request is acceptable.
    }

    expect(
      adapter.requestCount,
      0,
      reason: 'Account A PATCH must not dispatch under account B.',
    );
  });
}

final class _CountingAdapter implements HttpClientAdapter {
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;

    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
