//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'product_resource.g.dart';

/// ProductResource
///
/// Properties:
/// * [id] 
/// * [supplierId] 
/// * [supplierName] 
/// * [name] 
/// * [description] 
/// * [category] 
/// * [brand] 
/// * [price] 
/// * [quantity] 
/// * [isAvailable] 
/// * [imageUrl] 
/// * [colors] 
/// * [discount] 
/// * [rating] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class ProductResource implements Built<ProductResource, ProductResourceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'supplier_id')
  String get supplierId;

  @BuiltValueField(wireName: r'supplier_name')
  String get supplierName;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'category')
  String get category;

  @BuiltValueField(wireName: r'brand')
  String get brand;

  @BuiltValueField(wireName: r'price')
  num get price;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  @BuiltValueField(wireName: r'is_available')
  bool get isAvailable;

  @BuiltValueField(wireName: r'image_url')
  String? get imageUrl;

  @BuiltValueField(wireName: r'colors')
  BuiltList<String> get colors;

  @BuiltValueField(wireName: r'discount')
  num get discount;

  @BuiltValueField(wireName: r'rating')
  num get rating;

  @BuiltValueField(wireName: r'created_at')
  String? get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  String? get updatedAt;

  ProductResource._();

  factory ProductResource([void updates(ProductResourceBuilder b)]) = _$ProductResource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProductResourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProductResource> get serializer => _$ProductResourceSerializer();
}

class _$ProductResourceSerializer implements PrimitiveSerializer<ProductResource> {
  @override
  final Iterable<Type> types = const [ProductResource, _$ProductResource];

  @override
  final String wireName = r'ProductResource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProductResource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'supplier_id';
    yield serializers.serialize(
      object.supplierId,
      specifiedType: const FullType(String),
    );
    yield r'supplier_name';
    yield serializers.serialize(
      object.supplierName,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'description';
    yield object.description == null ? null : serializers.serialize(
      object.description,
      specifiedType: const FullType.nullable(String),
    );
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(String),
    );
    yield r'brand';
    yield serializers.serialize(
      object.brand,
      specifiedType: const FullType(String),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(num),
    );
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
    yield r'is_available';
    yield serializers.serialize(
      object.isAvailable,
      specifiedType: const FullType(bool),
    );
    yield r'image_url';
    yield object.imageUrl == null ? null : serializers.serialize(
      object.imageUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'colors';
    yield serializers.serialize(
      object.colors,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'discount';
    yield serializers.serialize(
      object.discount,
      specifiedType: const FullType(num),
    );
    yield r'rating';
    yield serializers.serialize(
      object.rating,
      specifiedType: const FullType(num),
    );
    yield r'created_at';
    yield object.createdAt == null ? null : serializers.serialize(
      object.createdAt,
      specifiedType: const FullType.nullable(String),
    );
    yield r'updated_at';
    yield object.updatedAt == null ? null : serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProductResource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProductResourceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'supplier_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.supplierId = valueDes;
          break;
        case r'supplier_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.supplierName = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.category = valueDes;
          break;
        case r'brand':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.brand = valueDes;
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.price = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        case r'is_available':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isAvailable = valueDes;
          break;
        case r'image_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.imageUrl = valueDes;
          break;
        case r'colors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.colors.replace(valueDes);
          break;
        case r'discount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.discount = valueDes;
          break;
        case r'rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.rating = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProductResource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProductResourceBuilder();
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

