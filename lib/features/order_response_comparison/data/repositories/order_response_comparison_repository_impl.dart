import '../../../orders/data/datasources/local/orders_local_datasource.dart';
import '../../../orders/data/mappers/orders_mapper.dart';
import '../../domain/entities/order_response_comparison_entity.dart';
import '../../domain/repositories/order_response_comparison_repository.dart';
import '../datasources/remote/order_response_comparison_remote_datasource.dart';
import '../mappers/order_response_comparison_mapper.dart';

final class OrderResponseComparisonRepositoryImpl
    implements OrderResponseComparisonRepository {
  OrderResponseComparisonRepositoryImpl(
    this._remoteDataSource,
    this._ordersLocalDataSource,
  );

  final OrderResponseComparisonRemoteDataSource _remoteDataSource;
  final OrdersLocalDataSource _ordersLocalDataSource;

  @override
  Future<OrderResponseComparisonEntity> getComparison({
    required String orderId,
  }) async {
    final resource = await _remoteDataSource.show(orderId: orderId);
    final comparison = OrderResponseComparisonMapper.fromResource(resource);

    await _persistAggregateStatus(comparison);

    return comparison;
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

    final comparison = OrderResponseComparisonMapper.fromResource(resource);

    await _persistAggregateStatus(comparison);

    return comparison;
  }

  Future<void> _persistAggregateStatus(
    OrderResponseComparisonEntity comparison,
  ) {
    return _ordersLocalDataSource.updateAggregateStatusSnapshot(
      orderId: comparison.id,
      aggregateStatus: OrdersMapper.aggregateStatusToDataValue(
        comparison.aggregateStatus,
      ),
    );
  }
}
