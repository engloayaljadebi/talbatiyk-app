import '../../domain/entities/received_order_entity.dart';

final class ReceivedOrdersState {
  const ReceivedOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.submittingRecipientId,
    this.errorMessage,
  });

  final List<ReceivedOrderEntity> orders;
  final bool isLoading;
  final String? submittingRecipientId;
  final String? errorMessage;

  bool get isSubmitting => submittingRecipientId != null;

  bool isSubmittingRecipient(String recipientId) {
    return submittingRecipientId == recipientId;
  }

  ReceivedOrdersState copyWith({
    List<ReceivedOrderEntity>? orders,
    bool? isLoading,
    String? submittingRecipientId,
    bool clearSubmittingRecipientId = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ReceivedOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      submittingRecipientId: clearSubmittingRecipientId
          ? null
          : submittingRecipientId ?? this.submittingRecipientId,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
