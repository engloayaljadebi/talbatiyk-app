//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_order_request_items_inner.g.dart';

/// CreateOrderRequestItemsInner
///
/// Properties:
/// * [itemType] - Omitted or null means catalog. The value is intentionally not injected into the validated data so that the idempotency payload hash of existing clients stays unchanged.
/// * [productId] - Catalog items only. Product existence is commercial state and must be validated after idempotency replay lookup inside OrderService.
/// * [quantity] 
/// * [expectedUnitPrice] - Catalog items only. This is the price Flutter observed when the user confirmed. Laravel compares it with Product.price and never stores it as the authoritative order price.
/// * [expectedSupplierId] - Catalog items only. This is a concurrency expectation, not the authoritative supplier. Laravel resolves the real supplier from Product.
/// * [name] - Manual items only. The name is stored in order_items.product_name and the price in order_items.unit_price. A manual item has one price only.
/// * [unitPrice] 
/// * [unit] 
/// * [note] 
@BuiltValue()
abstract class CreateOrderRequestItemsInner implements Built<CreateOrderRequestItemsInner, CreateOrderRequestItemsInnerBuilder> {
  /// Omitted or null means catalog. The value is intentionally not injected into the validated data so that the idempotency payload hash of existing clients stays unchanged.
  @BuiltValueField(wireName: r'item_type')
  CreateOrderRequestItemsInnerItemTypeEnum? get itemType;
  // enum itemTypeEnum {  catalog,  manual,  ,  };

  /// Catalog items only. Product existence is commercial state and must be validated after idempotency replay lookup inside OrderService.
  @BuiltValueField(wireName: r'product_id')
  String? get productId;

  @BuiltValueField(wireName: r'quantity')
  int get quantity;

  /// Catalog items only. This is the price Flutter observed when the user confirmed. Laravel compares it with Product.price and never stores it as the authoritative order price.
  @BuiltValueField(wireName: r'expected_unit_price')
  num? get expectedUnitPrice;

  /// Catalog items only. This is a concurrency expectation, not the authoritative supplier. Laravel resolves the real supplier from Product.
  @BuiltValueField(wireName: r'expected_supplier_id')
  String? get expectedSupplierId;

  /// Manual items only. The name is stored in order_items.product_name and the price in order_items.unit_price. A manual item has one price only.
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'unit_price')
  num? get unitPrice;

  @BuiltValueField(wireName: r'unit')
  String? get unit;

  @BuiltValueField(wireName: r'note')
  String? get note;

  CreateOrderRequestItemsInner._();

  factory CreateOrderRequestItemsInner([void updates(CreateOrderRequestItemsInnerBuilder b)]) = _$CreateOrderRequestItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateOrderRequestItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateOrderRequestItemsInner> get serializer => _$CreateOrderRequestItemsInnerSerializer();
}

class _$CreateOrderRequestItemsInnerSerializer implements PrimitiveSerializer<CreateOrderRequestItemsInner> {
  @override
  final Iterable<Type> types = const [CreateOrderRequestItemsInner, _$CreateOrderRequestItemsInner];

  @override
  final String wireName = r'CreateOrderRequestItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateOrderRequestItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.itemType != null) {
      yield r'item_type';
      yield serializers.serialize(
        object.itemType,
        specifiedType: const FullType.nullable(CreateOrderRequestItemsInnerItemTypeEnum),
      );
    }
    if (object.productId != null) {
      yield r'product_id';
      yield serializers.serialize(
        object.productId,
        specifiedType: const FullType(String),
      );
    }
    yield r'quantity';
    yield serializers.serialize(
      object.quantity,
      specifiedType: const FullType(int),
    );
    if (object.expectedUnitPrice != null) {
      yield r'expected_unit_price';
      yield serializers.serialize(
        object.expectedUnitPrice,
        specifiedType: const FullType(num),
      );
    }
    if (object.expectedSupplierId != null) {
      yield r'expected_supplier_id';
      yield serializers.serialize(
        object.expectedSupplierId,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.unitPrice != null) {
      yield r'unit_price';
      yield serializers.serialize(
        object.unitPrice,
        specifiedType: const FullType(num),
      );
    }
    if (object.unit != null) {
      yield r'unit';
      yield serializers.serialize(
        object.unit,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateOrderRequestItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateOrderRequestItemsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'item_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CreateOrderRequestItemsInnerItemTypeEnum),
          ) as CreateOrderRequestItemsInnerItemTypeEnum?;
          if (valueDes == null) continue;
          result.itemType = valueDes;
          break;
        case r'product_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.productId = valueDes;
          break;
        case r'quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.quantity = valueDes;
          break;
        case r'expected_unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.expectedUnitPrice = valueDes;
          break;
        case r'expected_supplier_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expectedSupplierId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.unitPrice = valueDes;
          break;
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unit = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateOrderRequestItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateOrderRequestItemsInnerBuilder();
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

class CreateOrderRequestItemsInnerItemTypeEnum extends EnumClass {

  /// Omitted or null means catalog. The value is intentionally not injected into the validated data so that the idempotency payload hash of existing clients stays unchanged.
  @BuiltValueEnumConst(wireName: r'catalog')
  static const CreateOrderRequestItemsInnerItemTypeEnum catalog = _$createOrderRequestItemsInnerItemTypeEnum_catalog;
  /// Omitted or null means catalog. The value is intentionally not injected into the validated data so that the idempotency payload hash of existing clients stays unchanged.
  @BuiltValueEnumConst(wireName: r'manual')
  static const CreateOrderRequestItemsInnerItemTypeEnum manual = _$createOrderRequestItemsInnerItemTypeEnum_manual;

  static Serializer<CreateOrderRequestItemsInnerItemTypeEnum> get serializer => _$createOrderRequestItemsInnerItemTypeEnumSerializer;

  const CreateOrderRequestItemsInnerItemTypeEnum._(String name): super(name);

  static BuiltSet<CreateOrderRequestItemsInnerItemTypeEnum> get values => _$createOrderRequestItemsInnerItemTypeEnumValues;
  static CreateOrderRequestItemsInnerItemTypeEnum valueOf(String name) => _$createOrderRequestItemsInnerItemTypeEnumValueOf(name);
}

