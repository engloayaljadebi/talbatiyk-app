import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/business/data/datasources/remote/business_remote_datasource.dart';

void main() {
  test('queued business index rejects account switch', () async {
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

    final pending = BusinessRemoteDataSourceImpl(api).index();

    await entered.future.timeout(const Duration(seconds: 5));

    api.setAccessToken('fake-account-B-token');
    release.complete();

    try {
      await pending;
    } catch (_) {
      // Cancellation is acceptable.
    }

    expect(
      adapter.requestCount,
      0,
      reason: 'Old account business request reached the network.',
    );
  });

  test('business index rejects stale HTTP response', () async {
    final api = GeneratedApiClient.create(baseUrl: 'http://localhost/api/v1');
    api.setAccessToken('fake-account-A-token');

    final adapter = _CountingAdapter();
    adapter.onFetch = () {
      api.setAccessToken('fake-account-B-token');
    };

    api.client.dio.httpClientAdapter = adapter;

    await expectLater(
      BusinessRemoteDataSourceImpl(api).index(),
      throwsA(isA<StateError>()),
    );

    expect(adapter.requestCount, 1);
  });
}

final class _CountingAdapter implements HttpClientAdapter {
  int requestCount = 0;
  void Function()? onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    onFetch?.call();

    return ResponseBody.fromString(
      '{"data":[]}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
