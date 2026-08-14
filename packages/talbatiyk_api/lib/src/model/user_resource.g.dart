// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserResource extends UserResource {
  @override
  final String id;
  @override
  final String username;
  @override
  final String displayName;
  @override
  final String status;
  @override
  final String? lastLoginAt;
  @override
  final BuiltList<UserResourceContactsInner>? contacts;

  factory _$UserResource([void Function(UserResourceBuilder)? updates]) =>
      (UserResourceBuilder()..update(updates))._build();

  _$UserResource._(
      {required this.id,
      required this.username,
      required this.displayName,
      required this.status,
      this.lastLoginAt,
      this.contacts})
      : super._();
  @override
  UserResource rebuild(void Function(UserResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserResourceBuilder toBuilder() => UserResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserResource &&
        id == other.id &&
        username == other.username &&
        displayName == other.displayName &&
        status == other.status &&
        lastLoginAt == other.lastLoginAt &&
        contacts == other.contacts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, lastLoginAt.hashCode);
    _$hash = $jc(_$hash, contacts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserResource')
          ..add('id', id)
          ..add('username', username)
          ..add('displayName', displayName)
          ..add('status', status)
          ..add('lastLoginAt', lastLoginAt)
          ..add('contacts', contacts))
        .toString();
  }
}

class UserResourceBuilder
    implements Builder<UserResource, UserResourceBuilder> {
  _$UserResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _lastLoginAt;
  String? get lastLoginAt => _$this._lastLoginAt;
  set lastLoginAt(String? lastLoginAt) => _$this._lastLoginAt = lastLoginAt;

  ListBuilder<UserResourceContactsInner>? _contacts;
  ListBuilder<UserResourceContactsInner> get contacts =>
      _$this._contacts ??= ListBuilder<UserResourceContactsInner>();
  set contacts(ListBuilder<UserResourceContactsInner>? contacts) =>
      _$this._contacts = contacts;

  UserResourceBuilder() {
    UserResource._defaults(this);
  }

  UserResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _displayName = $v.displayName;
      _status = $v.status;
      _lastLoginAt = $v.lastLoginAt;
      _contacts = $v.contacts?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserResource other) {
    _$v = other as _$UserResource;
  }

  @override
  void update(void Function(UserResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserResource build() => _build();

  _$UserResource _build() {
    _$UserResource _$result;
    try {
      _$result = _$v ??
          _$UserResource._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'UserResource', 'id'),
            username: BuiltValueNullFieldError.checkNotNull(
                username, r'UserResource', 'username'),
            displayName: BuiltValueNullFieldError.checkNotNull(
                displayName, r'UserResource', 'displayName'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'UserResource', 'status'),
            lastLoginAt: lastLoginAt,
            contacts: _contacts?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'contacts';
        _contacts?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserResource', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
