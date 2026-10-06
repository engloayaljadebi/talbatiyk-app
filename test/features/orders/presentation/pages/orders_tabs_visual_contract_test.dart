import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('orders tabs use unified project visual language', () {
    final source = File(
      'lib/features/orders/presentation/pages/orders_page.dart',
    ).readAsStringSync();

    expect(source, contains('orders-tabs-segment'));

    expect(source, contains('dividerColor: Colors.transparent'));

    expect(source, contains('indicatorSize: TabBarIndicatorSize.tab'));

    expect(source, contains('colors.primary.withValues(alpha: 0.10)'));

    expect(source, contains('colors.surfaceContainerLow'));

    expect(source, isNot(contains('bottom: const TabBar(')));
  });
}
