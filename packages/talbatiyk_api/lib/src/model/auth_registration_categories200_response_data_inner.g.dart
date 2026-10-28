// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_registration_categories200_response_data_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthRegistrationCategories200ResponseDataInner
    extends AuthRegistrationCategories200ResponseDataInner {
  @override
  final String id;
  @override
  final String name;

  factory _$AuthRegistrationCategories200ResponseDataInner(
          [void Function(AuthRegistrationCategories200ResponseDataInnerBuilder)?
              updates]) =>
      (AuthRegistrationCategories200ResponseDataInnerBuilder()..update(updates))
          ._build();

  _$AuthRegistrationCategories200ResponseDataInner._(
      {required this.id, required this.name})
      : super._();
  @override
  AuthRegistrationCategories200ResponseDataInner rebuild(
          void Function(AuthRegistrationCategories200ResponseDataInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthRegistrationCategories200ResponseDataInnerBuilder toBuilder() =>
      AuthRegistrationCategories200ResponseDataInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthRegistrationCategories200ResponseDataInner &&
        id == other.id &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AuthRegistrationCategories200ResponseDataInner')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class AuthRegistrationCategories200ResponseDataInnerBuilder
    implements
        Builder<AuthRegistrationCategories200ResponseDataInner,
            AuthRegistrationCategories200ResponseDataInnerBuilder> {
  _$AuthRegistrationCategories200ResponseDataInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  AuthRegistrationCategories200ResponseDataInnerBuilder() {
    AuthRegistrationCategories200ResponseDataInner._defaults(this);
  }

  AuthRegistrationCategories200ResponseDataInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthRegistrationCategories200ResponseDataInner other) {
    _$v = other as _$AuthRegistrationCategories200ResponseDataInner;
  }

  @override
  void update(
      void Function(AuthRegistrationCategories200ResponseDataInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthRegistrationCategories200ResponseDataInner build() => _build();

  _$AuthRegistrationCategories200ResponseDataInner _build() {
    final _$result = _$v ??
        _$AuthRegistrationCategories200ResponseDataInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AuthRegistrationCategories200ResponseDataInner', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'AuthRegistrationCategories200ResponseDataInner', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
