//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/order_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_index200_response.g.dart';

/// OrderIndex200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class OrderIndex200Response implements Built<OrderIndex200Response, OrderIndex200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<OrderResource> get data;

  OrderIndex200Response._();

  factory OrderIndex200Response([void updates(OrderIndex200ResponseBuilder b)]) = _$OrderIndex200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderIndex200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderIndex200Response> get serializer => _$OrderIndex200ResponseSerializer();
}

class _$OrderIndex200ResponseSerializer implements PrimitiveSerializer<OrderIndex200Response> {
  @override
  final Iterable<Type> types = const [OrderIndex200Response, _$OrderIndex200Response];

  @override
  final String wireName = r'OrderIndex200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(OrderResource)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderIndex200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(OrderResource)]),
          ) as BuiltList<OrderResource>;
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
  OrderIndex200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderIndex200ResponseBuilder();
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

