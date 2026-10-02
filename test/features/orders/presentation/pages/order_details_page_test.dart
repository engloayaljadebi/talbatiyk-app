import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/order_response_comparison/domain/entities/order_response_comparison_entity.dart';
import 'package:talbatiyk/features/order_response_comparison/domain/repositories/order_response_comparison_repository.dart';
import 'package:talbatiyk/features/order_response_comparison/presentation/pages/order_response_comparison_page.dart';
import 'package:talbatiyk/features/order_response_comparison/presentation/providers/order_response_comparison_provider.dart';
import 'package:talbatiyk/features/orders/domain/entities/orders_entity.dart';
import 'package:talbatiyk/features/orders/domain/repositories/orders_repository.dart';
import 'package:talbatiyk/features/orders/domain/usecases/orders_usecase.dart';
import 'package:talbatiyk/features/orders/presentation/controllers/orders_controller.dart';
import 'package:talbatiyk/features/orders/presentation/pages/order_details_page.dart';
import 'package:talbatiyk/features/orders/presentation/providers/orders_provider.dart';

void main() {
  late _FakeOrdersRepository ordersRepository;
  late _FakeComparisonRepository comparisonRepository;

  setUp(() {
    ordersRepository = _FakeOrdersRepository();
    comparisonRepository = _FakeComparisonRepository();
  });

  Widget createSubject({required OrderEntity order}) {
    return ProviderScope(
      overrides: [
        ordersProvider.overrideWith(
          (ref) => OrdersController(
            OrdersUseCase(ordersRepository),
            autoLoad: false,
          ),
        ),
        orderResponseComparisonRepositoryProvider.overrideWithValue(
          comparisonRepository,
        ),
      ],
      child: MaterialApp(home: OrderDetailsPage(order: order)),
    );
  }

  testWidgets(
    'disables supplier responses action and displays pending sync message for local-order-*',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final localOrder = OrderEntity(
        id: 'local-order-1727829102000',
        status: OrderStatus.pending,
        aggregateStatus: OrderAggregateStatus.pendingResponses,
        items: const [
          OrderItemEntity(
            productId: 'product-1',
            productName: 'منتج تجريبي',
            unitPrice: 100,
            quantity: 2,
            supplierId: 'supplier-1',
            supplierName: 'مورد تجريبي',
          ),
        ],
        createdAt: DateTime.utc(2026, 9, 26, 12, 0),
      );

      await tester.pumpWidget(createSubject(order: localOrder));
      await tester.pumpAndSettle();

      // التحقق من ظهور رسالة المزامنة باللغة العربية
      expect(
        find.text(
          'الطلبية قيد المزامنة حالياً مع الخادم. ستكون ردود الموردين متاحة فور اكتمال المزامنة.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('جاري إرسال الطلبية إلى الخادم والموردين...'),
        findsOneWidget,
      );
      expect(find.text('بانتظار اكتمال المزامنة'), findsOneWidget);

      // التحقق من أن الزر معطّل
      final buttonFinder = find.byKey(const Key('open-supplier-responses'));
      final button = tester.widget<FilledButton>(buttonFinder);
      expect(button.onPressed, isNull);

      // محاولة الضغط على الزر المعطل لا يجب أن تفتح صفحة المقارنة
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();
      await tester.tap(buttonFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(OrderResponseComparisonPage), findsNothing);
      expect(comparisonRepository.getCalls, 0);
    },
  );

  testWidgets(
    'enables supplier responses action and allows navigation for server UUID order',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const serverOrderId = '550e8400-e29b-41d4-a716-446655440000';
      final serverOrder = OrderEntity(
        id: serverOrderId,
        status: OrderStatus.pending,
        aggregateStatus: OrderAggregateStatus.pendingResponses,
        items: const [
          OrderItemEntity(
            productId: 'product-1',
            productName: 'منتج تجريبي',
            unitPrice: 100,
            quantity: 2,
            supplierId: 'supplier-1',
            supplierName: 'مورد تجريبي',
          ),
        ],
        createdAt: DateTime.utc(2026, 9, 26, 12, 0),
      );

      await tester.pumpWidget(createSubject(order: serverOrder));
      await tester.pumpAndSettle();

      // التحقق من ظهور النص المعتاد للطلبية المزامنة
      expect(
        find.text(
          'راجع الكميات المتاحة والأسعار التي أرسلها الموردون، ثم اختر العرض المناسب لك.',
        ),
        findsOneWidget,
      );
      expect(find.text('عرض ردود الموردين'), findsOneWidget);
      expect(
        find.text('جاري إرسال الطلبية إلى الخادم والموردين...'),
        findsNothing,
      );

      // التحقق من أن الزر مفعّل
      final buttonFinder = find.byKey(const Key('open-supplier-responses'));
      final button = tester.widget<FilledButton>(buttonFinder);
      expect(button.onPressed, isNotNull);

      // التمرير إلى الزر والضغط عليه يفتح صفحة مقارنة ردود الموردين
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(OrderResponseComparisonPage), findsOneWidget);
      expect(comparisonRepository.getCalls, 1);
      expect(comparisonRepository.lastOrderId, serverOrderId);
    },
  );

  testWidgets('disables supplier responses action when order ID is empty', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final emptyIdOrder = OrderEntity(
      id: '',
      status: OrderStatus.pending,
      aggregateStatus: OrderAggregateStatus.pendingResponses,
      items: const [
        OrderItemEntity(
          productId: 'product-1',
          productName: 'منتج تجريبي',
          unitPrice: 100,
          quantity: 2,
          supplierId: 'supplier-1',
          supplierName: 'مورد تجريبي',
        ),
      ],
      createdAt: DateTime.utc(2026, 9, 26, 12, 0),
    );

    await tester.pumpWidget(createSubject(order: emptyIdOrder));
    await tester.pumpAndSettle();

    final buttonFinder = find.byKey(const Key('open-supplier-responses'));
    final button = tester.widget<FilledButton>(buttonFinder);
    expect(button.onPressed, isNull);
    expect(find.text('بانتظار اكتمال المزامنة'), findsOneWidget);
  });
}

final class _FakeOrdersRepository implements OrdersRepository {
  @override
  Future<List<OrderEntity>> getOrders() async => const [];

  @override
  Future<OrderEntity> createOrder(CreateOrderRequest request) async {
    throw UnimplementedError();
  }
}

final class _FakeComparisonRepository
    implements OrderResponseComparisonRepository {
  int getCalls = 0;
  String? lastOrderId;

  @override
  Future<OrderResponseComparisonEntity> getComparison({
    required String orderId,
  }) async {
    getCalls++;
    lastOrderId = orderId;

    return const OrderResponseComparisonEntity(
      id: 'comparison-1',
      version: 1,
      status: 'submitted',
      aggregateStatus: OrderAggregateStatus.pendingResponses,
      notes: null,
      items: [],
      createdAt: null,
      updatedAt: null,
    );
  }

  @override
  Future<OrderResponseComparisonEntity> replaceSelections({
    required String orderId,
    required int expectedVersion,
    required List<OrderResponseSelectionInput> selections,
  }) async {
    throw UnimplementedError();
  }
}
