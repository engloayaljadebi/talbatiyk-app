import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/entities/registration_validation_exception.dart';
import 'package:talbatiyk/features/auth/domain/repositories/auth_repository.dart';
import 'package:talbatiyk/features/auth/domain/usecases/auth_usecase.dart';
import 'package:talbatiyk/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talbatiyk/features/auth/presentation/states/auth_state.dart';

void main() {
  const user = AuthUserEntity(
    id: '11111111-1111-4111-8111-111111111111',
    username: 'shoptest',
    displayName: 'Test Shop Owner',
    status: 'active',
    lastLoginAt: null,
    contacts: <AuthContactEntity>[],
  );
  const session = AuthSessionEntity(user: user);

  group('Mobile registration controller validation', () {
    late _RegistrationRepository repository;
    late AuthController controller;

    setUp(() {
      repository = _RegistrationRepository(session);
      controller = AuthController(AuthUseCase(repository), autoRestore: false);
    });

    tearDown(() {
      controller.dispose();
    });

    test('422 errors are available by field without authenticating', () async {
      repository.failure = RegistrationValidationException({
        'username': 'اسم المستخدم مستخدم مسبقًا.',
        'contact_value': 'وسيلة الاتصال مستخدمة في حساب آخر.',
      });

      final result = await controller.registerFromMobile({
        'account_type': 'shop',
      });

      expect(result, isFalse);
      expect(repository.registerCalls, 1);
      expect(controller.state.isAuthenticated, isFalse);
      expect(controller.state.session, isNull);
      expect(controller.state.isRegistering, isFalse);
      expect(
        controller.state.registrationFieldErrors['username'],
        'اسم المستخدم مستخدم مسبقًا.',
      );
      expect(
        controller.state.registrationFieldErrors['contact_value'],
        'وسيلة الاتصال مستخدمة في حساب آخر.',
      );
      expect(
        controller.state.registrationErrorMessage,
        contains('مراجعة البيانات'),
      );
    });

    test(
      'retry clears prior field errors before the request completes',
      () async {
        repository.failure = RegistrationValidationException({
          'username': 'اسم المستخدم مستخدم مسبقًا.',
        });
        await controller.registerFromMobile({'account_type': 'supplier'});
        expect(controller.state.registrationFieldErrors, isNotEmpty);

        repository.failure = null;
        repository.pending = Completer<AuthSessionEntity>();
        final pending = controller.registerFromMobile({
          'account_type': 'supplier',
        });

        expect(controller.state.isRegistering, isTrue);
        expect(controller.state.isBusy, isTrue);
        expect(controller.state.registrationFieldErrors, isEmpty);
        expect(controller.state.registrationErrorMessage, isNull);

        repository.pending!.complete(session);
        expect(await pending, isTrue);
        expect(controller.state.status, AuthStatus.authenticated);
        expect(controller.state.session, same(session));
        expect(controller.state.registrationFieldErrors, isEmpty);
        expect(controller.state.isRegistering, isFalse);
        expect(repository.registerCalls, 2);
      },
    );

    test('non-validation failures do not leave stale field errors', () async {
      repository.failure = RegistrationValidationException({
        'category_id': 'يجب اختيار فئة نشاط صحيحة.',
      });
      await controller.registerFromMobile({'account_type': 'shop'});
      expect(controller.state.registrationFieldErrors, isNotEmpty);

      repository.failure = Exception('network unavailable');
      final result = await controller.registerFromMobile({
        'account_type': 'shop',
      });

      expect(result, isFalse);
      expect(controller.state.registrationFieldErrors, isEmpty);
      expect(
        controller.state.registrationErrorMessage,
        'تعذر إنشاء الحساب. تحقق من البيانات وحاول مرة أخرى.',
      );
      expect(controller.state.isRegistering, isFalse);
    });

    test('concurrent duplicate registration is rejected', () async {
      repository.pending = Completer<AuthSessionEntity>();
      final first = controller.registerFromMobile({'account_type': 'supplier'});

      final second = await controller.registerFromMobile({
        'account_type': 'supplier',
      });
      expect(second, isFalse);
      expect(repository.registerCalls, 1);

      repository.pending!.complete(session);
      expect(await first, isTrue);
      expect(repository.registerCalls, 1);
    });

    test('ordinary customer account type is not accepted', () async {
      final result = await controller.registerFromMobile({
        'account_type': 'customer',
      });

      expect(result, isFalse);
      expect(repository.registerCalls, 0);
      expect(controller.state.isAuthenticated, isFalse);
    });
  });
}

final class _RegistrationRepository implements AuthRepository {
  _RegistrationRepository(this.session);

  final AuthSessionEntity session;
  Object? failure;
  Completer<AuthSessionEntity>? pending;
  int registerCalls = 0;

  @override
  Future<AuthSessionEntity> registerFromMobile(
    Map<String, Object?> payload,
  ) async {
    registerCalls++;
    final error = failure;
    if (error != null) {
      throw error;
    }
    final completer = pending;
    if (completer != null) {
      return completer.future;
    }
    return session;
  }

  @override
  Future<List<({String id, String name})>> fetchRegistrationCategories() async {
    return <({String id, String name})>[];
  }

  @override
  Future<AuthSessionEntity> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    return session;
  }

  @override
  Future<AuthSessionEntity?> restoreSession() async => null;

  @override
  Future<AuthUserEntity> getCurrentUser() async => session.user;

  @override
  Future<AuthUserEntity> updateProfile({
    String? username,
    String? displayName,
  }) async => session.user;

  @override
  Future<void> logout() async {}
}
