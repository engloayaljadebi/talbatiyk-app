import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/order_response_comparison/domain/entities/order_response_comparison_entity.dart';
import 'package:talbatiyk/features/order_response_comparison/domain/repositories/order_response_comparison_repository.dart';
import 'package:talbatiyk/features/order_response_comparison/presentation/pages/order_response_comparison_page.dart';
import 'package:talbatiyk/features/order_response_comparison/presentation/providers/order_response_comparison_provider.dart';

void main() {
  testWidgets('shows supplier response and saves selected quantity', (
    tester,
  ) async {
    final repository = _FakeRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderResponseComparisonRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
        child: const MaterialApp(
          home: OrderResponseComparisonPage(orderId: 'order-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Product One'), findsOneWidget);
    expect(find.text('Supplier One'), findsOneWidget);
    expect(find.text('12.50 ر.س'), findsOneWidget);
    expect(find.text('11.25 ر.س'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('selection-increment-response-item-1')),
    );

    await tester.pump();

    await tester.tap(find.byKey(const Key('save-supplier-selections')));

    await tester.pumpAndSettle();

    expect(repository.replaceCalls, 1);
    expect(repository.lastExpectedVersion, 1);
    expect(repository.lastSelections, hasLength(1));

    expect(repository.lastSelections.single.selectedQuantity, 1);
  });
}

final class _FakeRepository implements OrderResponseComparisonRepository {
  int replaceCalls = 0;
  int? lastExpectedVersion;

  List<OrderResponseSelectionInput> lastSelections = const [];

  @override
  Future<OrderResponseComparisonEntity> getComparison({
    required String orderId,
  }) async {
    return _comparison(version: 1);
  }

  @override
  Future<OrderResponseComparisonEntity> replaceSelections({
    required String orderId,
    required int expectedVersion,
    required List<OrderResponseSelectionInput> selections,
  }) async {
    replaceCalls += 1;
    lastExpectedVersion = expectedVersion;

    lastSelections = List<OrderResponseSelectionInput>.unmodifiable(selections);

    return _comparison(
      version: expectedVersion + 1,
      selectedQuantity: selections.single.selectedQuantity,
    );
  }
}

OrderResponseComparisonEntity _comparison({
  required int version,
  int? selectedQuantity,
}) {
  return OrderResponseComparisonEntity(
    id: 'order-1',
    version: version,
    status: 'pending',
    notes: null,
    createdAt: null,
    updatedAt: null,
    items: [
      OrderResponseComparisonItemEntity(
        id: 'order-item-1',
        productId: 'product-1',
        productName: 'Product One',
        requestedQuantity: 3,
        orderUnitPrice: '12.50',
        supplier: const OrderResponseSupplierEntity(
          recipientId: 'recipient-1',
          supplierId: 'supplier-1',
          supplierName: 'Supplier One',
        ),
        response: const OrderResponseItemResponseEntity(
          id: 'response-item-1',
          orderRecipientItemId: 'recipient-item-1',
          requestedQuantity: 3,
          availableQuantity: 2,
          availability: OrderResponseAvailability.partial,
          offeredUnitPrice: '11.25',
          responseNotes: null,
          createdAt: null,
          updatedAt: null,
        ),
        selection: selectedQuantity == null
            ? null
            : OrderResponseSelectionEntity(
                id: 'selection-1',
                orderRecipientItemResponseId: 'response-item-1',
                selectedQuantity: selectedQuantity,
              ),
      ),
    ],
  );
}
