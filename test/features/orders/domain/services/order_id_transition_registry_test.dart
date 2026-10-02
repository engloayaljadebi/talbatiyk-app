import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/orders/domain/services/order_id_transition_registry.dart';

void main() {
  group('OrderIdTransitionRegistry', () {
    late OrderIdTransitionRegistry registry;

    setUp(() {
      registry = OrderIdTransitionRegistry();
    });

    test('unknown ID resolves to itself', () {
      expect(registry.resolve('unknown-order-id'), 'unknown-order-id');
      expect(
        registry.resolve('local-order-not-registered'),
        'local-order-not-registered',
      );
    });

    test('registered local ID resolves to server UUID', () {
      const localId = 'local-order-1727829102000';
      const serverId = '550e8400-e29b-41d4-a716-446655440000';

      registry.registerTransition(
        localOrderId: localId,
        serverOrderId: serverId,
      );

      expect(registry.resolve(localId), serverId);
    });

    test('server UUID resolves to itself', () {
      const serverId = '550e8400-e29b-41d4-a716-446655440000';

      expect(registry.resolve(serverId), serverId);

      // Even if another transition exists
      registry.registerTransition(
        localOrderId: 'local-order-1',
        serverOrderId: serverId,
      );
      expect(registry.resolve(serverId), serverId);
    });

    group('whitespace and invalid input handling', () {
      test(
        'trims surrounding whitespace during resolution and registration',
        () {
          const localId = 'local-order-999';
          const serverId = '550e8400-e29b-41d4-a716-446655440001';

          registry.registerTransition(
            localOrderId: '  $localId  ',
            serverOrderId: '  $serverId  ',
          );

          expect(registry.resolve(localId), serverId);
          expect(registry.resolve('  $localId  '), serverId);
        },
      );

      test(
        'empty or whitespace-only inputs resolve to original input without registering',
        () {
          expect(registry.resolve(''), '');
          expect(registry.resolve('   '), '   ');

          // Attempting to register empty/whitespace IDs is ignored safely
          registry.registerTransition(
            localOrderId: '',
            serverOrderId: '550e8400-e29b-41d4-a716-446655440002',
          );
          registry.registerTransition(
            localOrderId: '   ',
            serverOrderId: '550e8400-e29b-41d4-a716-446655440002',
          );
          registry.registerTransition(
            localOrderId: 'local-order-3',
            serverOrderId: '',
          );
          registry.registerTransition(
            localOrderId: 'local-order-4',
            serverOrderId: '   ',
          );

          expect(registry.resolve('local-order-3'), 'local-order-3');
          expect(registry.resolve('local-order-4'), 'local-order-4');
        },
      );
    });

    test('clear removes all registered transitions', () {
      registry.registerTransition(
        localOrderId: 'local-order-1',
        serverOrderId: 'server-uuid-1',
      );
      expect(registry.resolve('local-order-1'), 'server-uuid-1');

      registry.clear();

      expect(registry.resolve('local-order-1'), 'local-order-1');
    });
  });
}
