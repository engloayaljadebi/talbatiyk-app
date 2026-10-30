import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/data/datasources/remote/auth_remote_datasource.dart'
    as approval_data;
import '../../../auth/presentation/providers/auth_providers.dart';

/// Review state is separate from the user login status and business.status.
final class AccountBusinessApproval {
  const AccountBusinessApproval({
    required this.businessId,
    required this.shopStatus,
    required this.supplierStatus,
    required this.supplierEnabled,
  });

  final String businessId;
  final String? shopStatus;
  final String? supplierStatus;
  final bool supplierEnabled;

  bool get requestedSupplier => supplierStatus != null;
  bool get requestedShop => shopStatus != null;

  /// The backend remains the final authority for protected capabilities.
  bool get mayUseSupplierTools =>
      supplierStatus == 'approved' && supplierEnabled;

  String get reviewDescription {
    final entries = <String>[];
    if (shopStatus != null) {
      entries.add('العميل: ${_label(shopStatus!)}');
    }
    if (supplierStatus != null) {
      entries.add('المورد: ${_label(supplierStatus!)}');
    }
    return entries.isEmpty ? 'لا يوجد طلب اعتماد مسجل' : entries.join(' — ');
  }

  static String _label(String status) => switch (status) {
    'pending' => 'قيد المراجعة',
    'approved' => 'تمت الموافقة',
    'rejected' => 'مرفوض',
    'revoked' => 'تم إلغاء الاعتماد',
    'expired' => 'منتهي الصلاحية',
    _ => 'حالة غير معروفة',
  };
}

/// Keyed by user ID and disposed when the profile no longer watches it.
final accountBusinessApprovalsProvider = FutureProvider.autoDispose
    .family<Map<String, AccountBusinessApproval>, String>((ref, userId) async {
      if (ref.read(authProvider).state.user?.id != userId) {
        throw StateError('Authentication changed before approval request.');
      }

      final api = ref.read(generatedApiClientProvider);

      final approvals = await approval_data.fetchBusinessApprovals(api);

      if (ref.read(authProvider).state.user?.id != userId) {
        throw StateError('Authentication changed during approval request.');
      }

      final items = <String, AccountBusinessApproval>{};

      for (final approval in approvals) {
        if (approval.businessId.isEmpty) {
          throw const FormatException('Invalid business approval entry.');
        }

        items[approval.businessId] = AccountBusinessApproval(
          businessId: approval.businessId,
          shopStatus: approval.shopStatus,
          supplierStatus: approval.supplierStatus,
          supplierEnabled: approval.supplierEnabled,
        );
      }

      return Map<String, AccountBusinessApproval>.unmodifiable(items);
    });
