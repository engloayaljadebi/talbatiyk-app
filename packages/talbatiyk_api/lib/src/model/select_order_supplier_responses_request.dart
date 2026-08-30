//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/select_order_supplier_responses_request_selections_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'select_order_supplier_responses_request.g.dart';

/// SelectOrderSupplierResponsesRequest
///
/// Properties:
/// * [expectedVersion] 
/// * [selections] 
@BuiltValue()
abstract class SelectOrderSupplierResponsesRequest implements Built<SelectOrderSupplierResponsesRequest, SelectOrderSupplierResponsesRequestBuilder> {
  @BuiltValueField(wireName: r'expected_version')
  int get expectedVersion;

  @BuiltValueField(wireName: r'selections')
  BuiltList<SelectOrderSupplierResponsesRequestSelectionsInner> get selections;

  SelectOrderSupplierResponsesRequest._();

  factory SelectOrderSupplierResponsesRequest([void updates(SelectOrderSupplierResponsesRequestBuilder b)]) = _$SelectOrderSupplierResponsesRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SelectOrderSupplierResponsesRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SelectOrderSupplierResponsesRequest> get serializer => _$SelectOrderSupplierResponsesRequestSerializer();
}

class _$SelectOrderSupplierResponsesRequestSerializer implements PrimitiveSerializer<SelectOrderSupplierResponsesRequest> {
  @override
  final Iterable<Type> types = const [SelectOrderSupplierResponsesRequest, _$SelectOrderSupplierResponsesRequest];

  @override
  final String wireName = r'SelectOrderSupplierResponsesRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SelectOrderSupplierResponsesRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expected_version';
    yield serializers.serialize(
      object.expectedVersion,
      specifiedType: const FullType(int),
    );
    yield r'selections';
    yield serializers.serialize(
      object.selections,
      specifiedType: const FullType(BuiltList, [FullType(SelectOrderSupplierResponsesRequestSelectionsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SelectOrderSupplierResponsesRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SelectOrderSupplierResponsesRequestBuilder result,
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
        case r'selections':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SelectOrderSupplierResponsesRequestSelectionsInner)]),
          ) as BuiltList<SelectOrderSupplierResponsesRequestSelectionsInner>;
          result.selections.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SelectOrderSupplierResponsesRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SelectOrderSupplierResponsesRequestBuilder();
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

