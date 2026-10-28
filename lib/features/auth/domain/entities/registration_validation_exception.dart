/// Represents validation errors returned by the registration API.
///
/// Domain and Presentation do not need to depend on Dio
/// or Laravel response models.
final class RegistrationValidationException implements Exception {
  RegistrationValidationException(Map<String, String> fieldErrors)
    : fieldErrors = Map<String, String>.unmodifiable(fieldErrors);

  /// Field name -> first validation error message.
  final Map<String, String> fieldErrors;

  /// Avoid including submitted values or passwords in logs.
  @override
  String toString() {
    return 'RegistrationValidationException(${fieldErrors.keys.join(', ')})';
  }
}
