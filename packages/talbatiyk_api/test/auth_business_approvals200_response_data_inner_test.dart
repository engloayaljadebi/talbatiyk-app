import 'package:built_value/serializer.dart';
import 'package:test/test.dart';
import 'package:talbatiyk_api/src/model/auth_business_approvals200_response_data_inner.dart';
import 'package:talbatiyk_api/src/serializers.dart';

void main() {
  group('AuthBusinessApprovals200ResponseDataInner serialization', () {
    test('deserializes all API wire fields', () {
      final decoded = standardSerializers.deserialize(
        <String, Object?>{
          'business_id': 'business-1',
          'shop_status': 'approved',
          'supplier_status': 'pending',
          'supplier_enabled': true,
        },
        specifiedType:
            const FullType(AuthBusinessApprovals200ResponseDataInner),
      ) as AuthBusinessApprovals200ResponseDataInner;

      expect(decoded.businessId, 'business-1');
      expect(decoded.shopStatus, 'approved');
      expect(decoded.supplierStatus, 'pending');
      expect(decoded.supplierEnabled, isTrue);
    });

    test('serializes using the exact API field names', () {
      final model = AuthBusinessApprovals200ResponseDataInner(
        (b) => b
          ..businessId = 'business-2'
          ..shopStatus = 'pending'
          ..supplierStatus = null
          ..supplierEnabled = false,
      );

      final encoded = standardSerializers.serialize(
        model,
        specifiedType:
            const FullType(AuthBusinessApprovals200ResponseDataInner),
      ) as Map<String, Object?>;

      expect(encoded['business_id'], 'business-2');
      expect(encoded['shop_status'], 'pending');
      expect(encoded['supplier_status'], isNull);
      expect(encoded['supplier_enabled'], isFalse);
    });

    test('accepts null review statuses', () {
      final decoded = standardSerializers.deserialize(
        <String, Object?>{
          'business_id': 'business-3',
          'shop_status': null,
          'supplier_status': null,
          'supplier_enabled': false,
        },
        specifiedType:
            const FullType(AuthBusinessApprovals200ResponseDataInner),
      ) as AuthBusinessApprovals200ResponseDataInner;

      expect(decoded.shopStatus, isNull);
      expect(decoded.supplierStatus, isNull);
    });
  });
}
