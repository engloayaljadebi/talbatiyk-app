import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/entities/registration_validation_exception.dart';
import 'package:talbatiyk/features/auth/domain/repositories/auth_repository.dart';
import 'package:talbatiyk/features/auth/domain/usecases/auth_usecase.dart';
import 'package:talbatiyk/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talbatiyk/features/auth/presentation/pages/register_page.dart';
import 'package:talbatiyk/features/auth/presentation/providers/auth_providers.dart';
import 'package:talbatiyk/features/auth/presentation/states/auth_state.dart';

const _categoryId = '11111111-1111-4111-8111-111111111111';
const _otherCategoryId = '22222222-2222-4222-8222-222222222222';

void main() {
  late _RegistrationWidgetRepository repository;
  late AuthController controller;

  setUp(() {
    repository = _RegistrationWidgetRepository();
    controller = AuthController(AuthUseCase(repository), autoRestore: false);
  });

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith((ref) => controller)],
        child: const MaterialApp(home: RegisterPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> advance(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('register-continue')));
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String field, String text) async {
    final finder = find.byKey(ValueKey('register-$field'));
    expect(finder, findsOneWidget);
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.enterText(finder, text);
    await tester.pump();
  }

  Future<void> selectCategory(WidgetTester tester) async {
    final finder = find.byKey(const ValueKey('register-category-empty'));
    expect(finder, findsOneWidget);
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pumpAndSettle();
    await tester.tap(find.text('المستلزمات الطبية').last);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('register-category-$_categoryId')),
      findsOneWidget,
    );
  }

  Future<void> fillThroughReview(
    WidgetTester tester, {
    bool supplier = false,
  }) async {
    if (supplier) {
      await tester.tap(find.text('مورد'));
      await tester.pumpAndSettle();
    }
    await advance(tester); // Type -> Account
    expect(find.text('المرحلة 2 من 6 — الحساب'), findsOneWidget);
    await enter(tester, 'username', supplier ? 'supplier123' : 'shop123');
    await enter(tester, 'display_name', 'مستخدم تجريبي');
    await enter(tester, 'contact_value', '777123456');
    await enter(tester, 'password', 'ValidPassword123');
    await enter(tester, 'password-confirmation', 'ValidPassword123');
    await advance(tester); // Account -> Personal
    expect(find.text('المرحلة 3 من 6 — الشخصية'), findsOneWidget);
    await advance(tester); // Personal -> Business (optional details)
    expect(find.text('المرحلة 4 من 6 — النشاط'), findsOneWidget);
    await enter(tester, 'name', supplier ? 'مؤسسة التوريد' : 'متجر الاختبار');
    await selectCategory(tester);
    await advance(tester); // Business -> Location
    expect(find.text('المرحلة 5 من 6 — الموقع'), findsOneWidget);
    await enter(tester, 'location_name', 'الموقع الرئيسي');
    await enter(tester, 'administrative_area', 'صنعاء');
    await enter(tester, 'locality', 'أمانة العاصمة');
    await advance(tester); // Location -> Review
    expect(find.text('المرحلة 6 من 6 — المراجعة'), findsOneWidget);
  }

  group('Mobile registration V6 screen', () {
    testWidgets('shows only shop and supplier account types', (tester) async {
      await mount(tester);
      expect(find.text('متجر'), findsOneWidget);
      expect(find.text('مورد'), findsOneWidget);
      expect(find.text('عميل عادي'), findsNothing);
      expect(find.text('المرحلة 1 من 6 — النوع'), findsOneWidget);
    });

    testWidgets('required account fields block navigation and submission', (
      tester,
    ) async {
      await mount(tester);
      await advance(tester); // Type -> Account
      await advance(tester); // Empty account must not advance
      expect(find.text('المرحلة 2 من 6 — الحساب'), findsOneWidget);
      expect(repository.submissions, isEmpty);
    });

    testWidgets('successful supplier submits the existing API field contract', (
      tester,
    ) async {
      await mount(tester);
      await fillThroughReview(tester, supplier: true);
      await advance(tester);
      expect(repository.submissions, hasLength(1));
      final submitted = repository.submissions.single;
      expect(submitted['account_type'], 'supplier');
      expect(submitted['category_id'], _categoryId);
      expect(submitted['location_type'], 'warehouse');
      expect(submitted['contact_type'], 'phone');
      expect(submitted['contact_value'], '777123456');
      expect(controller.state.status, AuthStatus.authenticated);
    });

    testWidgets('422 errors return to account and clear on each field edit', (
      tester,
    ) async {
      repository.failure = RegistrationValidationException({
        'username': 'اسم المستخدم مستخدم مسبقًا.',
        'contact_value': 'رقم الهاتف مستخدم مسبقًا.',
      });
      await mount(tester);
      await fillThroughReview(tester);
      await advance(tester); // Submit -> 422 -> Account
      expect(repository.submissions, hasLength(1));
      expect(repository.submissions.single['account_type'], 'shop');
      expect(repository.submissions.single['category_id'], _categoryId);
      expect(controller.state.isAuthenticated, isFalse);
      expect(find.text('المرحلة 2 من 6 — الحساب'), findsOneWidget);

      expect(find.text('اسم المستخدم مستخدم مسبقًا.'), findsOneWidget);
      expect(find.text('رقم الهاتف مستخدم مسبقًا.'), findsOneWidget);

      await enter(tester, 'username', 'anotherShop123');
      expect(find.text('اسم المستخدم مستخدم مسبقًا.'), findsNothing);
      expect(find.text('رقم الهاتف مستخدم مسبقًا.'), findsOneWidget);
    });

    testWidgets(
      '422 category error returns to business and shows field error',
      (tester) async {
        repository.failure = RegistrationValidationException({
          'category_id': 'فئة النشاط غير متاحة حاليًا.',
        });
        await mount(tester);
        await fillThroughReview(tester, supplier: true);
        await advance(tester);
        expect(repository.submissions, hasLength(1));
        expect(repository.submissions.single['account_type'], 'supplier');
        expect(repository.submissions.single['location_type'], 'warehouse');
        expect(find.text('المرحلة 4 من 6 — النشاط'), findsOneWidget);
        expect(find.text('فئة النشاط غير متاحة حاليًا.'), findsOneWidget);
      },
    );

    testWidgets('non-validation failure stays on review with general error', (
      tester,
    ) async {
      repository.failure = StateError('test offline failure');
      await mount(tester);
      await fillThroughReview(tester);
      await advance(tester);
      expect(repository.submissions, hasLength(1));
      expect(find.text('المرحلة 6 من 6 — المراجعة'), findsOneWidget);
      expect(
        find.text('تعذر إنشاء الحساب. تحقق من البيانات وحاول مرة أخرى.'),
        findsOneWidget,
      );
      expect(controller.state.registrationFieldErrors, isEmpty);
    });
  });
}

final class _RegistrationWidgetRepository implements AuthRepository {
  Object? failure;
  final List<Map<String, Object?>> submissions = [];

  static const _user = AuthUserEntity(
    id: '33333333-3333-4333-8333-333333333333',
    username: 'shop123',
    displayName: 'مستخدم تجريبي',
    status: 'active',
    lastLoginAt: null,
    contacts: <AuthContactEntity>[],
  );
  static const _session = AuthSessionEntity(user: _user);

  @override
  Future<List<({String id, String name})>> fetchRegistrationCategories() async {
    return [
      (id: _categoryId, name: 'المستلزمات الطبية'),
      (id: _otherCategoryId, name: 'الأواني المنزلية'),
    ];
  }

  @override
  Future<AuthSessionEntity> registerFromMobile(
    Map<String, Object?> payload,
  ) async {
    submissions.add(Map<String, Object?>.of(payload));
    final error = failure;
    if (error != null) {
      throw error;
    }
    return _session;
  }

  @override
  Future<AuthSessionEntity> login({
    required String login,
    required String password,
    required String deviceName,
  }) async => _session;

  @override
  Future<AuthSessionEntity?> restoreSession() async => null;

  @override
  Future<AuthUserEntity> getCurrentUser() async => _user;

  @override
  Future<AuthUserEntity> updateProfile({
    String? username,
    String? displayName,
  }) async => _user;

  @override
  Future<void> logout() async {}
}
