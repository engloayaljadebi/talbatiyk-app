import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/navigation/presentation/widgets/home_bottom_navigation.dart';

void main() {
  Widget buildNavigation(int count) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: HomeBottomNavigation(
          currentIndex: 0,
          ordersBadgeCount: count,
          onDestinationSelected: (_) {},
        ),
      ),
    );
  }

  testWidgets('orders badge is hidden when action count is zero', (
    tester,
  ) async {
    await tester.pumpWidget(buildNavigation(0));

    expect(find.byKey(const ValueKey<String>('orders-badge')), findsNothing);
  });

  testWidgets('orders badge displays actionable count', (tester) async {
    await tester.pumpWidget(buildNavigation(7));

    expect(find.byKey(const ValueKey<String>('orders-badge')), findsOneWidget);

    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('orders badge caps display at 99 plus', (tester) async {
    await tester.pumpWidget(buildNavigation(120));

    expect(find.text('99+'), findsOneWidget);
  });
}
