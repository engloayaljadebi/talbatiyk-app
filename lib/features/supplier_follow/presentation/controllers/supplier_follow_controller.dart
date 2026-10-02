import 'package:flutter/foundation.dart';

import '../../domain/usecases/supplier_follow_usecase.dart';

final class SupplierFollowController extends ChangeNotifier {
  SupplierFollowController(
    this._useCase,
    this.businessId, {
    bool autoLoad = true,
  }) {
    if (autoLoad) {
      loadStatus();
    }
  }

  final SupplierFollowUseCase _useCase;
  final String businessId;

  bool _isLoading = false;
  bool _isUpdating = false;
  Future<void>? _statusLoad;
  bool? _isFollowing;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  bool get isUpdating => _isUpdating;

  bool? get isFollowing => _isFollowing;

  String? get errorMessage => _errorMessage;

  bool get canToggle => !_isLoading && !_isUpdating && _isFollowing != null;

  Future<void> loadStatus() {
    // Share the in-flight request with cart actions instead of dropping a tap.
    final pending = _statusLoad;
    if (pending != null) return pending;
    if (_isUpdating) return Future<void>.value();

    final request = _fetchStatus();
    _statusLoad = request;
    request.whenComplete(() {
      if (identical(_statusLoad, request)) _statusLoad = null;
    });
    return request;
  }

  Future<void> _fetchStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _isFollowing = await _useCase.isFollowing(businessId);
    } catch (_) {
      _errorMessage = 'تعذر تحميل حالة متابعة المورد.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggle() async {
    final currentStatus = _isFollowing;

    if (currentStatus == null || _isLoading || _isUpdating) {
      return currentStatus ?? false;
    }

    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _isFollowing = currentStatus
          ? await _useCase.unfollow(businessId)
          : await _useCase.follow(businessId);

      return _isFollowing!;
    } catch (_) {
      _errorMessage = currentStatus
          ? 'تعذر إلغاء متابعة المورد.'
          : 'تعذر متابعة المورد.';

      return currentStatus;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;
    notifyListeners();
  }
}
