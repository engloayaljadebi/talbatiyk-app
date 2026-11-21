// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_unread_count200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationUnreadCount200Response
    extends NotificationUnreadCount200Response {
  @override
  final NotificationUnreadCount200ResponseData data;

  factory _$NotificationUnreadCount200Response(
          [void Function(NotificationUnreadCount200ResponseBuilder)?
              updates]) =>
      (NotificationUnreadCount200ResponseBuilder()..update(updates))._build();

  _$NotificationUnreadCount200Response._({required this.data}) : super._();
  @override
  NotificationUnreadCount200Response rebuild(
          void Function(NotificationUnreadCount200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationUnreadCount200ResponseBuilder toBuilder() =>
      NotificationUnreadCount200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationUnreadCount200Response && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationUnreadCount200Response')
          ..add('data', data))
        .toString();
  }
}

class NotificationUnreadCount200ResponseBuilder
    implements
        Builder<NotificationUnreadCount200Response,
            NotificationUnreadCount200ResponseBuilder> {
  _$NotificationUnreadCount200Response? _$v;

  NotificationUnreadCount200ResponseDataBuilder? _data;
  NotificationUnreadCount200ResponseDataBuilder get data =>
      _$this._data ??= NotificationUnreadCount200ResponseDataBuilder();
  set data(NotificationUnreadCount200ResponseDataBuilder? data) =>
      _$this._data = data;

  NotificationUnreadCount200ResponseBuilder() {
    NotificationUnreadCount200Response._defaults(this);
  }

  NotificationUnreadCount200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationUnreadCount200Response other) {
    _$v = other as _$NotificationUnreadCount200Response;
  }

  @override
  void update(
      void Function(NotificationUnreadCount200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationUnreadCount200Response build() => _build();

  _$NotificationUnreadCount200Response _build() {
    _$NotificationUnreadCount200Response _$result;
    try {
      _$result = _$v ??
          _$NotificationUnreadCount200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotificationUnreadCount200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
