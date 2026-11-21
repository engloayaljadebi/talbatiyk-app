// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_resource_contacts_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserResourceContactsInner extends UserResourceContactsInner {
  @override
  final String id;
  @override
  final String type;
  @override
  final String value;
  @override
  final bool isPrimary;
  @override
  final String? verifiedAt;

  factory _$UserResourceContactsInner(
          [void Function(UserResourceContactsInnerBuilder)? updates]) =>
      (UserResourceContactsInnerBuilder()..update(updates))._build();

  _$UserResourceContactsInner._(
      {required this.id,
      required this.type,
      required this.value,
      required this.isPrimary,
      this.verifiedAt})
      : super._();
  @override
  UserResourceContactsInner rebuild(
          void Function(UserResourceContactsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserResourceContactsInnerBuilder toBuilder() =>
      UserResourceContactsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserResourceContactsInner &&
        id == other.id &&
        type == other.type &&
        value == other.value &&
        isPrimary == other.isPrimary &&
        verifiedAt == other.verifiedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, isPrimary.hashCode);
    _$hash = $jc(_$hash, verifiedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserResourceContactsInner')
          ..add('id', id)
          ..add('type', type)
          ..add('value', value)
          ..add('isPrimary', isPrimary)
          ..add('verifiedAt', verifiedAt))
        .toString();
  }
}

class UserResourceContactsInnerBuilder
    implements
        Builder<UserResourceContactsInner, UserResourceContactsInnerBuilder> {
  _$UserResourceContactsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  bool? _isPrimary;
  bool? get isPrimary => _$this._isPrimary;
  set isPrimary(bool? isPrimary) => _$this._isPrimary = isPrimary;

  String? _verifiedAt;
  String? get verifiedAt => _$this._verifiedAt;
  set verifiedAt(String? verifiedAt) => _$this._verifiedAt = verifiedAt;

  UserResourceContactsInnerBuilder() {
    UserResourceContactsInner._defaults(this);
  }

  UserResourceContactsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _value = $v.value;
      _isPrimary = $v.isPrimary;
      _verifiedAt = $v.verifiedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserResourceContactsInner other) {
    _$v = other as _$UserResourceContactsInner;
  }

  @override
  void update(void Function(UserResourceContactsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserResourceContactsInner build() => _build();

  _$UserResourceContactsInner _build() {
    final _$result = _$v ??
        _$UserResourceContactsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'UserResourceContactsInner', 'id'),
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'UserResourceContactsInner', 'type'),
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'UserResourceContactsInner', 'value'),
          isPrimary: BuiltValueNullFieldError.checkNotNull(
              isPrimary, r'UserResourceContactsInner', 'isPrimary'),
          verifiedAt: verifiedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
