//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/notification_resource.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_mark_read200_response.g.dart';

/// NotificationMarkRead200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class NotificationMarkRead200Response implements Built<NotificationMarkRead200Response, NotificationMarkRead200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  NotificationResource get data;

  NotificationMarkRead200Response._();

  factory NotificationMarkRead200Response([void updates(NotificationMarkRead200ResponseBuilder b)]) = _$NotificationMarkRead200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationMarkRead200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationMarkRead200Response> get serializer => _$NotificationMarkRead200ResponseSerializer();
}

class _$NotificationMarkRead200ResponseSerializer implements PrimitiveSerializer<NotificationMarkRead200Response> {
  @override
  final Iterable<Type> types = const [NotificationMarkRead200Response, _$NotificationMarkRead200Response];

  @override
  final String wireName = r'NotificationMarkRead200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationMarkRead200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(NotificationResource),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationMarkRead200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationMarkRead200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationResource),
          ) as NotificationResource;
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
  NotificationMarkRead200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationMarkRead200ResponseBuilder();
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

