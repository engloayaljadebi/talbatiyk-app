import '../../domain/entities/business_entity.dart';

enum BusinessLoadStatus { initial, loading, loaded, failure }

final class BusinessState {
  const BusinessState._({
    required this.status,
    required this.businesses,
    this.errorMessage,
  });

  const BusinessState.initial()
    : this._(status: BusinessLoadStatus.initial, businesses: const []);

  const BusinessState.loading()
    : this._(status: BusinessLoadStatus.loading, businesses: const []);

  BusinessState.loaded(List<BusinessEntity> businesses)
    : this._(
        status: BusinessLoadStatus.loaded,
        businesses: List<BusinessEntity>.unmodifiable(businesses),
      );

  const BusinessState.failure(String message)
    : this._(
        status: BusinessLoadStatus.failure,
        businesses: const [],
        errorMessage: message,
      );

  final BusinessLoadStatus status;
  final List<BusinessEntity> businesses;
  final String? errorMessage;

  bool get isLoading => status == BusinessLoadStatus.loading;

  bool get hasBusinesses =>
      status == BusinessLoadStatus.loaded && businesses.isNotEmpty;

  bool get hasFailure => status == BusinessLoadStatus.failure;
}
