//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_approval_admin_approve_request.g.dart';

/// SupplierApprovalAdminApproveRequest
///
/// Properties:
/// * [reviewNote] 
@BuiltValue()
abstract class SupplierApprovalAdminApproveRequest implements Built<SupplierApprovalAdminApproveRequest, SupplierApprovalAdminApproveRequestBuilder> {
  @BuiltValueField(wireName: r'review_note')
  String? get reviewNote;

  SupplierApprovalAdminApproveRequest._();

  factory SupplierApprovalAdminApproveRequest([void updates(SupplierApprovalAdminApproveRequestBuilder b)]) = _$SupplierApprovalAdminApproveRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierApprovalAdminApproveRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierApprovalAdminApproveRequest> get serializer => _$SupplierApprovalAdminApproveRequestSerializer();
}

class _$SupplierApprovalAdminApproveRequestSerializer implements PrimitiveSerializer<SupplierApprovalAdminApproveRequest> {
  @override
  final Iterable<Type> types = const [SupplierApprovalAdminApproveRequest, _$SupplierApprovalAdminApproveRequest];

  @override
  final String wireName = r'SupplierApprovalAdminApproveRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierApprovalAdminApproveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.reviewNote != null) {
      yield r'review_note';
      yield serializers.serialize(
        object.reviewNote,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierApprovalAdminApproveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierApprovalAdminApproveRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  SupplierApprovalAdminApproveRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierApprovalAdminApproveRequestBuilder();
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

