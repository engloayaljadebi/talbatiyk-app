//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_index200_response_meta_links_inner.g.dart';

/// ProductIndex200ResponseMetaLinksInner
///
/// Properties:
/// * [url] 
/// * [label] 
/// * [active] 
@BuiltValue()
abstract class ProductIndex200ResponseMetaLinksInner implements Built<ProductIndex200ResponseMetaLinksInner, ProductIndex200ResponseMetaLinksInnerBuilder> {
  @BuiltValueField(wireName: r'url')
  String? get url;

  @BuiltValueField(wireName: r'label')
  String get label;

  @BuiltValueField(wireName: r'active')
  bool get active;

  ProductIndex200ResponseMetaLinksInner._();

  factory ProductIndex200ResponseMetaLinksInner([void updates(ProductIndex200ResponseMetaLinksInnerBuilder b)]) = _$ProductIndex200ResponseMetaLinksInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductIndex200ResponseMetaLinksInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductIndex200ResponseMetaLinksInner> get serializer => _$ProductIndex200ResponseMetaLinksInnerSerializer();
}

class _$ProductIndex200ResponseMetaLinksInnerSerializer implements PrimitiveSerializer<ProductIndex200ResponseMetaLinksInner> {
  @override
  final Iterable<Type> types = const [ProductIndex200ResponseMetaLinksInner, _$ProductIndex200ResponseMetaLinksInner];

  @override
  final String wireName = r'ProductIndex200ResponseMetaLinksInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductIndex200ResponseMetaLinksInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
    yield object.url == null ? null : serializers.serialize(
      object.url,
      specifiedType: const FullType.nullable(String),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    yield r'active';
    yield serializers.serialize(
      object.active,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductIndex200ResponseMetaLinksInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProductIndex200ResponseMetaLinksInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.url = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'active':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.active = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductIndex200ResponseMetaLinksInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductIndex200ResponseMetaLinksInnerBuilder();
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

