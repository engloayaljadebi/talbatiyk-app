import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/account/presentation/pages/account_page.dart';
import 'package:talbatiyk/features/account/presentation/providers/account_business_approvals_provider.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/repositories/auth_repository.dart';
import 'package:talbatiyk/features/auth/domain/usecases/auth_usecase.dart';
import 'package:talbatiyk/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talbatiyk/features/auth/presentation/providers/auth_providers.dart';
import 'package:talbatiyk/features/auth/presentation/states/auth_state.dart';
import 'package:talbatiyk/features/business/domain/entities/business_entity.dart';
import 'package:talbatiyk/features/business/domain/repositories/business_repository.dart';
import 'package:talbatiyk/features/business/domain/usecases/business_usecase.dart';
import 'package:talbatiyk/features/business/presentation/controllers/business_controller.dart';
import 'package:talbatiyk/features/business/presentation/providers/business_provider.dart';
import 'package:talbatiyk/features/business/presentation/state/business_state.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';
import 'package:talbatiyk/features/products/presentation/providers/products_provider.dart';
import 'package:talbatiyk/features/received_orders/domain/entities/received_order_entity.dart';
import 'package:talbatiyk/features/received_orders/domain/repositories/received_orders_repository.dart';
import 'package:talbatiyk/features/received_orders/domain/usecases/received_orders_usecase.dart';
import 'package:talbatiyk/features/received_orders/presentation/controllers/received_orders_controller.dart';
import 'package:talbatiyk/features/received_orders/presentation/providers/received_orders_provider.dart';
import 'package:talbatiyk/features/received_orders/presentation/state/received_orders_state.dart';

void main() {
  testWidgets(
    'Account profile shows received orders for the selected business',
    (tester) async {
      final businessController = BusinessController(
        BusinessUseCase(_FakeBusinessRepository()),
      );
      businessController.state = BusinessState.loaded([
        const BusinessEntity(id: 'business-a', name: 'متجر أ'),
        const BusinessEntity(id: 'business-b', name: 'متجر ب'),
      ]);

      final ordersControllerA =
          ReceivedOrdersController(
              'business-a',
              ReceivedOrdersUseCase(
                _FakeReceivedOrdersRepository([
                  ReceivedOrderEntity(
                    id: 'recipient-a',
                    orderId: 'ABCDEF12',
                    supplierId: 'business-a',
                    supplierName: 'متجر أ',
                    orderStatus: 'paid',
                    fulfillmentStatus: ReceivedOrderFulfillmentStatus.confirmed,
                    items: [
                      ReceivedOrderItemEntity(
                        id: 'item-a',
                        productId: 'prod-a',
                        productName: 'منتج أ',
                        unitPrice: '30.00',
                        requestedQuantity: 2,
                      ),
                    ],
                    createdAt: DateTime(2024, 4, 10, 18, 30),
                  ),
                ]),
              ),
              autoLoad: false,
            )
            ..state = ReceivedOrdersState(
              orders: [
                ReceivedOrderEntity(
                  id: 'recipient-a',
                  orderId: 'ABCDEF12',
                  supplierId: 'business-a',
                  supplierName: 'متجر أ',
                  orderStatus: 'paid',
                  fulfillmentStatus: ReceivedOrderFulfillmentStatus.confirmed,
                  items: [
                    ReceivedOrderItemEntity(
                      id: 'item-a',
                      productId: 'prod-a',
                      productName: 'منتج أ',
                      unitPrice: '30.00',
                      requestedQuantity: 2,
                    ),
                  ],
                  createdAt: DateTime(2024, 4, 10, 18, 30),
                ),
              ],
            );

      final ordersControllerB =
          ReceivedOrdersController(
              'business-b',
              ReceivedOrdersUseCase(
                _FakeReceivedOrdersRepository([
                  ReceivedOrderEntity(
                    id: 'recipient-b',
                    orderId: 'BCDEFG34',
                    supplierId: 'business-b',
                    supplierName: 'متجر ب',
                    orderStatus: 'paid',
                    fulfillmentStatus: ReceivedOrderFulfillmentStatus.preparing,
                    items: [
                      ReceivedOrderItemEntity(
                        id: 'item-b',
                        productId: 'prod-b',
                        productName: 'منتج ب',
                        unitPrice: '50.00',
                        requestedQuantity: 3,
                      ),
                    ],
                    createdAt: DateTime(2024, 4, 12, 10, 0),
                  ),
                ]),
              ),
              autoLoad: false,
            )
            ..state = ReceivedOrdersState(
              orders: [
                ReceivedOrderEntity(
                  id: 'recipient-b',
                  orderId: 'BCDEFG34',
                  supplierId: 'business-b',
                  supplierName: 'متجر ب',
                  orderStatus: 'paid',
                  fulfillmentStatus: ReceivedOrderFulfillmentStatus.preparing,
                  items: [
                    ReceivedOrderItemEntity(
                      id: 'item-b',
                      productId: 'prod-b',
                      productName: 'منتج ب',
                      unitPrice: '50.00',
                      requestedQuantity: 3,
                    ),
                  ],
                  createdAt: DateTime(2024, 4, 12, 10, 0),
                ),
              ],
            );

      final authController = AuthController(
        AuthUseCase(_FakeAuthRepository()),
        autoRestore: false,
      );
      authController.state = const AuthState(
        status: AuthStatus.authenticated,
        session: AuthSessionEntity(
          user: AuthUserEntity(
            id: 'test-approval-user',
            username: 'testaccount',
            displayName: 'Test Account',
            status: 'active',
            lastLoginAt: null,
            contacts: <AuthContactEntity>[],
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            accountBusinessApprovalsProvider.overrideWith(
              (ref, userId) async => const <String, AccountBusinessApproval>{
                'business-a': AccountBusinessApproval(
                  businessId: 'business-a',
                  shopStatus: null,
                  supplierStatus: 'approved',
                  supplierEnabled: true,
                ),
                'business-b': AccountBusinessApproval(
                  businessId: 'business-b',
                  shopStatus: null,
                  supplierStatus: 'approved',
                  supplierEnabled: true,
                ),
              },
            ),
            authProvider.overrideWith((ref) => authController),
            businessControllerProvider.overrideWith(
              (ref) => businessController,
            ),
            supplierManagedProductsProvider.overrideWith(
              (ref, businessId) async => const <ProductEntity>[],
            ),
            receivedOrdersControllerProvider.overrideWith(
              (ref, businessId) => switch (businessId) {
                'business-a' => ordersControllerA,
                'business-b' => ordersControllerB,
                _ => ordersControllerA,
              },
            ),
          ],
          child: const MaterialApp(home: AccountPage()),
        ),
      );

      // Wait until the asynchronous approval provider resolves.
      // Supplier tools must remain hidden until approval is verified.
      await tester.pumpAndSettle();

      expect(find.text('متجر أ'), findsWidgets);
      expect(find.text('الطلبات'), findsWidgets);

      final ordersTab = find.text('الطلبات').last;
      await tester.ensureVisible(ordersTab);
      await tester.pumpAndSettle();
      await tester.tap(ordersTab);
      await tester.pumpAndSettle();

      expect(find.textContaining('ABCDEF12'), findsOneWidget);

      // Return to the top: ListView may have disposed its off-screen child.
      final mainScroll = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      mainScroll.position.jumpTo(mainScroll.position.minScrollExtent);
      await tester.pumpAndSettle();

      final businessSelector = find.byType(DropdownButton<String>);
      expect(businessSelector, findsOneWidget);
      await tester.tap(businessSelector);
      await tester.pumpAndSettle();
      await tester.tap(find.text('متجر ب').last);
      await tester.pumpAndSettle();

      // Scroll down again after changing the selected business.
      final ordersTabAfterSwitch = find.text('الطلبات').last;

      await tester.dragUntilVisible(
        ordersTabAfterSwitch,
        find.byType(Scrollable).first,
        const Offset(0, -220),
      );
      await tester.pumpAndSettle();

      await tester.tap(ordersTabAfterSwitch);
      await tester.pumpAndSettle();

      expect(find.textContaining('BCDEFG34'), findsOneWidget);
    },
  );
}

final class _FakeBusinessRepository implements BusinessRepository {
  @override
  Future<List<BusinessEntity>> getAccessibleBusinesses() async => const [];
}

final class _FakeAuthRepository implements AuthRepository {
  @override
  Future<List<({String id, String name})>> fetchRegistrationCategories() async {
    throw UnimplementedError('Registration categories not used here.');
  }

  @override
  Future<AuthSessionEntity> registerFromMobile(
    Map<String, Object?> payload,
  ) async {
    throw UnimplementedError('Registration not used here.');
  }

  @override
  Future<AuthSessionEntity> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthSessionEntity?> restoreSession() async => null;

  @override
  Future<AuthUserEntity> getCurrentUser() async {
    throw UnimplementedError();
  }

  @override
  Future<AuthUserEntity> updateProfile({
    String? username,
    String? displayName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}
}

final class _FakeReceivedOrdersRepository implements ReceivedOrdersRepository {
  const _FakeReceivedOrdersRepository(this._orders);

  final List<ReceivedOrderEntity> _orders;

  @override
  Future<List<ReceivedOrderEntity>> getReceivedOrders({
    required String businessId,
  }) async => _orders;

  @override
  Future<ReceivedOrderResponseEntity> submitResponse({
    required String businessId,
    required String recipientId,
    required String idempotencyKey,
    required List<SubmitReceivedOrderItemResponse> items,
  }) async {
    throw UnimplementedError();
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
}
