//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/notification_unread_count200_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_unread_count200_response.g.dart';

/// NotificationUnreadCount200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class NotificationUnreadCount200Response implements Built<NotificationUnreadCount200Response, NotificationUnreadCount200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  NotificationUnreadCount200ResponseData get data;

  NotificationUnreadCount200Response._();

  factory NotificationUnreadCount200Response([void updates(NotificationUnreadCount200ResponseBuilder b)]) = _$NotificationUnreadCount200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationUnreadCount200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationUnreadCount200Response> get serializer => _$NotificationUnreadCount200ResponseSerializer();
}

class _$NotificationUnreadCount200ResponseSerializer implements PrimitiveSerializer<NotificationUnreadCount200Response> {
  @override
  final Iterable<Type> types = const [NotificationUnreadCount200Response, _$NotificationUnreadCount200Response];

  @override
  final String wireName = r'NotificationUnreadCount200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationUnreadCount200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(NotificationUnreadCount200ResponseData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationUnreadCount200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationUnreadCount200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationUnreadCount200ResponseData),
          ) as NotificationUnreadCount200ResponseData;
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
  NotificationUnreadCount200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationUnreadCount200ResponseBuilder();
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

