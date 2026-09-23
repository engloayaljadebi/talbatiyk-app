// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_mark_all_read200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationMarkAllRead200ResponseData
    extends NotificationMarkAllRead200ResponseData {
  @override
  final int updatedCount;
  @override
  final int unreadCount;

  factory _$NotificationMarkAllRead200ResponseData(
          [void Function(NotificationMarkAllRead200ResponseDataBuilder)?
              updates]) =>
      (NotificationMarkAllRead200ResponseDataBuilder()..update(updates))
          ._build();

  _$NotificationMarkAllRead200ResponseData._(
      {required this.updatedCount, required this.unreadCount})
      : super._();
  @override
  NotificationMarkAllRead200ResponseData rebuild(
          void Function(NotificationMarkAllRead200ResponseDataBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationMarkAllRead200ResponseDataBuilder toBuilder() =>
      NotificationMarkAllRead200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationMarkAllRead200ResponseData &&
        updatedCount == other.updatedCount &&
        unreadCount == other.unreadCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, updatedCount.hashCode);
    _$hash = $jc(_$hash, unreadCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'NotificationMarkAllRead200ResponseData')
          ..add('updatedCount', updatedCount)
          ..add('unreadCount', unreadCount))
        .toString();
  }
}

class NotificationMarkAllRead200ResponseDataBuilder
    implements
        Builder<NotificationMarkAllRead200ResponseData,
            NotificationMarkAllRead200ResponseDataBuilder> {
  _$NotificationMarkAllRead200ResponseData? _$v;

  int? _updatedCount;
  int? get updatedCount => _$this._updatedCount;
  set updatedCount(int? updatedCount) => _$this._updatedCount = updatedCount;

  int? _unreadCount;
  int? get unreadCount => _$this._unreadCount;
  set unreadCount(int? unreadCount) => _$this._unreadCount = unreadCount;

  NotificationMarkAllRead200ResponseDataBuilder() {
    NotificationMarkAllRead200ResponseData._defaults(this);
  }

  NotificationMarkAllRead200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _updatedCount = $v.updatedCount;
      _unreadCount = $v.unreadCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationMarkAllRead200ResponseData other) {
    _$v = other as _$NotificationMarkAllRead200ResponseData;
  }

  @override
  void update(
      void Function(NotificationMarkAllRead200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationMarkAllRead200ResponseData build() => _build();

  _$NotificationMarkAllRead200ResponseData _build() {
    final _$result = _$v ??
        _$NotificationMarkAllRead200ResponseData._(
          updatedCount: BuiltValueNullFieldError.checkNotNull(updatedCount,
              r'NotificationMarkAllRead200ResponseData', 'updatedCount'),
          unreadCount: BuiltValueNullFieldError.checkNotNull(unreadCount,
              r'NotificationMarkAllRead200ResponseData', 'unreadCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
