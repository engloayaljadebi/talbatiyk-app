//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/supplier_approval_admin_approve200_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_approval_admin_approve200_response.g.dart';

/// SupplierApprovalAdminApprove200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class SupplierApprovalAdminApprove200Response implements Built<SupplierApprovalAdminApprove200Response, SupplierApprovalAdminApprove200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  SupplierApprovalAdminApprove200ResponseData get data;

  SupplierApprovalAdminApprove200Response._();

  factory SupplierApprovalAdminApprove200Response([void updates(SupplierApprovalAdminApprove200ResponseBuilder b)]) = _$SupplierApprovalAdminApprove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierApprovalAdminApprove200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierApprovalAdminApprove200Response> get serializer => _$SupplierApprovalAdminApprove200ResponseSerializer();
}

class _$SupplierApprovalAdminApprove200ResponseSerializer implements PrimitiveSerializer<SupplierApprovalAdminApprove200Response> {
  @override
  final Iterable<Type> types = const [SupplierApprovalAdminApprove200Response, _$SupplierApprovalAdminApprove200Response];

  @override
  final String wireName = r'SupplierApprovalAdminApprove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierApprovalAdminApprove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(SupplierApprovalAdminApprove200ResponseData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierApprovalAdminApprove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierApprovalAdminApprove200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SupplierApprovalAdminApprove200ResponseData),
          ) as SupplierApprovalAdminApprove200ResponseData;
          result.data.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierApprovalAdminApprove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierApprovalAdminApprove200ResponseBuilder();
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

