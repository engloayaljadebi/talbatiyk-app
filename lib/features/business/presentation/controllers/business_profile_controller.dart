import 'package:flutter/foundation.dart';

import '../../domain/entities/business_entity.dart';
import '../../domain/entities/business_profile_update.dart';
import '../../domain/usecases/update_business_profile_usecase.dart';
import '../state/business_profile_state.dart';

final class BusinessProfileController extends ChangeNotifier {
  BusinessProfileController(this._updateProfile, BusinessEntity initialBusiness)
    : state = BusinessProfileState(business: initialBusiness);

  final UpdateBusinessProfileUseCase _updateProfile;

  BusinessProfileState state;

  bool _disposed = false;

  Future<BusinessEntity?> save(BusinessProfileUpdate update) async {
    if (state.isSaving || update.isEmpty) {
      return null;
    }

    _setState(state.copyWith(isSaving: true, clearErrorMessage: true));

    try {
      final updated = await _updateProfile(
        businessId: state.business.id,
        update: update,
      );

      if (_disposed) {
        return null;
      }

      _setState(BusinessProfileState(business: updated));

      return updated;
    } catch (error, stackTrace) {
      debugPrint(
        'Business profile update failed: '
        '$error\n$stackTrace',
      );

      _setState(
        state.copyWith(
          isSaving: false,
          errorMessage:
              'تعذر حفظ بيانات النشاط. تحقق من الاتصال '
              'وحاول مرة أخرى.',
        ),
      );

      return null;
    }
  }

  void _setState(BusinessProfileState next) {
    if (_disposed) {
      return;
    }

    state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
