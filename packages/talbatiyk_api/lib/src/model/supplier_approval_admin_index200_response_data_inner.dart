//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/supplier_approval_admin_index200_response_data_inner_business.dart';
import 'package:talbatiyk_api/src/model/supplier_approval_admin_index200_response_data_inner_requested_by.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_approval_admin_index200_response_data_inner.g.dart';

/// SupplierApprovalAdminIndex200ResponseDataInner
///
/// Properties:
/// * [id] 
/// * [businessId] 
/// * [status] 
/// * [requestedAt] 
/// * [business] 
/// * [requestedBy] 
@BuiltValue()
abstract class SupplierApprovalAdminIndex200ResponseDataInner implements Built<SupplierApprovalAdminIndex200ResponseDataInner, SupplierApprovalAdminIndex200ResponseDataInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'business_id')
  String? get businessId;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'requested_at')
  String get requestedAt;

  @BuiltValueField(wireName: r'business')
  SupplierApprovalAdminIndex200ResponseDataInnerBusiness get business;

  @BuiltValueField(wireName: r'requested_by')
  SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy get requestedBy;

  SupplierApprovalAdminIndex200ResponseDataInner._();

  factory SupplierApprovalAdminIndex200ResponseDataInner([void updates(SupplierApprovalAdminIndex200ResponseDataInnerBuilder b)]) = _$SupplierApprovalAdminIndex200ResponseDataInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierApprovalAdminIndex200ResponseDataInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierApprovalAdminIndex200ResponseDataInner> get serializer => _$SupplierApprovalAdminIndex200ResponseDataInnerSerializer();
}

class _$SupplierApprovalAdminIndex200ResponseDataInnerSerializer implements PrimitiveSerializer<SupplierApprovalAdminIndex200ResponseDataInner> {
  @override
  final Iterable<Type> types = const [SupplierApprovalAdminIndex200ResponseDataInner, _$SupplierApprovalAdminIndex200ResponseDataInner];

  @override
  final String wireName = r'SupplierApprovalAdminIndex200ResponseDataInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierApprovalAdminIndex200ResponseDataInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'business_id';
    yield object.businessId == null ? null : serializers.serialize(
      object.businessId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'requested_at';
    yield serializers.serialize(
      object.requestedAt,
      specifiedType: const FullType(String),
    );
    yield r'business';
    yield serializers.serialize(
      object.business,
      specifiedType: const FullType(SupplierApprovalAdminIndex200ResponseDataInnerBusiness),
    );
    yield r'requested_by';
    yield serializers.serialize(
      object.requestedBy,
      specifiedType: const FullType(SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierApprovalAdminIndex200ResponseDataInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierApprovalAdminIndex200ResponseDataInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'business_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.businessId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'requested_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestedAt = valueDes;
          break;
        case r'business':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SupplierApprovalAdminIndex200ResponseDataInnerBusiness),
          ) as SupplierApprovalAdminIndex200ResponseDataInnerBusiness;
          result.business.replace(valueDes);
          break;
        case r'requested_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy),
          ) as SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy;
          result.requestedBy.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierApprovalAdminIndex200ResponseDataInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierApprovalAdminIndex200ResponseDataInnerBuilder();
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

