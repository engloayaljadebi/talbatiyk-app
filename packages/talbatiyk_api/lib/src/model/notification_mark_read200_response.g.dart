// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_mark_read200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationMarkRead200Response
    extends NotificationMarkRead200Response {
  @override
  final NotificationResource data;

  factory _$NotificationMarkRead200Response(
          [void Function(NotificationMarkRead200ResponseBuilder)? updates]) =>
      (NotificationMarkRead200ResponseBuilder()..update(updates))._build();

  _$NotificationMarkRead200Response._({required this.data}) : super._();
  @override
  NotificationMarkRead200Response rebuild(
          void Function(NotificationMarkRead200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationMarkRead200ResponseBuilder toBuilder() =>
      NotificationMarkRead200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationMarkRead200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'NotificationMarkRead200Response')
          ..add('data', data))
        .toString();
  }
}

class NotificationMarkRead200ResponseBuilder
    implements
        Builder<NotificationMarkRead200Response,
            NotificationMarkRead200ResponseBuilder> {
  _$NotificationMarkRead200Response? _$v;

  NotificationResourceBuilder? _data;
  NotificationResourceBuilder get data =>
      _$this._data ??= NotificationResourceBuilder();
  set data(NotificationResourceBuilder? data) => _$this._data = data;

  NotificationMarkRead200ResponseBuilder() {
    NotificationMarkRead200Response._defaults(this);
  }

  NotificationMarkRead200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationMarkRead200Response other) {
    _$v = other as _$NotificationMarkRead200Response;
  }

  @override
  void update(void Function(NotificationMarkRead200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationMarkRead200Response build() => _build();

  _$NotificationMarkRead200Response _build() {
    _$NotificationMarkRead200Response _$result;
    try {
      _$result = _$v ??
          _$NotificationMarkRead200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotificationMarkRead200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
