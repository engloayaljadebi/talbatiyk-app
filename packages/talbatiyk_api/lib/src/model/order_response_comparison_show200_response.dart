//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/order_response_comparison_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_response_comparison_show200_response.g.dart';

/// OrderResponseComparisonShow200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class OrderResponseComparisonShow200Response implements Built<OrderResponseComparisonShow200Response, OrderResponseComparisonShow200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OrderResponseComparisonResource get data;

  OrderResponseComparisonShow200Response._();

  factory OrderResponseComparisonShow200Response([void updates(OrderResponseComparisonShow200ResponseBuilder b)]) = _$OrderResponseComparisonShow200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderResponseComparisonShow200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderResponseComparisonShow200Response> get serializer => _$OrderResponseComparisonShow200ResponseSerializer();
}

class _$OrderResponseComparisonShow200ResponseSerializer implements PrimitiveSerializer<OrderResponseComparisonShow200Response> {
  @override
  final Iterable<Type> types = const [OrderResponseComparisonShow200Response, _$OrderResponseComparisonShow200Response];

  @override
  final String wireName = r'OrderResponseComparisonShow200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderResponseComparisonShow200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OrderResponseComparisonResource),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderResponseComparisonShow200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderResponseComparisonShow200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OrderResponseComparisonResource),
          ) as OrderResponseComparisonResource;
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
  OrderResponseComparisonShow200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderResponseComparisonShow200ResponseBuilder();
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

