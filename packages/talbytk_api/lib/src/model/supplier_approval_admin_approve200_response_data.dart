//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_approval_admin_approve200_response_data.g.dart';

/// SupplierApprovalAdminApprove200ResponseData
///
/// Properties:
/// * [id] 
/// * [businessId] 
/// * [status] 
/// * [reviewedByUserId] 
/// * [reviewedAt] 
/// * [reviewNote] 
@BuiltValue()
abstract class SupplierApprovalAdminApprove200ResponseData implements Built<SupplierApprovalAdminApprove200ResponseData, SupplierApprovalAdminApprove200ResponseDataBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'business_id')
  String? get businessId;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'reviewed_by_user_id')
  String? get reviewedByUserId;

  @BuiltValueField(wireName: r'reviewed_at')
  String? get reviewedAt;

  @BuiltValueField(wireName: r'review_note')
  String? get reviewNote;

  SupplierApprovalAdminApprove200ResponseData._();

  factory SupplierApprovalAdminApprove200ResponseData([void updates(SupplierApprovalAdminApprove200ResponseDataBuilder b)]) = _$SupplierApprovalAdminApprove200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierApprovalAdminApprove200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierApprovalAdminApprove200ResponseData> get serializer => _$SupplierApprovalAdminApprove200ResponseDataSerializer();
}

class _$SupplierApprovalAdminApprove200ResponseDataSerializer implements PrimitiveSerializer<SupplierApprovalAdminApprove200ResponseData> {
  @override
  final Iterable<Type> types = const [SupplierApprovalAdminApprove200ResponseData, _$SupplierApprovalAdminApprove200ResponseData];

  @override
  final String wireName = r'SupplierApprovalAdminApprove200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierApprovalAdminApprove200ResponseData object, {
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
    yield r'reviewed_by_user_id';
    yield object.reviewedByUserId == null ? null : serializers.serialize(
      object.reviewedByUserId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'reviewed_at';
    yield object.reviewedAt == null ? null : serializers.serialize(
      object.reviewedAt,
      specifiedType: const FullType.nullable(String),
    );
    yield r'review_note';
    yield object.reviewNote == null ? null : serializers.serialize(
      object.reviewNote,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierApprovalAdminApprove200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierApprovalAdminApprove200ResponseDataBuilder result,
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
        case r'reviewed_by_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reviewedByUserId = valueDes;
          break;
        case r'reviewed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reviewedAt = valueDes;
          break;
        case r'review_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reviewNote = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierApprovalAdminApprove200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierApprovalAdminApprove200ResponseDataBuilder();
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

