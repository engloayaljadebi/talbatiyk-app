import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/received_orders/domain/entities/received_order_entity.dart';
import 'package:talbatiyk/features/received_orders/domain/errors/stale_recipient_fulfillment_version_exception.dart';
import 'package:talbatiyk/features/received_orders/domain/repositories/received_orders_repository.dart';
import 'package:talbatiyk/features/received_orders/domain/usecases/received_orders_usecase.dart';
import 'package:talbatiyk/features/received_orders/presentation/controllers/received_orders_controller.dart';

void main() {
  group('ReceivedOrdersController', () {
    late _FakeReceivedOrdersRepository repository;
    late ReceivedOrdersController controller;

    setUp(() {
      repository = _FakeReceivedOrdersRepository();

      controller = ReceivedOrdersController(
        'business-1',
        ReceivedOrdersUseCase(repository),
        autoLoad: false,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('loads received orders', () async {
      repository.orders = [_order()];

      await controller.loadReceivedOrders();

      expect(controller.state.orders, hasLength(1));
      expect(controller.state.errorMessage, isNull);
      expect(controller.state.isLoading, isFalse);
    });

    test(
      'reuses idempotency key when retrying same logical response',
      () async {
        repository.orders = [_order()];

        await controller.loadReceivedOrders();

        repository.failNextSubmit = true;

        const responses = [
          SubmitReceivedOrderItemResponse(
            orderRecipientItemId: 'item-1',
            availability: ReceivedOrderAvailability.full,
            availableQuantity: 3,
          ),
        ];

        final first = await controller.submitResponse(
          order: controller.state.orders.single,
          items: responses,
        );

        expect(first, isFalse);

        final second = await controller.submitResponse(
          order: controller.state.orders.single,
          items: responses,
        );

        expect(second, isTrue);

        expect(repository.idempotencyKeys, hasLength(2));

        expect(repository.idempotencyKeys[0], repository.idempotencyKeys[1]);

        expect(controller.state.orders.single.hasResponse, isTrue);

        expect(controller.state.isSubmitting, isFalse);
      },
    );

    test(
      'rejects response that does not contain every recipient item',
      () async {
        repository.orders = [_orderWithTwoItems()];

        await controller.loadReceivedOrders();

        final succeeded = await controller.submitResponse(
          order: controller.state.orders.single,
          items: const [
            SubmitReceivedOrderItemResponse(
              orderRecipientItemId: 'item-1',
              availability: ReceivedOrderAvailability.full,
              availableQuantity: 3,
            ),
          ],
        );

        expect(succeeded, isFalse);
        expect(repository.submitCalls, 0);

        expect(controller.state.errorMessage, isNotNull);
      },
    );
    test(
      'updateFulfillment sends next transition with current version and replaces recipient',
      () async {
        repository.orders = [
          _fulfillmentOrder(
            status: ReceivedOrderFulfillmentStatus.confirmed,
            version: 4,
          ),
        ];

        await controller.loadReceivedOrders();

        final succeeded = await controller.updateFulfillment(
          order: controller.state.orders.single,
        );

        expect(succeeded, isTrue);
        expect(repository.fulfillmentCalls, 1);
        expect(repository.lastFulfillmentBusinessId, 'business-1');
        expect(repository.lastFulfillmentRecipientId, 'recipient-1');
        expect(repository.lastFulfillmentExpectedVersion, 4);
        expect(
          repository.lastFulfillmentStatus,
          ReceivedOrderFulfillmentStatus.preparing,
        );

        final updated = controller.state.orders.single;

        expect(
          updated.fulfillmentStatus,
          ReceivedOrderFulfillmentStatus.preparing,
        );
        expect(updated.fulfillmentVersion, 5);
        expect(controller.state.isUpdatingFulfillment, isFalse);
        expect(controller.state.errorMessage, isNull);
      },
    );

    test(
      'stale fulfillment reloads fresh orders without blind retry',
      () async {
        repository.orders = [
          _fulfillmentOrder(
            status: ReceivedOrderFulfillmentStatus.confirmed,
            version: 4,
          ),
        ];

        await controller.loadReceivedOrders();

        final staleOrder = controller.state.orders.single;

        repository.orders = [
          _fulfillmentOrder(
            status: ReceivedOrderFulfillmentStatus.preparing,
            version: 5,
          ),
        ];
        repository.failNextFulfillmentWithStale = true;

        final succeeded = await controller.updateFulfillment(order: staleOrder);

        expect(succeeded, isFalse);

        expect(repository.fulfillmentCalls, 1);
        expect(repository.getCalls, 2);

        final fresh = controller.state.orders.single;

        expect(
          fresh.fulfillmentStatus,
          ReceivedOrderFulfillmentStatus.preparing,
        );
        expect(fresh.fulfillmentVersion, 5);
        expect(controller.state.isUpdatingFulfillment, isFalse);
        expect(controller.state.errorMessage, isNotNull);
      },
    );

    test('updateFulfillment rejects order without selection', () async {
      repository.orders = [
        _fulfillmentOrder(
          status: ReceivedOrderFulfillmentStatus.confirmed,
          selectedQuantity: null,
        ),
      ];

      await controller.loadReceivedOrders();

      final succeeded = await controller.updateFulfillment(
        order: controller.state.orders.single,
      );

      expect(succeeded, isFalse);
      expect(repository.fulfillmentCalls, 0);
      expect(controller.state.errorMessage, isNotNull);
    });

    test('updateFulfillment rejects terminal delivered order', () async {
      repository.orders = [
        _fulfillmentOrder(
          status: ReceivedOrderFulfillmentStatus.delivered,
          version: 8,
        ),
      ];

      await controller.loadReceivedOrders();

      final succeeded = await controller.updateFulfillment(
        order: controller.state.orders.single,
      );

      expect(succeeded, isFalse);
      expect(repository.fulfillmentCalls, 0);
      expect(controller.state.errorMessage, isNotNull);
    });
  });
}

ReceivedOrderEntity _order() {
  return ReceivedOrderEntity(
    id: 'recipient-1',
    orderId: 'order-1',
    supplierId: 'business-1',
    supplierName: 'Supplier One',
    orderStatus: 'pending',
    items: const [
      ReceivedOrderItemEntity(
        id: 'item-1',
        productId: 'product-1',
        productName: 'Product One',
        unitPrice: '10.00',
        requestedQuantity: 3,
      ),
    ],
  );
}

ReceivedOrderEntity _orderWithTwoItems() {
  return ReceivedOrderEntity(
    id: 'recipient-1',
    orderId: 'order-1',
    supplierId: 'business-1',
    supplierName: 'Supplier One',
    orderStatus: 'pending',
    items: const [
      ReceivedOrderItemEntity(
        id: 'item-1',
        productId: 'product-1',
        productName: 'Product One',
        unitPrice: '10.00',
        requestedQuantity: 3,
      ),
      ReceivedOrderItemEntity(
        id: 'item-2',
        productId: 'product-2',
        productName: 'Product Two',
        unitPrice: '20.00',
        requestedQuantity: 2,
      ),
    ],
  );
}

ReceivedOrderEntity _fulfillmentOrder({
  required ReceivedOrderFulfillmentStatus status,
  int version = 1,
  int? selectedQuantity = 2,
}) {
  return ReceivedOrderEntity(
    id: 'recipient-1',
    orderId: 'order-1',
    supplierId: 'business-1',
    supplierName: 'Supplier One',
    orderStatus: 'pending',
    fulfillmentStatus: status,
    fulfillmentVersion: version,
    items: [
      ReceivedOrderItemEntity(
        id: 'item-1',
        productId: 'product-1',
        productName: 'Product One',
        unitPrice: '10.00',
        requestedQuantity: 3,
        selectedQuantity: selectedQuantity,
      ),
    ],
  );
}

final class _FakeReceivedOrdersRepository implements ReceivedOrdersRepository {
  List<ReceivedOrderEntity> orders = [];

  bool failNextSubmit = false;
  bool failNextFulfillmentWithStale = false;

  int submitCalls = 0;
  int fulfillmentCalls = 0;
  int getCalls = 0;

  String? lastFulfillmentBusinessId;
  String? lastFulfillmentRecipientId;
  int? lastFulfillmentExpectedVersion;
  ReceivedOrderFulfillmentStatus? lastFulfillmentStatus;

  final List<String> idempotencyKeys = [];

  @override
  Future<List<ReceivedOrderEntity>> getReceivedOrders({
    required String businessId,
  }) async {
    getCalls += 1;
    return orders;
  }

  @override
  Future<ReceivedOrderEntity> updateFulfillment({
    required String businessId,
    required String recipientId,
    required int expectedVersion,
    required ReceivedOrderFulfillmentStatus status,
  }) async {
    fulfillmentCalls += 1;
    lastFulfillmentBusinessId = businessId;
    lastFulfillmentRecipientId = recipientId;
    lastFulfillmentExpectedVersion = expectedVersion;
    lastFulfillmentStatus = status;

    if (failNextFulfillmentWithStale) {
      failNextFulfillmentWithStale = false;
      throw const StaleRecipientFulfillmentVersionException();
    }

    final current = orders.firstWhere((order) => order.id == recipientId);

    final updated = ReceivedOrderEntity(
      id: current.id,
      orderId: current.orderId,
      supplierId: current.supplierId,
      supplierName: current.supplierName,
      orderStatus: current.orderStatus,
      fulfillmentStatus: status,
      fulfillmentVersion: expectedVersion + 1,
      notes: current.notes,
      items: current.items,
      response: current.response,
      createdAt: current.createdAt,
      updatedAt: current.updatedAt,
    );

    orders = [
      for (final order in orders)
        if (order.id == recipientId) updated else order,
    ];

    return updated;
  }

  @override
  Future<ReceivedOrderResponseEntity> submitResponse({
    required String businessId,
    required String recipientId,
    required String idempotencyKey,
    required List<SubmitReceivedOrderItemResponse> items,
  }) async {
    submitCalls += 1;
    idempotencyKeys.add(idempotencyKey);

    if (failNextSubmit) {
      failNextSubmit = false;
      throw StateError('simulated network failure');
    }

    return ReceivedOrderResponseEntity(
      id: 'response-1',
      orderRecipientId: recipientId,
      items: [
        for (final item in items)
          ReceivedOrderItemResponseEntity(
            id: 'response-${item.orderRecipientItemId}',
            orderRecipientItemId: item.orderRecipientItemId,
            requestedQuantity: 3,
            availableQuantity: item.availableQuantity,
            availability: item.availability,
          ),
      ],
    );
  }
}
