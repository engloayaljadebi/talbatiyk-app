// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationResource extends NotificationResource {
  @override
  final String id;
  @override
  final String type;
  @override
  final String title;
  @override
  final String body;
  @override
  final BuiltMap<String, JsonObject?> data;
  @override
  final bool isRead;
  @override
  final DateTime? readAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$NotificationResource(
          [void Function(NotificationResourceBuilder)? updates]) =>
      (NotificationResourceBuilder()..update(updates))._build();

  _$NotificationResource._(
      {required this.id,
      required this.type,
      required this.title,
      required this.body,
      required this.data,
      required this.isRead,
      this.readAt,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  NotificationResource rebuild(
          void Function(NotificationResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationResourceBuilder toBuilder() =>
      NotificationResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationResource &&
        id == other.id &&
        type == other.type &&
        title == other.title &&
        body == other.body &&
        data == other.data &&
        isRead == other.isRead &&
        readAt == other.readAt &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, isRead.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationResource')
          ..add('id', id)
          ..add('type', type)
          ..add('title', title)
          ..add('body', body)
          ..add('data', data)
          ..add('isRead', isRead)
          ..add('readAt', readAt)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class NotificationResourceBuilder
    implements Builder<NotificationResource, NotificationResourceBuilder> {
  _$NotificationResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  MapBuilder<String, JsonObject?>? _data;
  MapBuilder<String, JsonObject?> get data =>
      _$this._data ??= MapBuilder<String, JsonObject?>();
  set data(MapBuilder<String, JsonObject?>? data) => _$this._data = data;

  bool? _isRead;
  bool? get isRead => _$this._isRead;
  set isRead(bool? isRead) => _$this._isRead = isRead;

  DateTime? _readAt;
  DateTime? get readAt => _$this._readAt;
  set readAt(DateTime? readAt) => _$this._readAt = readAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  NotificationResourceBuilder() {
    NotificationResource._defaults(this);
  }

  NotificationResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _title = $v.title;
      _body = $v.body;
      _data = $v.data.toBuilder();
      _isRead = $v.isRead;
      _readAt = $v.readAt;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationResource other) {
    _$v = other as _$NotificationResource;
  }

  @override
  void update(void Function(NotificationResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationResource build() => _build();

  _$NotificationResource _build() {
    _$NotificationResource _$result;
    try {
      _$result = _$v ??
          _$NotificationResource._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'NotificationResource', 'id'),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'NotificationResource', 'type'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'NotificationResource', 'title'),
            body: BuiltValueNullFieldError.checkNotNull(
                body, r'NotificationResource', 'body'),
            data: data.build(),
            isRead: BuiltValueNullFieldError.checkNotNull(
                isRead, r'NotificationResource', 'isRead'),
            readAt: readAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotificationResource', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
