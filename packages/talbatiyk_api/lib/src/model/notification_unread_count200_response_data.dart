//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_unread_count200_response_data.g.dart';

/// NotificationUnreadCount200ResponseData
///
/// Properties:
/// * [unreadCount] 
@BuiltValue()
abstract class NotificationUnreadCount200ResponseData implements Built<NotificationUnreadCount200ResponseData, NotificationUnreadCount200ResponseDataBuilder> {
  @BuiltValueField(wireName: r'unread_count')
  int get unreadCount;

  NotificationUnreadCount200ResponseData._();

  factory NotificationUnreadCount200ResponseData([void updates(NotificationUnreadCount200ResponseDataBuilder b)]) = _$NotificationUnreadCount200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationUnreadCount200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationUnreadCount200ResponseData> get serializer => _$NotificationUnreadCount200ResponseDataSerializer();
}

class _$NotificationUnreadCount200ResponseDataSerializer implements PrimitiveSerializer<NotificationUnreadCount200ResponseData> {
  @override
  final Iterable<Type> types = const [NotificationUnreadCount200ResponseData, _$NotificationUnreadCount200ResponseData];

  @override
  final String wireName = r'NotificationUnreadCount200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationUnreadCount200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'unread_count';
    yield serializers.serialize(
      object.unreadCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationUnreadCount200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationUnreadCount200ResponseDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'unread_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.unreadCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationUnreadCount200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationUnreadCount200ResponseDataBuilder();
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

