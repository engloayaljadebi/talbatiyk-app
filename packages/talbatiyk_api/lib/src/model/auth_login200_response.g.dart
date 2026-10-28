// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_login200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthLogin200Response extends AuthLogin200Response {
  @override
  final AuthLogin200ResponseData data;

  factory _$AuthLogin200Response(
          [void Function(AuthLogin200ResponseBuilder)? updates]) =>
      (AuthLogin200ResponseBuilder()..update(updates))._build();

  _$AuthLogin200Response._({required this.data}) : super._();
  @override
  AuthLogin200Response rebuild(
          void Function(AuthLogin200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthLogin200ResponseBuilder toBuilder() =>
      AuthLogin200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthLogin200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'AuthLogin200Response')
          ..add('data', data))
        .toString();
  }
}

class AuthLogin200ResponseBuilder
    implements Builder<AuthLogin200Response, AuthLogin200ResponseBuilder> {
  _$AuthLogin200Response? _$v;

  AuthLogin200ResponseDataBuilder? _data;
  AuthLogin200ResponseDataBuilder get data =>
      _$this._data ??= AuthLogin200ResponseDataBuilder();
  set data(AuthLogin200ResponseDataBuilder? data) => _$this._data = data;

  AuthLogin200ResponseBuilder() {
    AuthLogin200Response._defaults(this);
  }

  AuthLogin200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthLogin200Response other) {
    _$v = other as _$AuthLogin200Response;
  }

  @override
  void update(void Function(AuthLogin200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthLogin200Response build() => _build();

  _$AuthLogin200Response _build() {
    _$AuthLogin200Response _$result;
    try {
      _$result = _$v ??
          _$AuthLogin200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuthLogin200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
