import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart' as api;

import '../../../domain/entities/order_response_comparison_entity.dart';
import '../../../domain/errors/stale_order_version_exception.dart';

abstract interface class OrderResponseComparisonRemoteDataSource {
  Future<api.OrderResponseComparisonResource> show({required String orderId});

  Future<api.OrderResponseComparisonResource> replaceSelections({
    required String orderId,
    required int expectedVersion,
    required List<OrderResponseSelectionInput> selections,
  });
}

final class OrderResponseComparisonRemoteDataSourceImpl
    implements OrderResponseComparisonRemoteDataSource {
  OrderResponseComparisonRemoteDataSourceImpl(this._apiClient);

  final GeneratedApiClient _apiClient;

  @override
  Future<api.OrderResponseComparisonResource> show({
    required String orderId,
  }) async {
    final order = orderId.trim();

    if (order.isEmpty) {
      throw ArgumentError.value(
        orderId,
        'orderId',
        'Order id cannot be empty.',
      );
    }

    final response = await _apiClient.orderResponseComparisons
        .orderResponseComparisonShow(order: order);

    final body = response.data;

    if (body == null) {
      throw StateError('Order response comparison does not contain data.');
    }

    return body.data;
  }

  @override
  Future<api.OrderResponseComparisonResource> replaceSelections({
    required String orderId,
    required int expectedVersion,
    required List<OrderResponseSelectionInput> selections,
  }) async {
    final order = orderId.trim();

    if (order.isEmpty) {
      throw ArgumentError.value(
        orderId,
        'orderId',
        'Order id cannot be empty.',
      );
    }

    if (expectedVersion <= 0) {
      throw ArgumentError.value(
        expectedVersion,
        'expectedVersion',
        'Expected version must be positive.',
      );
    }

    if (selections.isEmpty) {
      throw ArgumentError.value(
        selections,
        'selections',
        'At least one supplier response must be selected.',
      );
    }

    final request = api.SelectOrderSupplierResponsesRequest((builder) {
      builder
        ..expectedVersion = expectedVersion
        ..selections.replace(
          BuiltList<api.SelectOrderSupplierResponsesRequestSelectionsInner>(
            selections.map(
              (selection) =>
                  api.SelectOrderSupplierResponsesRequestSelectionsInner((
                    itemBuilder,
                  ) {
                    itemBuilder
                      ..orderRecipientItemResponseId =
                          selection.orderRecipientItemResponseId
                      ..selectedQuantity = selection.selectedQuantity;
                  }),
            ),
          ),
        );
    });

    try {
      final response = await _apiClient.orderResponseComparisons
          .orderResponseComparisonUpdate(
            order: order,
            selectOrderSupplierResponsesRequest: request,
          );

      final body = response.data;

      if (body == null) {
        throw StateError('Supplier selection response does not contain data.');
      }

      return body.data;
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        throw const StaleOrderVersionException();
      }

      rethrow;
    }
  }
}
