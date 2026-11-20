import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';

void main() {
  for (final replaceSession in [false, true]) {
    test(
      replaceSession
          ? 'late HTTP 401 preserves the new session'
          : 'HTTP 401 invalidates the current session',
      () async {
        final api = GeneratedApiClient.create(
          baseUrl: 'http://localhost/api/v1',
        );
        addTearDown(() => api.client.dio.close(force: true));

        final adapter = _UnauthorizedAdapter();
        api.client.dio.httpClientAdapter = adapter;
        api.setAccessToken('fake-original-token');
        final originalAuth = api.captureProtectedRequestAuthExtra();

        final response = expectLater(
          api.getJsonAuthenticated(path: '/protected-test'),
          throwsA(
            isA<DioException>().having(
              (error) => error.response?.statusCode,
              'status code',
              401,
            ),
          ),
        );

        await adapter.dispatched.future.timeout(const Duration(seconds: 5));
        if (replaceSession) {
          api.setAccessToken('fake-new-token');
        }
        final activeAuth = api.captureProtectedRequestAuthExtra();
        adapter.respond.complete();
        await response;

        expect(
          () => api.ensureProtectedRequestAuthCurrent(originalAuth),
          throwsStateError,
        );
        if (replaceSession) {
          api.ensureProtectedRequestAuthCurrent(activeAuth);
        } else {
          expect(api.captureProtectedRequestAuthExtra, throwsStateError);
        }
      },
    );
  }
}

final class _UnauthorizedAdapter implements HttpClientAdapter {
  final dispatched = Completer<void>();
  final respond = Completer<void>();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    dispatched.complete();
    await respond.future;
    return ResponseBody.fromString(
      '{"message":"Unauthenticated."}',
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
