//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/availability_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'submit_supplier_order_response_request_items_inner.g.dart';

/// SubmitSupplierOrderResponseRequestItemsInner
///
/// Properties:
/// * [orderRecipientItemId] 
/// * [availabilityStatus] 
/// * [availableQuantity] 
/// * [offeredUnitPrice] 
/// * [responseNotes] 
@BuiltValue()
abstract class SubmitSupplierOrderResponseRequestItemsInner implements Built<SubmitSupplierOrderResponseRequestItemsInner, SubmitSupplierOrderResponseRequestItemsInnerBuilder> {
  @BuiltValueField(wireName: r'order_recipient_item_id')
  String get orderRecipientItemId;

  @BuiltValueField(wireName: r'availability_status')
  AvailabilityStatus get availabilityStatus;
  // enum availabilityStatusEnum {  full,  partial,  unavailable,  };

  @BuiltValueField(wireName: r'available_quantity')
  int get availableQuantity;

  @BuiltValueField(wireName: r'offered_unit_price')
  num? get offeredUnitPrice;

  @BuiltValueField(wireName: r'response_notes')
  String? get responseNotes;

  SubmitSupplierOrderResponseRequestItemsInner._();

  factory SubmitSupplierOrderResponseRequestItemsInner([void updates(SubmitSupplierOrderResponseRequestItemsInnerBuilder b)]) = _$SubmitSupplierOrderResponseRequestItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubmitSupplierOrderResponseRequestItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubmitSupplierOrderResponseRequestItemsInner> get serializer => _$SubmitSupplierOrderResponseRequestItemsInnerSerializer();
}

class _$SubmitSupplierOrderResponseRequestItemsInnerSerializer implements PrimitiveSerializer<SubmitSupplierOrderResponseRequestItemsInner> {
  @override
  final Iterable<Type> types = const [SubmitSupplierOrderResponseRequestItemsInner, _$SubmitSupplierOrderResponseRequestItemsInner];

  @override
  final String wireName = r'SubmitSupplierOrderResponseRequestItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubmitSupplierOrderResponseRequestItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'order_recipient_item_id';
    yield serializers.serialize(
      object.orderRecipientItemId,
      specifiedType: const FullType(String),
    );
    yield r'availability_status';
    yield serializers.serialize(
      object.availabilityStatus,
      specifiedType: const FullType(AvailabilityStatus),
    );
    yield r'available_quantity';
    yield serializers.serialize(
      object.availableQuantity,
      specifiedType: const FullType(int),
    );
    if (object.offeredUnitPrice != null) {
      yield r'offered_unit_price';
      yield serializers.serialize(
        object.offeredUnitPrice,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.responseNotes != null) {
      yield r'response_notes';
      yield serializers.serialize(
        object.responseNotes,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SubmitSupplierOrderResponseRequestItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubmitSupplierOrderResponseRequestItemsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'order_recipient_item_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.orderRecipientItemId = valueDes;
          break;
        case r'availability_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AvailabilityStatus),
          ) as AvailabilityStatus;
          result.availabilityStatus = valueDes;
          break;
        case r'available_quantity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.availableQuantity = valueDes;
          break;
        case r'offered_unit_price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.offeredUnitPrice = valueDes;
          break;
        case r'response_notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.responseNotes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SubmitSupplierOrderResponseRequestItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubmitSupplierOrderResponseRequestItemsInnerBuilder();
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

