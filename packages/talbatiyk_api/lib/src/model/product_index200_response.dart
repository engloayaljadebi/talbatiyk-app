//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/product_index200_response_links.dart';
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/product_resource.dart';
import 'package:talbatiyk_api/src/model/product_index200_response_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_index200_response.g.dart';

/// ProductIndex200Response
///
/// Properties:
/// * [data] 
/// * [links] 
/// * [meta] 
@BuiltValue()
abstract class ProductIndex200Response implements Built<ProductIndex200Response, ProductIndex200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<ProductResource> get data;

  @BuiltValueField(wireName: r'links')
  ProductIndex200ResponseLinks get links;

  @BuiltValueField(wireName: r'meta')
  ProductIndex200ResponseMeta get meta;

  ProductIndex200Response._();

  factory ProductIndex200Response([void updates(ProductIndex200ResponseBuilder b)]) = _$ProductIndex200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductIndex200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductIndex200Response> get serializer => _$ProductIndex200ResponseSerializer();
}

class _$ProductIndex200ResponseSerializer implements PrimitiveSerializer<ProductIndex200Response> {
  @override
  final Iterable<Type> types = const [ProductIndex200Response, _$ProductIndex200Response];

  @override
  final String wireName = r'ProductIndex200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(ProductResource)]),
    );
    yield r'links';
    yield serializers.serialize(
      object.links,
      specifiedType: const FullType(ProductIndex200ResponseLinks),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(ProductIndex200ResponseMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProductIndex200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ProductResource)]),
          ) as BuiltList<ProductResource>;
          result.data.replace(valueDes);
          break;
        case r'links':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProductIndex200ResponseLinks),
          ) as ProductIndex200ResponseLinks;
          result.links.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProductIndex200ResponseMeta),
          ) as ProductIndex200ResponseMeta;
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
  ProductIndex200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductIndex200ResponseBuilder();
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

