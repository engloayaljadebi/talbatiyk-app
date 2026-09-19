//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/order_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'order_store201_response.g.dart';

/// OrderStore201Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class OrderStore201Response implements Built<OrderStore201Response, OrderStore201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  OrderResource get data;

  OrderStore201Response._();

  factory OrderStore201Response([void updates(OrderStore201ResponseBuilder b)]) = _$OrderStore201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OrderStore201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OrderStore201Response> get serializer => _$OrderStore201ResponseSerializer();
}

class _$OrderStore201ResponseSerializer implements PrimitiveSerializer<OrderStore201Response> {
  @override
  final Iterable<Type> types = const [OrderStore201Response, _$OrderStore201Response];

  @override
  final String wireName = r'OrderStore201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OrderStore201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(OrderResource),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    OrderStore201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required OrderStore201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(OrderResource),
          ) as OrderResource;
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
  OrderStore201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OrderStore201ResponseBuilder();
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

