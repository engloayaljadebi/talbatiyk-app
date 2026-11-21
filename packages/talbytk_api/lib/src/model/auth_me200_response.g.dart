// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_me200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthMe200Response extends AuthMe200Response {
  @override
  final UserResource data;

  factory _$AuthMe200Response(
          [void Function(AuthMe200ResponseBuilder)? updates]) =>
      (AuthMe200ResponseBuilder()..update(updates))._build();

  _$AuthMe200Response._({required this.data}) : super._();
  @override
  AuthMe200Response rebuild(void Function(AuthMe200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthMe200ResponseBuilder toBuilder() =>
      AuthMe200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthMe200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'AuthMe200Response')
          ..add('data', data))
        .toString();
  }
}

class AuthMe200ResponseBuilder
    implements Builder<AuthMe200Response, AuthMe200ResponseBuilder> {
  _$AuthMe200Response? _$v;

  UserResourceBuilder? _data;
  UserResourceBuilder get data => _$this._data ??= UserResourceBuilder();
  set data(UserResourceBuilder? data) => _$this._data = data;

  AuthMe200ResponseBuilder() {
    AuthMe200Response._defaults(this);
  }

  AuthMe200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthMe200Response other) {
    _$v = other as _$AuthMe200Response;
  }

  @override
  void update(void Function(AuthMe200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthMe200Response build() => _build();

  _$AuthMe200Response _build() {
    _$AuthMe200Response _$result;
    try {
      _$result = _$v ??
          _$AuthMe200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuthMe200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
