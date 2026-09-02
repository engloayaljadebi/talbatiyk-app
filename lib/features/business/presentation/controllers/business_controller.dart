import 'package:flutter/foundation.dart';

import '../../domain/usecases/business_usecase.dart';
import '../state/business_state.dart';

final class BusinessController extends ChangeNotifier {
  BusinessController(this._useCase);

  final BusinessUseCase _useCase;

  BusinessState state = const BusinessState.initial();

  bool _disposed = false;

  Future<void> loadBusinesses() async {
    if (state.isLoading) {
      return;
    }

    _setState(const BusinessState.loading());

    try {
      final businesses = await _useCase.getAccessibleBusinesses();

      if (_disposed) {
        return;
      }

      _setState(BusinessState.loaded(businesses));
    } catch (error, stackTrace) {
      debugPrint('Business loading failed: $error\n$stackTrace');

      _setState(
        const BusinessState.failure(
          'تعذر تحميل الأنشطة التجارية. حاول مرة أخرى.',
        ),
      );
    }
  }

  void _setState(BusinessState value) {
    if (_disposed) {
      return;
    }

    state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
