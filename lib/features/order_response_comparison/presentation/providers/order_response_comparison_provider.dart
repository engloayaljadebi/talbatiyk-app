import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talbatiyk/core/network/network_providers.dart';

import '../../data/datasources/remote/order_response_comparison_remote_datasource.dart';
import '../../data/repositories/order_response_comparison_repository_impl.dart';
import '../../domain/repositories/order_response_comparison_repository.dart';
import '../../domain/usecases/order_response_comparison_usecase.dart';
import '../controllers/order_response_comparison_controller.dart';

final orderResponseComparisonRemoteDataSourceProvider =
    Provider<OrderResponseComparisonRemoteDataSource>((ref) {
      return OrderResponseComparisonRemoteDataSourceImpl(
        ref.watch(generatedApiClientProvider),
      );
    });

final orderResponseComparisonRepositoryProvider =
    Provider<OrderResponseComparisonRepository>((ref) {
      return OrderResponseComparisonRepositoryImpl(
        ref.watch(orderResponseComparisonRemoteDataSourceProvider),
      );
    });

final orderResponseComparisonUseCaseProvider =
    Provider<OrderResponseComparisonUseCase>((ref) {
      return OrderResponseComparisonUseCase(
        ref.watch(orderResponseComparisonRepositoryProvider),
      );
    });

final orderResponseComparisonControllerProvider =
    ChangeNotifierProvider.family<OrderResponseComparisonController, String>((
      ref,
      orderId,
    ) {
      return OrderResponseComparisonController(
        orderId,
        ref.watch(orderResponseComparisonUseCaseProvider),
      );
    });
