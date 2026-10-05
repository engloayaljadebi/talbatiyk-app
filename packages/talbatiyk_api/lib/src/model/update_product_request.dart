//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_product_request.g.dart';

/// UpdateProductRequest
///
/// Properties:
/// * [expectedVersion] 
/// * [name] 
/// * [description] 
/// * [category] 
/// * [brand] 
/// * [price] 
/// * [quantity] 
/// * [isAvailable] 
/// * [removeImage] 
/// * [supplierId] 
/// * [supplierName] 
/// * [imageUrl] 
/// * [version] 
/// * [rating] 
/// * [discount] 
/// * [colors] 
/// * [idempotencyKey] 
/// * [idempotencyPayloadHash] 
/// * [deletedAt] 
@BuiltValue()
abstract class UpdateProductRequest implements Built<UpdateProductRequest, UpdateProductRequestBuilder> {
  @BuiltValueField(wireName: r'expected_version')
  int get expectedVersion;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'category')
  String get category;

  @BuiltValueField(wireName: r'brand')
  String? get brand;

  @BuiltValueField(wireName: r'price')
  num get price;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  @BuiltValueField(wireName: r'is_available')
  bool get isAvailable;

  @BuiltValueField(wireName: r'remove_image')
  bool? get removeImage;

  @BuiltValueField(wireName: r'supplier_id')
  String? get supplierId;

  @BuiltValueField(wireName: r'supplier_name')
  String? get supplierName;

  @BuiltValueField(wireName: r'image_url')
  String? get imageUrl;

  @BuiltValueField(wireName: r'version')
  String? get version;

  @BuiltValueField(wireName: r'rating')
  String? get rating;

  @BuiltValueField(wireName: r'discount')
  String? get discount;

  @BuiltValueField(wireName: r'colors')
  String? get colors;

  @BuiltValueField(wireName: r'idempotency_key')
  String? get idempotencyKey;

  @BuiltValueField(wireName: r'idempotency_payload_hash')
  String? get idempotencyPayloadHash;

  @BuiltValueField(wireName: r'deleted_at')
  String? get deletedAt;

  UpdateProductRequest._();

  factory UpdateProductRequest([void updates(UpdateProductRequestBuilder b)]) = _$UpdateProductRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateProductRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateProductRequest> get serializer => _$UpdateProductRequestSerializer();
}

class _$UpdateProductRequestSerializer implements PrimitiveSerializer<UpdateProductRequest> {
  @override
  final Iterable<Type> types = const [UpdateProductRequest, _$UpdateProductRequest];

  @override
  final String wireName = r'UpdateProductRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateProductRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expected_version';
    yield serializers.serialize(
      object.expectedVersion,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(String),
    );
    if (object.brand != null) {
      yield r'brand';
      yield serializers.serialize(
        object.brand,
        specifiedType: const FullType.nullable(String),
      );
    }
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
    if (object.removeImage != null) {
      yield r'remove_image';
      yield serializers.serialize(
        object.removeImage,
        specifiedType: const FullType(bool),
      );
    }
    if (object.supplierId != null) {
      yield r'supplier_id';
      yield serializers.serialize(
        object.supplierId,
        specifiedType: const FullType(String),
      );
    }
    if (object.supplierName != null) {
      yield r'supplier_name';
      yield serializers.serialize(
        object.supplierName,
        specifiedType: const FullType(String),
      );
    }
    if (object.imageUrl != null) {
      yield r'image_url';
      yield serializers.serialize(
        object.imageUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.version != null) {
      yield r'version';
      yield serializers.serialize(
        object.version,
        specifiedType: const FullType(String),
      );
    }
    if (object.rating != null) {
      yield r'rating';
      yield serializers.serialize(
        object.rating,
        specifiedType: const FullType(String),
      );
    }
    if (object.discount != null) {
      yield r'discount';
      yield serializers.serialize(
        object.discount,
        specifiedType: const FullType(String),
      );
    }
    if (object.colors != null) {
      yield r'colors';
      yield serializers.serialize(
        object.colors,
        specifiedType: const FullType(String),
      );
    }
    if (object.idempotencyKey != null) {
      yield r'idempotency_key';
      yield serializers.serialize(
        object.idempotencyKey,
        specifiedType: const FullType(String),
      );
    }
    if (object.idempotencyPayloadHash != null) {
      yield r'idempotency_payload_hash';
      yield serializers.serialize(
        object.idempotencyPayloadHash,
        specifiedType: const FullType(String),
      );
    }
    if (object.deletedAt != null) {
      yield r'deleted_at';
      yield serializers.serialize(
        object.deletedAt,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateProductRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateProductRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expected_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedVersion = valueDes;
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
        case r'remove_image':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.removeImage = valueDes;
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
        case r'image_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.imageUrl = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.version = valueDes;
          break;
        case r'rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rating = valueDes;
          break;
        case r'discount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.discount = valueDes;
          break;
        case r'colors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.colors = valueDes;
          break;
        case r'idempotency_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.idempotencyKey = valueDes;
          break;
        case r'idempotency_payload_hash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.idempotencyPayloadHash = valueDes;
          break;
        case r'deleted_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deletedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateProductRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateProductRequestBuilder();
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

