import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/api_environment.dart';

void main() {
  group('ApiEnvironment.normalizeBaseUrl', () {
    test('trims whitespace and trailing slash for development URLs', () {
      expect(
        ApiEnvironment.normalizeBaseUrl(
          '  http://127.0.0.1:8000/api/v1/  ',
          isRelease: false,
        ),
        'http://127.0.0.1:8000/api/v1',
      );
    });

    test('rejects an empty API base URL', () {
      expect(
        () => ApiEnvironment.normalizeBaseUrl('   ', isRelease: false),
        throwsA(isA<StateError>()),
      );
    });

    test('release accepts the canonical production API URL', () {
      expect(
        ApiEnvironment.normalizeBaseUrl(
          'https://api.talbytk.com/api/v1',
          isRelease: true,
        ),
        'https://api.talbytk.com/api/v1',
      );
    });

    test('release rejects an insecure production URL', () {
      expect(
        () => ApiEnvironment.normalizeBaseUrl(
          'http://api.talbytk.com/api/v1',
          isRelease: true,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('release rejects the development API URL', () {
      expect(
        () => ApiEnvironment.normalizeBaseUrl(
          'https://dev-api.talbytk.com/api/v1',
          isRelease: true,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects malformed non HTTP API URLs', () {
      expect(
        () =>
            ApiEnvironment.normalizeBaseUrl('not-an-api-url', isRelease: false),
        throwsA(isA<StateError>()),
      );
    });
  });
}
