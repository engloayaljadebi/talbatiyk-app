//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/supplier_summary_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_discovery_index200_response.g.dart';

/// SupplierDiscoveryIndex200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class SupplierDiscoveryIndex200Response implements Built<SupplierDiscoveryIndex200Response, SupplierDiscoveryIndex200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<SupplierSummaryResource> get data;

  SupplierDiscoveryIndex200Response._();

  factory SupplierDiscoveryIndex200Response([void updates(SupplierDiscoveryIndex200ResponseBuilder b)]) = _$SupplierDiscoveryIndex200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierDiscoveryIndex200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierDiscoveryIndex200Response> get serializer => _$SupplierDiscoveryIndex200ResponseSerializer();
}

class _$SupplierDiscoveryIndex200ResponseSerializer implements PrimitiveSerializer<SupplierDiscoveryIndex200Response> {
  @override
  final Iterable<Type> types = const [SupplierDiscoveryIndex200Response, _$SupplierDiscoveryIndex200Response];

  @override
  final String wireName = r'SupplierDiscoveryIndex200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierDiscoveryIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(SupplierSummaryResource)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierDiscoveryIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierDiscoveryIndex200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SupplierSummaryResource)]),
          ) as BuiltList<SupplierSummaryResource>;
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
  SupplierDiscoveryIndex200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierDiscoveryIndex200ResponseBuilder();
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

