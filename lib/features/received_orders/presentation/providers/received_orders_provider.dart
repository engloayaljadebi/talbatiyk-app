import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/remote/received_orders_remote_datasource.dart';
import '../../data/repositories/received_orders_repository_impl.dart';
import '../../domain/repositories/received_orders_repository.dart';
import '../../domain/usecases/received_orders_usecase.dart';
import '../controllers/received_orders_controller.dart';

final receivedOrdersRemoteDataSourceProvider =
    Provider<ReceivedOrdersRemoteDataSource>((ref) {
      return ReceivedOrdersRemoteDataSourceImpl(
        ref.watch(generatedApiClientProvider),
      );
    });

final receivedOrdersRepositoryProvider = Provider<ReceivedOrdersRepository>((
  ref,
) {
  return ReceivedOrdersRepositoryImpl(
    ref.watch(receivedOrdersRemoteDataSourceProvider),
  );
});

final receivedOrdersUseCaseProvider = Provider<ReceivedOrdersUseCase>((ref) {
  return ReceivedOrdersUseCase(ref.watch(receivedOrdersRepositoryProvider));
});

final receivedOrdersControllerProvider =
    ChangeNotifierProvider.family<ReceivedOrdersController, String>((
      ref,
      businessId,
    ) {
      return ReceivedOrdersController(
        businessId,
        ref.watch(receivedOrdersUseCaseProvider),
      );
    });
