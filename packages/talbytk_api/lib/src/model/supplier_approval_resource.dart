//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_approval_resource.g.dart';

/// SupplierApprovalResource
///
/// Properties:
/// * [id] 
/// * [status] 
/// * [requestedAt] 
/// * [reviewedAt] 
/// * [rejectionReason] 
@BuiltValue()
abstract class SupplierApprovalResource implements Built<SupplierApprovalResource, SupplierApprovalResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'requested_at')
  String? get requestedAt;

  @BuiltValueField(wireName: r'reviewed_at')
  String? get reviewedAt;

  @BuiltValueField(wireName: r'rejection_reason')
  String? get rejectionReason;

  SupplierApprovalResource._();

  factory SupplierApprovalResource([void updates(SupplierApprovalResourceBuilder b)]) = _$SupplierApprovalResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierApprovalResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierApprovalResource> get serializer => _$SupplierApprovalResourceSerializer();
}

class _$SupplierApprovalResourceSerializer implements PrimitiveSerializer<SupplierApprovalResource> {
  @override
  final Iterable<Type> types = const [SupplierApprovalResource, _$SupplierApprovalResource];

  @override
  final String wireName = r'SupplierApprovalResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierApprovalResource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'requested_at';
    yield object.requestedAt == null ? null : serializers.serialize(
      object.requestedAt,
      specifiedType: const FullType.nullable(String),
    );
    yield r'reviewed_at';
    yield object.reviewedAt == null ? null : serializers.serialize(
      object.reviewedAt,
      specifiedType: const FullType.nullable(String),
    );
    yield r'rejection_reason';
    yield object.rejectionReason == null ? null : serializers.serialize(
      object.rejectionReason,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierApprovalResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierApprovalResourceBuilder result,
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.requestedAt = valueDes;
          break;
        case r'reviewed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reviewedAt = valueDes;
          break;
        case r'rejection_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.rejectionReason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierApprovalResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierApprovalResourceBuilder();
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

