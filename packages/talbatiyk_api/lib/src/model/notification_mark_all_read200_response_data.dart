//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_mark_all_read200_response_data.g.dart';

/// NotificationMarkAllRead200ResponseData
///
/// Properties:
/// * [updatedCount] 
/// * [unreadCount] 
@BuiltValue()
abstract class NotificationMarkAllRead200ResponseData implements Built<NotificationMarkAllRead200ResponseData, NotificationMarkAllRead200ResponseDataBuilder> {
  @BuiltValueField(wireName: r'updated_count')
  int get updatedCount;

  @BuiltValueField(wireName: r'unread_count')
  int get unreadCount;

  NotificationMarkAllRead200ResponseData._();

  factory NotificationMarkAllRead200ResponseData([void updates(NotificationMarkAllRead200ResponseDataBuilder b)]) = _$NotificationMarkAllRead200ResponseData;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationMarkAllRead200ResponseDataBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationMarkAllRead200ResponseData> get serializer => _$NotificationMarkAllRead200ResponseDataSerializer();
}

class _$NotificationMarkAllRead200ResponseDataSerializer implements PrimitiveSerializer<NotificationMarkAllRead200ResponseData> {
  @override
  final Iterable<Type> types = const [NotificationMarkAllRead200ResponseData, _$NotificationMarkAllRead200ResponseData];

  @override
  final String wireName = r'NotificationMarkAllRead200ResponseData';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationMarkAllRead200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'updated_count';
    yield serializers.serialize(
      object.updatedCount,
      specifiedType: const FullType(int),
    );
    yield r'unread_count';
    yield serializers.serialize(
      object.unreadCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationMarkAllRead200ResponseData object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationMarkAllRead200ResponseDataBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'updated_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.updatedCount = valueDes;
          break;
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
  NotificationMarkAllRead200ResponseData deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationMarkAllRead200ResponseDataBuilder();
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

