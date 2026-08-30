//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_supplier_fulfillment_request.g.dart';

/// UpdateSupplierFulfillmentRequest
///
/// Properties:
/// * [expectedVersion] 
/// * [status] 
@BuiltValue()
abstract class UpdateSupplierFulfillmentRequest implements Built<UpdateSupplierFulfillmentRequest, UpdateSupplierFulfillmentRequestBuilder> {
  @BuiltValueField(wireName: r'expected_version')
  int get expectedVersion;

  @BuiltValueField(wireName: r'status')
  UpdateSupplierFulfillmentRequestStatusEnum get status;
  // enum statusEnum {  preparing,  ready_for_delivery,  out_for_delivery,  delivered,  };

  UpdateSupplierFulfillmentRequest._();

  factory UpdateSupplierFulfillmentRequest([void updates(UpdateSupplierFulfillmentRequestBuilder b)]) = _$UpdateSupplierFulfillmentRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateSupplierFulfillmentRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateSupplierFulfillmentRequest> get serializer => _$UpdateSupplierFulfillmentRequestSerializer();
}

class _$UpdateSupplierFulfillmentRequestSerializer implements PrimitiveSerializer<UpdateSupplierFulfillmentRequest> {
  @override
  final Iterable<Type> types = const [UpdateSupplierFulfillmentRequest, _$UpdateSupplierFulfillmentRequest];

  @override
  final String wireName = r'UpdateSupplierFulfillmentRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateSupplierFulfillmentRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expected_version';
    yield serializers.serialize(
      object.expectedVersion,
      specifiedType: const FullType(int),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(UpdateSupplierFulfillmentRequestStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateSupplierFulfillmentRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateSupplierFulfillmentRequestBuilder result,
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
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateSupplierFulfillmentRequestStatusEnum),
          ) as UpdateSupplierFulfillmentRequestStatusEnum;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateSupplierFulfillmentRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateSupplierFulfillmentRequestBuilder();
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

class UpdateSupplierFulfillmentRequestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'preparing')
  static const UpdateSupplierFulfillmentRequestStatusEnum preparing = _$updateSupplierFulfillmentRequestStatusEnum_preparing;
  @BuiltValueEnumConst(wireName: r'ready_for_delivery')
  static const UpdateSupplierFulfillmentRequestStatusEnum readyForDelivery = _$updateSupplierFulfillmentRequestStatusEnum_readyForDelivery;
  @BuiltValueEnumConst(wireName: r'out_for_delivery')
  static const UpdateSupplierFulfillmentRequestStatusEnum outForDelivery = _$updateSupplierFulfillmentRequestStatusEnum_outForDelivery;
  @BuiltValueEnumConst(wireName: r'delivered')
  static const UpdateSupplierFulfillmentRequestStatusEnum delivered = _$updateSupplierFulfillmentRequestStatusEnum_delivered;

  static Serializer<UpdateSupplierFulfillmentRequestStatusEnum> get serializer => _$updateSupplierFulfillmentRequestStatusEnumSerializer;

  const UpdateSupplierFulfillmentRequestStatusEnum._(String name): super(name);

  static BuiltSet<UpdateSupplierFulfillmentRequestStatusEnum> get values => _$updateSupplierFulfillmentRequestStatusEnumValues;
  static UpdateSupplierFulfillmentRequestStatusEnum valueOf(String name) => _$updateSupplierFulfillmentRequestStatusEnumValueOf(name);
}

