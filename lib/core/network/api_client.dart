/// Transport-agnostic API contract shared by remote feature data sources.
///
/// A Dio or package:http adapter can implement this interface when the backend
/// is connected. Feature layers only work with decoded response objects.
abstract interface class ApiClient {
  Future<Object?> get(
    String path, {
    Map<String, Object?>? queryParameters,
  });

  Future<Object?> post(
    String path, {
    Object? body,
    Map<String, Object?>? queryParameters,
  });
}
