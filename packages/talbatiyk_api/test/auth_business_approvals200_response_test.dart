import 'package:built_value/serializer.dart';
import 'package:test/test.dart';
import 'package:talbatiyk_api/src/model/auth_business_approvals200_response.dart';
import 'package:talbatiyk_api/src/serializers.dart';

void main() {
  group('AuthBusinessApprovals200Response serialization', () {
    test('deserializes the business approvals response', () {
      final decoded = standardSerializers.deserialize(
        <String, Object?>{
          'data': <Object?>[
            <String, Object?>{
              'business_id': 'business-1',
              'shop_status': null,
              'supplier_status': 'pending',
              'supplier_enabled': false,
            },
          ],
        },
        specifiedType: const FullType(AuthBusinessApprovals200Response),
      ) as AuthBusinessApprovals200Response;

      expect(decoded.data, hasLength(1));
      expect(decoded.data.single.businessId, 'business-1');
      expect(decoded.data.single.shopStatus, isNull);
      expect(decoded.data.single.supplierStatus, 'pending');
      expect(decoded.data.single.supplierEnabled, isFalse);
    });

    test('supports an empty approvals collection', () {
      final decoded = standardSerializers.deserialize(
        <String, Object?>{'data': <Object?>[]},
        specifiedType: const FullType(AuthBusinessApprovals200Response),
      ) as AuthBusinessApprovals200Response;

      expect(decoded.data, isEmpty);
    });
  });
}
