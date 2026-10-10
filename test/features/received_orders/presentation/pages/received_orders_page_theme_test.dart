import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/theme/app_theme.dart';
import 'package:talbatiyk/features/received_orders/domain/entities/received_order_entity.dart';
import 'package:talbatiyk/features/received_orders/domain/repositories/received_orders_repository.dart';
import 'package:talbatiyk/features/received_orders/domain/usecases/received_orders_usecase.dart';
import 'package:talbatiyk/features/received_orders/presentation/controllers/received_orders_controller.dart';
import 'package:talbatiyk/features/received_orders/presentation/pages/received_orders_page.dart';
import 'package:talbatiyk/features/received_orders/presentation/providers/received_orders_provider.dart';

final class _MockReceivedOrdersRepository implements ReceivedOrdersRepository {
  List<ReceivedOrderEntity> orders = [];

  @override
  Future<List<ReceivedOrderEntity>> getReceivedOrders({
    required String businessId,
  }) async {
    return orders;
  }

  @override
  Future<ReceivedOrderEntity> updateFulfillment({
    required String businessId,
    required String recipientId,
    required int expectedVersion,
    required ReceivedOrderFulfillmentStatus status,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ReceivedOrderResponseEntity> submitResponse({
    required String businessId,
    required String recipientId,
    required String idempotencyKey,
    required List<SubmitReceivedOrderItemResponse> items,
  }) async {
    throw UnimplementedError();
  }
}

ReceivedOrderEntity _createSampleOrder({
  ReceivedOrderFulfillmentStatus? status = ReceivedOrderFulfillmentStatus.confirmed,
}) {
  return ReceivedOrderEntity(
    id: 'recipient-1',
    orderId: 'order-12345678',
    supplierId: 'business-1',
    supplierName: 'مورد تجريبي',
    orderStatus: 'pending',
    fulfillmentStatus: status,
    fulfillmentVersion: 1,
    notes: 'ملاحظات الطلب التجريبي',
    createdAt: DateTime(2026, 10, 9, 10, 30),
    items: const [
      ReceivedOrderItemEntity(
        id: 'item-1',
        productId: 'prod-1',
        productName: 'منتج تجريبي أول',
        unitPrice: '25.50',
        requestedQuantity: 3,
        selectedQuantity: 2,
      ),
    ],
  );
}

void main() {
  group('ReceivedOrdersPage Theme Integration', () {
    late _MockReceivedOrdersRepository repository;

    setUp(() {
      repository = _MockReceivedOrdersRepository();
    });

    testWidgets('renders in Light Mode with theme colors', (tester) async {
      repository.orders = [_createSampleOrder()];

      final controller = ReceivedOrdersController(
        'business-1',
        ReceivedOrdersUseCase(repository),
        autoLoad: false,
      );
      await controller.loadReceivedOrders();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            receivedOrdersControllerProvider('business-1').overrideWith(
              (ref) => controller,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ReceivedOrdersPage(businessId: 'business-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final theme = AppTheme.light;
      expect(scaffold.backgroundColor, equals(theme.colorScheme.surfaceContainerLowest));

      final cardBoxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      final cardBox = cardBoxes.firstWhere(
        (box) => (box.decoration as BoxDecoration).color == theme.colorScheme.surface,
      );
      expect((cardBox.decoration as BoxDecoration).color, equals(theme.colorScheme.surface));

      expect(find.text('الطلبات'), findsOneWidget);
      expect(find.text('الطلبات المستلمة'), findsOneWidget);
    });

    testWidgets('renders in Dark Mode with dark theme colors', (tester) async {
      repository.orders = [_createSampleOrder()];

      final darkTheme = ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          brightness: Brightness.dark,
        ),
      );

      final controller = ReceivedOrdersController(
        'business-1',
        ReceivedOrdersUseCase(repository),
        autoLoad: false,
      );
      await controller.loadReceivedOrders();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            receivedOrdersControllerProvider('business-1').overrideWith(
              (ref) => controller,
            ),
          ],
          child: MaterialApp(
            theme: darkTheme,
            home: const ReceivedOrdersPage(businessId: 'business-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(darkTheme.colorScheme.surfaceContainerLowest));

      final cardBoxes = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
      final cardBox = cardBoxes.firstWhere(
        (box) => (box.decoration as BoxDecoration).color == darkTheme.colorScheme.surface,
      );
      expect((cardBox.decoration as BoxDecoration).color, equals(darkTheme.colorScheme.surface));

      expect(find.text('الطلبات'), findsOneWidget);
      expect(find.text('الطلبات المستلمة'), findsOneWidget);
    });

    testWidgets('renders embedded mode matching parent background', (tester) async {
      repository.orders = [_createSampleOrder()];

      final controller = ReceivedOrdersController(
        'business-1',
        ReceivedOrdersUseCase(repository),
        autoLoad: false,
      );
      await controller.loadReceivedOrders();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            receivedOrdersControllerProvider('business-1').overrideWith(
              (ref) => controller,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: ReceivedOrdersPage(
                businessId: 'business-1',
                embedded: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final coloredBoxes = tester.widgetList<ColoredBox>(find.byType(ColoredBox));
      final embeddedCanvas = coloredBoxes.firstWhere(
        (box) => box.color == AppTheme.light.colorScheme.surfaceContainerLowest,
      );
      expect(embeddedCanvas.color, equals(AppTheme.light.colorScheme.surfaceContainerLowest));
    });

    testWidgets('renders empty state in Light and Dark Mode', (tester) async {
      final darkTheme = ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          brightness: Brightness.dark,
        ),
      );

      final controller = ReceivedOrdersController(
        'business-1',
        ReceivedOrdersUseCase(repository),
        autoLoad: false,
      );
      await controller.loadReceivedOrders();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            receivedOrdersControllerProvider('business-1').overrideWith(
              (ref) => controller,
            ),
          ],
          child: MaterialApp(
            theme: darkTheme,
            home: const ReceivedOrdersPage(businessId: 'business-1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('لا توجد طلبات الآن'), findsOneWidget);
    });
  });
}
