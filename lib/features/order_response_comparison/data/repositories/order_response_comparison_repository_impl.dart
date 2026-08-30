import '../../domain/entities/order_response_comparison_entity.dart';
import '../../domain/repositories/order_response_comparison_repository.dart';
import '../datasources/remote/order_response_comparison_remote_datasource.dart';
import '../mappers/order_response_comparison_mapper.dart';

final class OrderResponseComparisonRepositoryImpl
    implements OrderResponseComparisonRepository {
  OrderResponseComparisonRepositoryImpl(this._remoteDataSource);

  final OrderResponseComparisonRemoteDataSource _remoteDataSource;

  @override
  Future<OrderResponseComparisonEntity> getComparison({
    required String orderId,
  }) async {
    final resource = await _remoteDataSource.show(orderId: orderId);

    return OrderResponseComparisonMapper.fromResource(resource);
  }

  @override
  Future<OrderResponseComparisonEntity> replaceSelections({
    required String orderId,
    required int expectedVersion,
    required List<OrderResponseSelectionInput> selections,
  }) async {
    final resource = await _remoteDataSource.replaceSelections(
      orderId: orderId,
      expectedVersion: expectedVersion,
      selections: selections,
    );

    return OrderResponseComparisonMapper.fromResource(resource);
  }
}
