//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/product_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_store201_response.g.dart';

/// ProductStore201Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class ProductStore201Response implements Built<ProductStore201Response, ProductStore201ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  ProductResource get data;

  ProductStore201Response._();

  factory ProductStore201Response([void updates(ProductStore201ResponseBuilder b)]) = _$ProductStore201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductStore201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductStore201Response> get serializer => _$ProductStore201ResponseSerializer();
}

class _$ProductStore201ResponseSerializer implements PrimitiveSerializer<ProductStore201Response> {
  @override
  final Iterable<Type> types = const [ProductStore201Response, _$ProductStore201Response];

  @override
  final String wireName = r'ProductStore201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductStore201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(ProductResource),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductStore201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProductStore201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProductResource),
          ) as ProductResource;
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
  ProductStore201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductStore201ResponseBuilder();
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

