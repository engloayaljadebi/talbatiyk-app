import '../../domain/entities/business_entity.dart';

final class BusinessProfileState {
  const BusinessProfileState({
    required this.business,
    this.isSaving = false,
    this.errorMessage,
  });

  final BusinessEntity business;
  final bool isSaving;
  final String? errorMessage;

  BusinessProfileState copyWith({
    BusinessEntity? business,
    bool? isSaving,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return BusinessProfileState(
      business: business ?? this.business,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
