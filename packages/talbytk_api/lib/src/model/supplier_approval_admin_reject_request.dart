//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_approval_admin_reject_request.g.dart';

/// SupplierApprovalAdminRejectRequest
///
/// Properties:
/// * [reviewNote] 
@BuiltValue()
abstract class SupplierApprovalAdminRejectRequest implements Built<SupplierApprovalAdminRejectRequest, SupplierApprovalAdminRejectRequestBuilder> {
  @BuiltValueField(wireName: r'review_note')
  String get reviewNote;

  SupplierApprovalAdminRejectRequest._();

  factory SupplierApprovalAdminRejectRequest([void updates(SupplierApprovalAdminRejectRequestBuilder b)]) = _$SupplierApprovalAdminRejectRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierApprovalAdminRejectRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierApprovalAdminRejectRequest> get serializer => _$SupplierApprovalAdminRejectRequestSerializer();
}

class _$SupplierApprovalAdminRejectRequestSerializer implements PrimitiveSerializer<SupplierApprovalAdminRejectRequest> {
  @override
  final Iterable<Type> types = const [SupplierApprovalAdminRejectRequest, _$SupplierApprovalAdminRejectRequest];

  @override
  final String wireName = r'SupplierApprovalAdminRejectRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierApprovalAdminRejectRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'review_note';
    yield serializers.serialize(
      object.reviewNote,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierApprovalAdminRejectRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierApprovalAdminRejectRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'review_note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  SupplierApprovalAdminRejectRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierApprovalAdminRejectRequestBuilder();
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

