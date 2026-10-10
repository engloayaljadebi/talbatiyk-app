import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('both order surfaces keep item rows horizontal and theme-driven', () {
    final sentSource = File(
      'lib/features/orders/presentation/pages/orders_page.dart',
    ).readAsStringSync();
    final receivedSource = File(
      'lib/features/received_orders/presentation/pages/received_orders_page.dart',
    ).readAsStringSync();
    final detailsSource = File(
      'lib/features/orders/presentation/pages/order_details_page.dart',
    ).readAsStringSync();

    expect(sentSource, contains('sent-order-items-horizontal'));
    expect(receivedSource, contains('received-order-items-horizontal'));
    expect(detailsSource, contains('sent-order-details-items-horizontal'));

    for (final source in [sentSource, receivedSource, detailsSource]) {
      expect(source, contains('scrollDirection: Axis.horizontal'));
      expect(source, contains('colors.primary'));
    }

    final sentCard = sentSource
        .split('class _OrderCard extends StatelessWidget {')
        .last
        .split('class _OrderTopSection extends StatelessWidget {')
        .first;
    final receivedCard = receivedSource
        .split('final class _ReceivedOrderCard extends StatelessWidget {')
        .last
        .split('final class _OrderHeader extends StatelessWidget {')
        .first;

    // Surfaces must never be outlined; received order also has no divider lines.
    expect(sentCard, isNot(contains('Border.all(')));
    expect(receivedCard, isNot(contains('Border.all(')));
    expect(sentCard, contains('color: colors.surface'));
    expect(sentCard, contains('shadowColor: colors.shadow'));
    expect(receivedCard, isNot(contains('boxShadow: [')));
    expect(receivedCard, isNot(contains('Divider(')));

    final receivedItems = receivedSource
        .split('final class _OrderItemsSection extends StatelessWidget {')
        .last
        .split('final class _OrderNotes extends StatelessWidget {')
        .first;
    expect(receivedItems, contains('Image.network('));
    expect(receivedItems, contains('item.imageUrl'));
    expect(receivedItems, contains('item.productName'));
    expect(receivedItems, contains('item.requestedQuantity'));
    expect(receivedItems, contains('item.unitPrice'));
    expect(receivedItems, contains('responseItem.offeredUnitPrice'));
    expect(receivedItems, isNot(contains('Border.all(')));
    expect(receivedItems, isNot(contains('Divider(')));

    expect(sentSource, contains('OrderDetailsPage(order: order)'));
    expect(sentSource, contains('embedded: true'));
    expect(receivedSource, contains('onRespond: order.hasResponse'));
    expect(receivedSource, contains('onAdvanceFulfillment:'));
  });
}
