import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/supplier_follow/data/datasources/supplier_follow_remote_datasource.dart';

const businessId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';

void main() {
  for (final operation in ['isFollowing', 'follow', 'unfollow']) {
    test('queued $operation rejects account switch', () async {
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
            if (!entered.isCompleted) {
              entered.complete();
            }

            release.future.then((_) => handler.next(options));
          },
        ),
      );

      final source = SupplierFollowRemoteDataSourceImpl(api);
      final pending = _invoke(operation, source);

      await entered.future.timeout(const Duration(seconds: 5));

      api.setAccessToken('fake-account-B-token');
      release.complete();

      try {
        await pending;
      } catch (_) {
        // Rejecting an obsolete request is acceptable.
      }

      expect(
        adapter.requestCount,
        0,
        reason: 'Old account $operation reached the network.',
      );
    });

    test('$operation rejects stale HTTP response', () async {
      final api = GeneratedApiClient.create(baseUrl: 'http://localhost/api/v1');

      api.setAccessToken('fake-account-A-token');

      final adapter = _CountingAdapter();

      adapter.onFetch = () {
        api.setAccessToken('fake-account-B-token');
      };

      api.client.dio.httpClientAdapter = adapter;

      final source = SupplierFollowRemoteDataSourceImpl(api);

      await expectLater(_invoke(operation, source), throwsA(isA<StateError>()));

      expect(adapter.requestCount, 1);
    });
  }
}

Future<bool> _invoke(
  String operation,
  SupplierFollowRemoteDataSourceImpl source,
) {
  switch (operation) {
    case 'isFollowing':
      return source.isFollowing(businessId);

    case 'follow':
      return source.follow(businessId);

    case 'unfollow':
      return source.unfollow(businessId);

    default:
      throw ArgumentError.value(operation);
  }
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

    final following = options.method == 'POST';

    return ResponseBody.fromString(
      '{"data":{"business_id":"$businessId",'
      '"is_following":$following}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
