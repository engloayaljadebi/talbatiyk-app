import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/supplier_candidate_entity.dart';
import '../../domain/repositories/supplier_discovery_repository.dart';
import '../datasources/local/supplier_discovery_local_datasource.dart';
import '../datasources/remote/supplier_discovery_remote_datasource.dart';
import '../mappers/supplier_discovery_mapper.dart';

final class SupplierDiscoveryRepositoryImpl
    implements SupplierDiscoveryRepository {
  const SupplierDiscoveryRepositoryImpl(
    this._remoteDataSource, {
    required this._localDataSource,
    required this._currentUserId,
  });

  final SupplierDiscoveryRemoteDataSource _remoteDataSource;
  final SupplierDiscoveryLocalDataSource _localDataSource;
  final String? Function() _currentUserId;

  @override
  Future<List<SupplierCandidateEntity>> getSuppliers() async {
    final userId = _currentUserId();
    if (userId == null || userId.isEmpty) {
      throw StateError('Supplier discovery requires an authenticated user.');
    }

    try {
      final resources = await _remoteDataSource.index();
      final suppliers = List<SupplierCandidateEntity>.unmodifiable(
        resources.map(SupplierDiscoveryMapper.fromResource),
      );
      // Never return a snapshot from a different account after an in-flight
      // request completes during an account switch.
      if (_currentUserId() != userId) {
        throw StateError('Authenticated user changed during discovery.');
      }
      await _localDataSource.replace(userId: userId, suppliers: suppliers);
      return suppliers;
    } catch (error) {
      if (!_isTransient(error) || _currentUserId() != userId) rethrow;
      final cached = await _localDataSource.readSnapshot(userId: userId);
      if (cached.isEmpty) rethrow;
      return cached;
    }
  }

  bool _isTransient(Object error) {
    if (error is! DioException) return false;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.unknown:
        return error.error is SocketException;
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        return code == 408 || code == 429 || (code != null && code >= 500);
      default:
        return false;
    }
  }
}
