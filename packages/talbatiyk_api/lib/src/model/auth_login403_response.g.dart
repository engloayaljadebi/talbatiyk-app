// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_login403_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthLogin403Response extends AuthLogin403Response {
  @override
  final String message;

  factory _$AuthLogin403Response(
          [void Function(AuthLogin403ResponseBuilder)? updates]) =>
      (AuthLogin403ResponseBuilder()..update(updates))._build();

  _$AuthLogin403Response._({required this.message}) : super._();
  @override
  AuthLogin403Response rebuild(
          void Function(AuthLogin403ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthLogin403ResponseBuilder toBuilder() =>
      AuthLogin403ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthLogin403Response && message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthLogin403Response')
          ..add('message', message))
        .toString();
  }
}

class AuthLogin403ResponseBuilder
    implements Builder<AuthLogin403Response, AuthLogin403ResponseBuilder> {
  _$AuthLogin403Response? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  AuthLogin403ResponseBuilder() {
    AuthLogin403Response._defaults(this);
  }

  AuthLogin403ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthLogin403Response other) {
    _$v = other as _$AuthLogin403Response;
  }

  @override
  void update(void Function(AuthLogin403ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthLogin403Response build() => _build();

  _$AuthLogin403Response _build() {
    final _$result = _$v ??
        _$AuthLogin403Response._(
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'AuthLogin403Response', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
