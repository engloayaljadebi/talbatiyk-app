import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unified orders center source contract', () {
    final ordersSource = File(
      'lib/features/orders/presentation/pages/orders_page.dart',
    ).readAsStringSync();

    final receivedSource = File(
      'lib/features/received_orders/presentation/pages/received_orders_page.dart',
    ).readAsStringSync();

    final accountSource = File(
      'lib/features/account/presentation/pages/account_page.dart',
    ).readAsStringSync();

    final workspaceSource = File(
      'lib/features/business/presentation/pages/business_workspace_page.dart',
    ).readAsStringSync();

    expect(ordersSource, contains('orders-sent-tab'));

    expect(ordersSource, contains('orders-received-tab'));

    expect(ordersSource, contains("'طلباتي'"));

    expect(ordersSource, contains("'المستلمة'"));

    expect(ordersSource, contains('ReceivedOrdersPage('));

    expect(ordersSource, contains('embedded: true'));

    expect(ordersSource, contains('received-orders-business-selector'));

    expect(receivedSource, contains('final bool embedded;'));

    expect(receivedSource, contains('if (embedded)'));

    expect(accountSource, contains('receivedOrdersControllerProvider(selectedBusiness.id)'));

    expect(accountSource, contains('class _OrdersTab'));

    expect(accountSource, contains("'المنتجات'"));

    expect(accountSource, contains("'العرض'"));

    expect(workspaceSource, isNot(contains('ReceivedOrdersPage')));

    expect(workspaceSource, isNot(contains('الطلبات المستلمة')));
  });
}
