//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'supplier_approval_admin_index200_response_data_inner_business.g.dart';

/// SupplierApprovalAdminIndex200ResponseDataInnerBusiness
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [status] 
@BuiltValue()
abstract class SupplierApprovalAdminIndex200ResponseDataInnerBusiness implements Built<SupplierApprovalAdminIndex200ResponseDataInnerBusiness, SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'status')
  String get status;

  SupplierApprovalAdminIndex200ResponseDataInnerBusiness._();

  factory SupplierApprovalAdminIndex200ResponseDataInnerBusiness([void updates(SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder b)]) = _$SupplierApprovalAdminIndex200ResponseDataInnerBusiness;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SupplierApprovalAdminIndex200ResponseDataInnerBusiness> get serializer => _$SupplierApprovalAdminIndex200ResponseDataInnerBusinessSerializer();
}

class _$SupplierApprovalAdminIndex200ResponseDataInnerBusinessSerializer implements PrimitiveSerializer<SupplierApprovalAdminIndex200ResponseDataInnerBusiness> {
  @override
  final Iterable<Type> types = const [SupplierApprovalAdminIndex200ResponseDataInnerBusiness, _$SupplierApprovalAdminIndex200ResponseDataInnerBusiness];

  @override
  final String wireName = r'SupplierApprovalAdminIndex200ResponseDataInnerBusiness';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SupplierApprovalAdminIndex200ResponseDataInnerBusiness object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SupplierApprovalAdminIndex200ResponseDataInnerBusiness object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  SupplierApprovalAdminIndex200ResponseDataInnerBusiness deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SupplierApprovalAdminIndex200ResponseDataInnerBusinessBuilder();
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

