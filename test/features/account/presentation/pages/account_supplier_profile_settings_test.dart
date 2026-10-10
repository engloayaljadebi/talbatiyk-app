import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/core/network/network_providers.dart';
import 'package:talbatiyk/features/account/presentation/pages/account_page.dart';
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
import 'package:talbatiyk/features/business/presentation/pages/business_profile_edit_page.dart';
import 'package:talbatiyk/features/business/presentation/providers/business_provider.dart';
import 'package:talbatiyk/features/business/presentation/state/business_state.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';
import 'package:talbatiyk/features/products/presentation/providers/products_provider.dart';
import 'package:talbatiyk/features/received_orders/domain/entities/received_order_entity.dart';
import 'package:talbatiyk/features/received_orders/domain/repositories/received_orders_repository.dart';
import 'package:talbatiyk/features/received_orders/domain/usecases/received_orders_usecase.dart';
import 'package:talbatiyk/features/received_orders/presentation/controllers/received_orders_controller.dart';
import 'package:talbatiyk/features/received_orders/presentation/providers/received_orders_provider.dart';

void main() {
  testWidgets('supplier settings opens the selected business profile editor', (
    tester,
  ) async {
    const business = BusinessEntity(
      id: 'business-1',
      name: 'ظ…طھط¬ط± ط·ظ„ط¨ظٹطھظƒ',
      legalName: 'ط´ط±ظƒط© ط·ظ„ط¨ظٹطھظƒ',
      description: 'ظˆطµظپ ط§ظ„ظ†ط´ط§ط·',
    );

    final businessController = BusinessController(
      BusinessUseCase(_FakeBusinessRepository()),
    )..state = BusinessState.loaded(<BusinessEntity>[business]);

    final authController = AuthController(
      AuthUseCase(_FakeAuthRepository()),
      autoRestore: false,
    )..state = const AuthState(status: AuthStatus.unauthenticated);

    final ordersController = ReceivedOrdersController(
      business.id,
      ReceivedOrdersUseCase(_FakeReceivedOrdersRepository()),
      autoLoad: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          generatedApiClientProvider.overrideWithValue(
            GeneratedApiClient.create(baseUrl: 'http://127.0.0.1:8000/api/v1'),
          ),
          authProvider.overrideWith((ref) => authController),
          businessControllerProvider.overrideWith((ref) => businessController),
          supplierManagedProductsProvider.overrideWith(
            (ref, businessId) async => const <ProductEntity>[],
          ),
          receivedOrdersControllerProvider.overrideWith(
            (ref, businessId) => ordersController,
          ),
        ],
        child: const MaterialApp(home: AccountPage()),
      ),
    );

    await tester.pumpAndSettle();

    final supplierSettings = find.widgetWithIcon(
      FilledButton,
      Icons.edit_outlined,
    );

    expect(supplierSettings, findsOneWidget);

    await tester.tap(supplierSettings);
    await tester.pumpAndSettle();

    expect(find.byType(BusinessProfileEditPage), findsOneWidget);

    final editPage = tester.widget<BusinessProfileEditPage>(
      find.byType(BusinessProfileEditPage),
    );

    expect(editPage.business.id, business.id);
    expect(editPage.business.name, business.name);
  });
}

final class _FakeBusinessRepository implements BusinessRepository {
  @override
  Future<List<BusinessEntity>> getAccessibleBusinesses() async =>
      const <BusinessEntity>[];
}

final class _FakeAuthRepository implements AuthRepository {
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
  @override
  Future<List<ReceivedOrderEntity>> getReceivedOrders({
    required String businessId,
  }) async => const <ReceivedOrderEntity>[];

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
