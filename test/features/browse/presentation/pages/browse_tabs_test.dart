import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/browse/presentation/pages/browse_page.dart';
import 'package:talbatiyk/features/navigation/presentation/widgets/home_bottom_navigation.dart';

void main() {
  testWidgets('browse has products and stores tabs with working selection', (
    tester,
  ) async {
    int selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, update) => Scaffold(
            body: BrowseTabs(
              selectedIndex: selected,
              onSelected: (index) => update(() => selected = index),
            ),
          ),
        ),
      ),
    );

    expect(find.text('المنتجات'), findsOneWidget);
    expect(find.text('المتاجر'), findsOneWidget);
    await tester.tap(find.text('المتاجر'));
    await tester.pump();
    expect(selected, 1);
  });

  testWidgets('bottom navigation keeps five destinations and renames browse', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: HomeBottomNavigation(
            currentIndex: 1,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('تصفح'), findsOneWidget);
    expect(find.text('المنتجات'), findsNothing);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('السلة'), findsOneWidget);
    expect(find.text('الطلبات'), findsOneWidget);
    expect(find.text('الحساب'), findsOneWidget);
  });
}
