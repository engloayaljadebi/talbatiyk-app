import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/account/presentation/providers/account_business_approvals_provider.dart';

void main() {
  test(
    'pending supplier is shown as under review and cannot manage products',
    () {
      const review = AccountBusinessApproval(
        businessId: 'business-1',
        shopStatus: null,
        supplierStatus: 'pending',
        supplierEnabled: false,
      );

      expect(review.requestedSupplier, isTrue);
      expect(review.mayUseSupplierTools, isFalse);
      expect(review.reviewDescription, contains('قيد المراجعة'));
    },
  );

  test('approval alone is not enough without active supplier capability', () {
    const review = AccountBusinessApproval(
      businessId: 'business-1',
      shopStatus: null,
      supplierStatus: 'approved',
      supplierEnabled: false,
    );

    expect(review.mayUseSupplierTools, isFalse);
  });

  test('supplier tools require both approval and active capability', () {
    const review = AccountBusinessApproval(
      businessId: 'business-1',
      shopStatus: null,
      supplierStatus: 'approved',
      supplierEnabled: true,
    );

    expect(review.mayUseSupplierTools, isTrue);
    expect(review.reviewDescription, contains('تمت الموافقة'));
  });

  test('shop request is displayed as customer, not supplier', () {
    const review = AccountBusinessApproval(
      businessId: 'business-2',
      shopStatus: 'pending',
      supplierStatus: null,
      supplierEnabled: false,
    );

    expect(review.requestedShop, isTrue);
    expect(review.requestedSupplier, isFalse);
    expect(review.mayUseSupplierTools, isFalse);
    expect(review.reviewDescription, contains('العميل: قيد المراجعة'));
  });
}
