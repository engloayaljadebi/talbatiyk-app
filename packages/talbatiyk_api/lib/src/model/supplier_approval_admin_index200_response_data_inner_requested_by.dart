//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_approval_admin_index200_response_data_inner_requested_by.g.dart';

/// SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy
///
/// Properties:
/// * [id] 
/// * [displayName] 
@BuiltValue()
abstract class SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy implements Built<SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy, SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'display_name')
  String get displayName;

  SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy._();

  factory SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy([void updates(SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder b)]) = _$SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy> get serializer => _$SupplierApprovalAdminIndex200ResponseDataInnerRequestedBySerializer();
}

class _$SupplierApprovalAdminIndex200ResponseDataInnerRequestedBySerializer implements PrimitiveSerializer<SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy> {
  @override
  final Iterable<Type> types = const [SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy, _$SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy];

  @override
  final String wireName = r'SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'display_name';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder result,
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
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SupplierApprovalAdminIndex200ResponseDataInnerRequestedBy deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierApprovalAdminIndex200ResponseDataInnerRequestedByBuilder();
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

