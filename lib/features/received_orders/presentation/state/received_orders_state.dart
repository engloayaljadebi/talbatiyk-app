import '../../domain/entities/received_order_entity.dart';

final class ReceivedOrdersState {
  const ReceivedOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.submittingRecipientId,
    this.updatingFulfillmentRecipientId,
    this.errorMessage,
  });

  final List<ReceivedOrderEntity> orders;
  final bool isLoading;
  final String? submittingRecipientId;
  final String? updatingFulfillmentRecipientId;
  final String? errorMessage;

  bool get isSubmitting => submittingRecipientId != null;

  bool get isUpdatingFulfillment => updatingFulfillmentRecipientId != null;

  bool isSubmittingRecipient(String recipientId) {
    return submittingRecipientId == recipientId;
  }

  bool isUpdatingFulfillmentRecipient(String recipientId) {
    return updatingFulfillmentRecipientId == recipientId;
  }

  ReceivedOrdersState copyWith({
    List<ReceivedOrderEntity>? orders,
    bool? isLoading,
    String? submittingRecipientId,
    bool clearSubmittingRecipientId = false,
    String? updatingFulfillmentRecipientId,
    bool clearUpdatingFulfillmentRecipientId = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ReceivedOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      submittingRecipientId: clearSubmittingRecipientId
          ? null
          : submittingRecipientId ?? this.submittingRecipientId,
      updatingFulfillmentRecipientId: clearUpdatingFulfillmentRecipientId
          ? null
          : updatingFulfillmentRecipientId ??
                this.updatingFulfillmentRecipientId,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
