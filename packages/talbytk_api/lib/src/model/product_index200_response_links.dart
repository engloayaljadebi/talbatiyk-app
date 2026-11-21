//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_index200_response_links.g.dart';

/// ProductIndex200ResponseLinks
///
/// Properties:
/// * [first] 
/// * [last] 
/// * [prev] 
/// * [next] 
@BuiltValue()
abstract class ProductIndex200ResponseLinks implements Built<ProductIndex200ResponseLinks, ProductIndex200ResponseLinksBuilder> {
  @BuiltValueField(wireName: r'first')
  String? get first;

  @BuiltValueField(wireName: r'last')
  String? get last;

  @BuiltValueField(wireName: r'prev')
  String? get prev;

  @BuiltValueField(wireName: r'next')
  String? get next;

  ProductIndex200ResponseLinks._();

  factory ProductIndex200ResponseLinks([void updates(ProductIndex200ResponseLinksBuilder b)]) = _$ProductIndex200ResponseLinks;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductIndex200ResponseLinksBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductIndex200ResponseLinks> get serializer => _$ProductIndex200ResponseLinksSerializer();
}

class _$ProductIndex200ResponseLinksSerializer implements PrimitiveSerializer<ProductIndex200ResponseLinks> {
  @override
  final Iterable<Type> types = const [ProductIndex200ResponseLinks, _$ProductIndex200ResponseLinks];

  @override
  final String wireName = r'ProductIndex200ResponseLinks';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductIndex200ResponseLinks object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'first';
    yield object.first == null ? null : serializers.serialize(
      object.first,
      specifiedType: const FullType.nullable(String),
    );
    yield r'last';
    yield object.last == null ? null : serializers.serialize(
      object.last,
      specifiedType: const FullType.nullable(String),
    );
    yield r'prev';
    yield object.prev == null ? null : serializers.serialize(
      object.prev,
      specifiedType: const FullType.nullable(String),
    );
    yield r'next';
    yield object.next == null ? null : serializers.serialize(
      object.next,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductIndex200ResponseLinks object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProductIndex200ResponseLinksBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'first':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.first = valueDes;
          break;
        case r'last':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.last = valueDes;
          break;
        case r'prev':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.prev = valueDes;
          break;
        case r'next':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.next = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductIndex200ResponseLinks deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductIndex200ResponseLinksBuilder();
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

