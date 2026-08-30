import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/order_response_comparison/domain/entities/order_response_comparison_entity.dart';
import 'package:talbatiyk/features/order_response_comparison/domain/errors/stale_order_version_exception.dart';
import 'package:talbatiyk/features/order_response_comparison/domain/repositories/order_response_comparison_repository.dart';
import 'package:talbatiyk/features/order_response_comparison/domain/usecases/order_response_comparison_usecase.dart';
import 'package:talbatiyk/features/order_response_comparison/presentation/controllers/order_response_comparison_controller.dart';

void main() {
  group('OrderResponseComparisonController', () {
    late _FakeOrderResponseComparisonRepository repository;
    late OrderResponseComparisonController controller;

    setUp(() {
      repository = _FakeOrderResponseComparisonRepository();

      controller = OrderResponseComparisonController(
        'order-1',
        OrderResponseComparisonUseCase(repository),
        autoLoad: false,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('loads supplier response comparison', () async {
      repository.comparison = _comparison(version: 1);

      await controller.loadComparison();

      expect(controller.state.comparison, isNotNull);
      expect(controller.state.comparison!.version, 1);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, isNull);
      expect(repository.getCalls, 1);
    });

    test(
      'successful selection uses current version and stores server result',
      () async {
        repository.comparison = _comparison(version: 1);

        await controller.loadComparison();

        final succeeded = await controller.submitSelections(const [
          OrderResponseSelectionInput(
            orderRecipientItemResponseId: 'response-item-1',
            selectedQuantity: 1,
          ),
        ]);

        expect(succeeded, isTrue);
        expect(repository.replaceCalls, 1);
        expect(repository.lastExpectedVersion, 1);

        expect(
          repository.lastSelections.single.orderRecipientItemResponseId,
          'response-item-1',
        );

        expect(controller.state.comparison!.version, 2);

        expect(
          controller.state.comparison!.items.single.selection!.selectedQuantity,
          1,
        );

        expect(controller.state.isSubmitting, isFalse);
        expect(controller.state.errorMessage, isNull);
      },
    );

    test(
      'rejects quantity above supplier availability before repository call',
      () async {
        repository.comparison = _comparison(version: 1, availableQuantity: 2);

        await controller.loadComparison();

        final succeeded = await controller.submitSelections(const [
          OrderResponseSelectionInput(
            orderRecipientItemResponseId: 'response-item-1',
            selectedQuantity: 3,
          ),
        ]);

        expect(succeeded, isFalse);
        expect(repository.replaceCalls, 0);
        expect(controller.state.errorMessage, isNotNull);
      },
    );

    test(
      'stale version refreshes comparison without blindly retrying update',
      () async {
        repository.comparison = _comparison(version: 1);

        await controller.loadComparison();

        repository.staleNextReplace = true;

        final succeeded = await controller.submitSelections(const [
          OrderResponseSelectionInput(
            orderRecipientItemResponseId: 'response-item-1',
            selectedQuantity: 1,
          ),
        ]);

        expect(succeeded, isFalse);

        /*
         * One replace attempt only. The conflict is never retried with the
         * stale expectedVersion.
         */
        expect(repository.replaceCalls, 1);

        /*
         * Initial load + conflict refresh.
         */
        expect(repository.getCalls, 2);

        expect(controller.state.comparison, isNotNull);
        expect(controller.state.comparison!.version, 2);
        expect(controller.state.isSubmitting, isFalse);
        expect(controller.state.errorMessage, isNotNull);
      },
    );
  });
}

OrderResponseComparisonEntity _comparison({
  required int version,
  int availableQuantity = 2,
  OrderResponseAvailability availability = OrderResponseAvailability.partial,
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
        response: OrderResponseItemResponseEntity(
          id: 'response-item-1',
          orderRecipientItemId: 'recipient-item-1',
          requestedQuantity: 3,
          availableQuantity: availableQuantity,
          availability: availability,
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

final class _FakeOrderResponseComparisonRepository
    implements OrderResponseComparisonRepository {
  OrderResponseComparisonEntity comparison = _comparison(version: 1);

  int getCalls = 0;
  int replaceCalls = 0;

  bool staleNextReplace = false;

  int? lastExpectedVersion;

  List<OrderResponseSelectionInput> lastSelections = const [];

  @override
  Future<OrderResponseComparisonEntity> getComparison({
    required String orderId,
  }) async {
    getCalls += 1;

    return comparison;
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

    if (staleNextReplace) {
      staleNextReplace = false;

      /*
       * Simulate another writer committing version + 1 before this request.
       */
      comparison = _comparison(version: expectedVersion + 1);

      throw const StaleOrderVersionException();
    }

    comparison = _comparison(
      version: expectedVersion + 1,
      selectedQuantity: selections.single.selectedQuantity,
    );

    return comparison;
  }
}
