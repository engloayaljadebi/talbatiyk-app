import 'package:flutter/foundation.dart';

import '../../domain/usecases/supplier_discovery_usecase.dart';
import '../state/supplier_discovery_state.dart';

final class SupplierDiscoveryController extends ChangeNotifier {
  SupplierDiscoveryController(this._useCase);

  final SupplierDiscoveryUseCase _useCase;

  SupplierDiscoveryState _state = const SupplierDiscoveryState();

  SupplierDiscoveryState get state => _state;

  Future<bool> loadSuppliers() async {
    if (_state.isLoading) {
      return false;
    }

    _state = const SupplierDiscoveryState(isLoading: true);
    notifyListeners();

    try {
      final suppliers = await _useCase.getSuppliers();

      _state = SupplierDiscoveryState(suppliers: suppliers);
      notifyListeners();

      return true;
    } catch (_) {
      _state = const SupplierDiscoveryState(
        errorMessage: 'تعذر تحميل الموردين المتاحين. حاول مرة أخرى.',
      );
      notifyListeners();

      return false;
    }
  }
}
