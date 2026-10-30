//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/auth_business_approvals200_response_data_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_business_approvals200_response.g.dart';

/// AuthBusinessApprovals200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class AuthBusinessApprovals200Response implements Built<AuthBusinessApprovals200Response, AuthBusinessApprovals200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<AuthBusinessApprovals200ResponseDataInner> get data;

  AuthBusinessApprovals200Response._();

  factory AuthBusinessApprovals200Response([void updates(AuthBusinessApprovals200ResponseBuilder b)]) = _$AuthBusinessApprovals200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthBusinessApprovals200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthBusinessApprovals200Response> get serializer => _$AuthBusinessApprovals200ResponseSerializer();
}

class _$AuthBusinessApprovals200ResponseSerializer implements PrimitiveSerializer<AuthBusinessApprovals200Response> {
  @override
  final Iterable<Type> types = const [AuthBusinessApprovals200Response, _$AuthBusinessApprovals200Response];

  @override
  final String wireName = r'AuthBusinessApprovals200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthBusinessApprovals200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(AuthBusinessApprovals200ResponseDataInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthBusinessApprovals200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthBusinessApprovals200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AuthBusinessApprovals200ResponseDataInner)]),
          ) as BuiltList<AuthBusinessApprovals200ResponseDataInner>;
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
  AuthBusinessApprovals200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthBusinessApprovals200ResponseBuilder();
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

