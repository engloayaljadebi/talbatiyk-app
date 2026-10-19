//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/supplier_approval_admin_index200_response_data_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/supplier_approval_admin_index200_response_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_approval_admin_index200_response.g.dart';

/// SupplierApprovalAdminIndex200Response
///
/// Properties:
/// * [data] 
/// * [meta] 
@BuiltValue()
abstract class SupplierApprovalAdminIndex200Response implements Built<SupplierApprovalAdminIndex200Response, SupplierApprovalAdminIndex200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<SupplierApprovalAdminIndex200ResponseDataInner> get data;

  @BuiltValueField(wireName: r'meta')
  SupplierApprovalAdminIndex200ResponseMeta get meta;

  SupplierApprovalAdminIndex200Response._();

  factory SupplierApprovalAdminIndex200Response([void updates(SupplierApprovalAdminIndex200ResponseBuilder b)]) = _$SupplierApprovalAdminIndex200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierApprovalAdminIndex200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierApprovalAdminIndex200Response> get serializer => _$SupplierApprovalAdminIndex200ResponseSerializer();
}

class _$SupplierApprovalAdminIndex200ResponseSerializer implements PrimitiveSerializer<SupplierApprovalAdminIndex200Response> {
  @override
  final Iterable<Type> types = const [SupplierApprovalAdminIndex200Response, _$SupplierApprovalAdminIndex200Response];

  @override
  final String wireName = r'SupplierApprovalAdminIndex200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierApprovalAdminIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(SupplierApprovalAdminIndex200ResponseDataInner)]),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(SupplierApprovalAdminIndex200ResponseMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierApprovalAdminIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierApprovalAdminIndex200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SupplierApprovalAdminIndex200ResponseDataInner)]),
          ) as BuiltList<SupplierApprovalAdminIndex200ResponseDataInner>;
          result.data.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SupplierApprovalAdminIndex200ResponseMeta),
          ) as SupplierApprovalAdminIndex200ResponseMeta;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierApprovalAdminIndex200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierApprovalAdminIndex200ResponseBuilder();
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

