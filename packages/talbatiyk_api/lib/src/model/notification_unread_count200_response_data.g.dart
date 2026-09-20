// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_unread_count200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationUnreadCount200ResponseData
    extends NotificationUnreadCount200ResponseData {
  @override
  final int unreadCount;

  factory _$NotificationUnreadCount200ResponseData(
          [void Function(NotificationUnreadCount200ResponseDataBuilder)?
              updates]) =>
      (NotificationUnreadCount200ResponseDataBuilder()..update(updates))
          ._build();

  _$NotificationUnreadCount200ResponseData._({required this.unreadCount})
      : super._();
  @override
  NotificationUnreadCount200ResponseData rebuild(
          void Function(NotificationUnreadCount200ResponseDataBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationUnreadCount200ResponseDataBuilder toBuilder() =>
      NotificationUnreadCount200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationUnreadCount200ResponseData &&
        unreadCount == other.unreadCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, unreadCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'NotificationUnreadCount200ResponseData')
          ..add('unreadCount', unreadCount))
        .toString();
  }
}

class NotificationUnreadCount200ResponseDataBuilder
    implements
        Builder<NotificationUnreadCount200ResponseData,
            NotificationUnreadCount200ResponseDataBuilder> {
  _$NotificationUnreadCount200ResponseData? _$v;

  int? _unreadCount;
  int? get unreadCount => _$this._unreadCount;
  set unreadCount(int? unreadCount) => _$this._unreadCount = unreadCount;

  NotificationUnreadCount200ResponseDataBuilder() {
    NotificationUnreadCount200ResponseData._defaults(this);
  }

  NotificationUnreadCount200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _unreadCount = $v.unreadCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationUnreadCount200ResponseData other) {
    _$v = other as _$NotificationUnreadCount200ResponseData;
  }

  @override
  void update(
      void Function(NotificationUnreadCount200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationUnreadCount200ResponseData build() => _build();

  _$NotificationUnreadCount200ResponseData _build() {
    final _$result = _$v ??
        _$NotificationUnreadCount200ResponseData._(
          unreadCount: BuiltValueNullFieldError.checkNotNull(unreadCount,
              r'NotificationUnreadCount200ResponseData', 'unreadCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
