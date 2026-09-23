// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_mark_all_read200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationMarkAllRead200Response
    extends NotificationMarkAllRead200Response {
  @override
  final NotificationMarkAllRead200ResponseData data;

  factory _$NotificationMarkAllRead200Response(
          [void Function(NotificationMarkAllRead200ResponseBuilder)?
              updates]) =>
      (NotificationMarkAllRead200ResponseBuilder()..update(updates))._build();

  _$NotificationMarkAllRead200Response._({required this.data}) : super._();
  @override
  NotificationMarkAllRead200Response rebuild(
          void Function(NotificationMarkAllRead200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationMarkAllRead200ResponseBuilder toBuilder() =>
      NotificationMarkAllRead200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationMarkAllRead200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'NotificationMarkAllRead200Response')
          ..add('data', data))
        .toString();
  }
}

class NotificationMarkAllRead200ResponseBuilder
    implements
        Builder<NotificationMarkAllRead200Response,
            NotificationMarkAllRead200ResponseBuilder> {
  _$NotificationMarkAllRead200Response? _$v;

  NotificationMarkAllRead200ResponseDataBuilder? _data;
  NotificationMarkAllRead200ResponseDataBuilder get data =>
      _$this._data ??= NotificationMarkAllRead200ResponseDataBuilder();
  set data(NotificationMarkAllRead200ResponseDataBuilder? data) =>
      _$this._data = data;

  NotificationMarkAllRead200ResponseBuilder() {
    NotificationMarkAllRead200Response._defaults(this);
  }

  NotificationMarkAllRead200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationMarkAllRead200Response other) {
    _$v = other as _$NotificationMarkAllRead200Response;
  }

  @override
  void update(
      void Function(NotificationMarkAllRead200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationMarkAllRead200Response build() => _build();

  _$NotificationMarkAllRead200Response _build() {
    _$NotificationMarkAllRead200Response _$result;
    try {
      _$result = _$v ??
          _$NotificationMarkAllRead200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotificationMarkAllRead200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
