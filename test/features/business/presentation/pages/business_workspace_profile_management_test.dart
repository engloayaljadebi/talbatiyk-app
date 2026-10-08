import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/business/domain/entities/business_entity.dart';
import 'package:talbatiyk/features/business/presentation/pages/business_profile_edit_page.dart';
import 'package:talbatiyk/features/business/presentation/pages/business_workspace_page.dart';

void main() {
  testWidgets('business workspace exposes profile management entry', (
    tester,
  ) async {
    const business = BusinessEntity(
      id: 'business-1',
      name: 'متجر طلبيتك',
      legalName: 'شركة طلبيتك',
      description: 'وصف النشاط',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BusinessWorkspacePage(businesses: <BusinessEntity>[business]),
        ),
      ),
    );

    final entry = find.byKey(
      const ValueKey<String>('manage-business-profile-business-1'),
    );

    expect(entry, findsOneWidget);

    await tester.tap(entry);
    await tester.pumpAndSettle();

    expect(find.byType(BusinessProfileEditPage), findsOneWidget);
  });
}
