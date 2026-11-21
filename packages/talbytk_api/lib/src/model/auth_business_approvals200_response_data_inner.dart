//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_business_approvals200_response_data_inner.g.dart';

/// AuthBusinessApprovals200ResponseDataInner
///
/// Properties:
/// * [businessId] 
/// * [shopStatus] 
/// * [supplierStatus] 
/// * [supplierEnabled] 
@BuiltValue()
abstract class AuthBusinessApprovals200ResponseDataInner implements Built<AuthBusinessApprovals200ResponseDataInner, AuthBusinessApprovals200ResponseDataInnerBuilder> {
  @BuiltValueField(wireName: r'business_id')
  String get businessId;

  @BuiltValueField(wireName: r'shop_status')
  String? get shopStatus;

  @BuiltValueField(wireName: r'supplier_status')
  String? get supplierStatus;

  @BuiltValueField(wireName: r'supplier_enabled')
  bool get supplierEnabled;

  AuthBusinessApprovals200ResponseDataInner._();

  factory AuthBusinessApprovals200ResponseDataInner([void updates(AuthBusinessApprovals200ResponseDataInnerBuilder b)]) = _$AuthBusinessApprovals200ResponseDataInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthBusinessApprovals200ResponseDataInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthBusinessApprovals200ResponseDataInner> get serializer => _$AuthBusinessApprovals200ResponseDataInnerSerializer();
}

class _$AuthBusinessApprovals200ResponseDataInnerSerializer implements PrimitiveSerializer<AuthBusinessApprovals200ResponseDataInner> {
  @override
  final Iterable<Type> types = const [AuthBusinessApprovals200ResponseDataInner, _$AuthBusinessApprovals200ResponseDataInner];

  @override
  final String wireName = r'AuthBusinessApprovals200ResponseDataInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthBusinessApprovals200ResponseDataInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'business_id';
    yield serializers.serialize(
      object.businessId,
      specifiedType: const FullType(String),
    );
    yield r'shop_status';
    yield object.shopStatus == null ? null : serializers.serialize(
      object.shopStatus,
      specifiedType: const FullType.nullable(String),
    );
    yield r'supplier_status';
    yield object.supplierStatus == null ? null : serializers.serialize(
      object.supplierStatus,
      specifiedType: const FullType.nullable(String),
    );
    yield r'supplier_enabled';
    yield serializers.serialize(
      object.supplierEnabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthBusinessApprovals200ResponseDataInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthBusinessApprovals200ResponseDataInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'business_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.businessId = valueDes;
          break;
        case r'shop_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.shopStatus = valueDes;
          break;
        case r'supplier_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.supplierStatus = valueDes;
          break;
        case r'supplier_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.supplierEnabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthBusinessApprovals200ResponseDataInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthBusinessApprovals200ResponseDataInnerBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

