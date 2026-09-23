//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:talbatiyk_api/src/model/notification_mark_all_read200_response_data.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_mark_all_read200_response.g.dart';

/// NotificationMarkAllRead200Response
///
/// Properties:
/// * [data] 
@BuiltValue()
abstract class NotificationMarkAllRead200Response implements Built<NotificationMarkAllRead200Response, NotificationMarkAllRead200ResponseBuilder> {
  @BuiltValueField(wireName: r'data')
  NotificationMarkAllRead200ResponseData get data;

  NotificationMarkAllRead200Response._();

  factory NotificationMarkAllRead200Response([void updates(NotificationMarkAllRead200ResponseBuilder b)]) = _$NotificationMarkAllRead200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationMarkAllRead200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationMarkAllRead200Response> get serializer => _$NotificationMarkAllRead200ResponseSerializer();
}

class _$NotificationMarkAllRead200ResponseSerializer implements PrimitiveSerializer<NotificationMarkAllRead200Response> {
  @override
  final Iterable<Type> types = const [NotificationMarkAllRead200Response, _$NotificationMarkAllRead200Response];

  @override
  final String wireName = r'NotificationMarkAllRead200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationMarkAllRead200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(NotificationMarkAllRead200ResponseData),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationMarkAllRead200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationMarkAllRead200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NotificationMarkAllRead200ResponseData),
          ) as NotificationMarkAllRead200ResponseData;
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
  NotificationMarkAllRead200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationMarkAllRead200ResponseBuilder();
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

