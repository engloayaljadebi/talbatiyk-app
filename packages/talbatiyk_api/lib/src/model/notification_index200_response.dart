//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/product_index200_response_links.dart';
import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/src/model/notification_resource.dart';
import 'package:talbatiyk_api/src/model/product_index200_response_meta.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_index200_response.g.dart';

/// NotificationIndex200Response
///
/// Properties:
/// * [data] 
/// * [links] 
/// * [meta] 
@BuiltValue()
abstract class NotificationIndex200Response implements Built<NotificationIndex200Response, NotificationIndex200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  BuiltList<NotificationResource> get data;

  @BuiltValueField(wireName: r'links')
  ProductIndex200ResponseLinks get links;

  @BuiltValueField(wireName: r'meta')
  ProductIndex200ResponseMeta get meta;

  NotificationIndex200Response._();

  factory NotificationIndex200Response([void updates(NotificationIndex200ResponseBuilder b)]) = _$NotificationIndex200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationIndex200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationIndex200Response> get serializer => _$NotificationIndex200ResponseSerializer();
}

class _$NotificationIndex200ResponseSerializer implements PrimitiveSerializer<NotificationIndex200Response> {
  @override
  final Iterable<Type> types = const [NotificationIndex200Response, _$NotificationIndex200Response];

  @override
  final String wireName = r'NotificationIndex200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(BuiltList, [FullType(NotificationResource)]),
    );
    yield r'links';
    yield serializers.serialize(
      object.links,
      specifiedType: const FullType(ProductIndex200ResponseLinks),
    );
    yield r'meta';
    yield serializers.serialize(
      object.meta,
      specifiedType: const FullType(ProductIndex200ResponseMeta),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationIndex200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationIndex200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(NotificationResource)]),
          ) as BuiltList<NotificationResource>;
          result.data.replace(valueDes);
          break;
        case r'links':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProductIndex200ResponseLinks),
          ) as ProductIndex200ResponseLinks;
          result.links.replace(valueDes);
          break;
        case r'meta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProductIndex200ResponseMeta),
          ) as ProductIndex200ResponseMeta;
          result.meta.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationIndex200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationIndex200ResponseBuilder();
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

