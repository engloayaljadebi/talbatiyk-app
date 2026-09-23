import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/network/network_providers.dart';
import '../../data/datasources/local/notifications_local_datasource.dart';
import '../../data/datasources/remote/notifications_remote_datasource.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/usecases/notifications_usecase.dart';
import '../controllers/notifications_controller.dart';

final notificationsLocalDataSourceProvider =
    Provider<NotificationsLocalDatasource>((ref) {
      return NotificationsLocalDatasourceImpl(ref.watch(appDatabaseProvider));
    });

final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDatasource>((ref) {
      return NotificationsRemoteDatasourceImpl(
        ref.watch(generatedApiClientProvider),
      );
    });

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepositoryImpl(
    localDataSource: ref.watch(notificationsLocalDataSourceProvider),
    remoteDataSource: ref.watch(notificationsRemoteDataSourceProvider),
  );
});

final notificationsUseCaseProvider = Provider<NotificationsUseCase>((ref) {
  return NotificationsUseCase(ref.watch(notificationsRepositoryProvider));
});

final notificationsProvider = ChangeNotifierProvider.autoDispose
    .family<NotificationsController, String>((ref, userId) {
      return NotificationsController(
        ref.watch(notificationsUseCaseProvider),
        userId: userId,
        autoLoad: false,
      );
    });
