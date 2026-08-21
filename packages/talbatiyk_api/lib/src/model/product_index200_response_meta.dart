//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/product_index200_response_meta_links_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_index200_response_meta.g.dart';

/// ProductIndex200ResponseMeta
///
/// Properties:
/// * [currentPage] 
/// * [from] 
/// * [lastPage] 
/// * [links] - Generated paginator links.
/// * [path] - Base path for paginator generated URLs.
/// * [perPage] - Number of items shown per page.
/// * [to] - Number of the last item in the slice.
/// * [total] - Total number of items being paginated.
@BuiltValue()
abstract class ProductIndex200ResponseMeta implements Built<ProductIndex200ResponseMeta, ProductIndex200ResponseMetaBuilder> {
  @BuiltValueField(wireName: r'current_page')
  int get currentPage;

  @BuiltValueField(wireName: r'from')
  int? get from;

  @BuiltValueField(wireName: r'last_page')
  int get lastPage;

  /// Generated paginator links.
  @BuiltValueField(wireName: r'links')
  BuiltList<ProductIndex200ResponseMetaLinksInner> get links;

  /// Base path for paginator generated URLs.
  @BuiltValueField(wireName: r'path')
  String? get path;

  /// Number of items shown per page.
  @BuiltValueField(wireName: r'per_page')
  int get perPage;

  /// Number of the last item in the slice.
  @BuiltValueField(wireName: r'to')
  int? get to;

  /// Total number of items being paginated.
  @BuiltValueField(wireName: r'total')
  int get total;

  ProductIndex200ResponseMeta._();

  factory ProductIndex200ResponseMeta([void updates(ProductIndex200ResponseMetaBuilder b)]) = _$ProductIndex200ResponseMeta;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductIndex200ResponseMetaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductIndex200ResponseMeta> get serializer => _$ProductIndex200ResponseMetaSerializer();
}

class _$ProductIndex200ResponseMetaSerializer implements PrimitiveSerializer<ProductIndex200ResponseMeta> {
  @override
  final Iterable<Type> types = const [ProductIndex200ResponseMeta, _$ProductIndex200ResponseMeta];

  @override
  final String wireName = r'ProductIndex200ResponseMeta';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductIndex200ResponseMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'current_page';
    yield serializers.serialize(
      object.currentPage,
      specifiedType: const FullType(int),
    );
    yield r'from';
    yield object.from == null ? null : serializers.serialize(
      object.from,
      specifiedType: const FullType.nullable(int),
    );
    yield r'last_page';
    yield serializers.serialize(
      object.lastPage,
      specifiedType: const FullType(int),
    );
    yield r'links';
    yield serializers.serialize(
      object.links,
      specifiedType: const FullType(BuiltList, [FullType(ProductIndex200ResponseMetaLinksInner)]),
    );
    yield r'path';
    yield object.path == null ? null : serializers.serialize(
      object.path,
      specifiedType: const FullType.nullable(String),
    );
    yield r'per_page';
    yield serializers.serialize(
      object.perPage,
      specifiedType: const FullType(int),
    );
    yield r'to';
    yield object.to == null ? null : serializers.serialize(
      object.to,
      specifiedType: const FullType.nullable(int),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductIndex200ResponseMeta object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProductIndex200ResponseMetaBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'current_page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.currentPage = valueDes;
          break;
        case r'from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.from = valueDes;
          break;
        case r'last_page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.lastPage = valueDes;
          break;
        case r'links':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ProductIndex200ResponseMetaLinksInner)]),
          ) as BuiltList<ProductIndex200ResponseMetaLinksInner>;
          result.links.replace(valueDes);
          break;
        case r'path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.path = valueDes;
          break;
        case r'per_page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.perPage = valueDes;
          break;
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.to = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductIndex200ResponseMeta deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductIndex200ResponseMetaBuilder();
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

