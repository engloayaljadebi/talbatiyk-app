// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_me403_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthMe403ResponseCodeEnum _$authMe403ResponseCodeEnum_ACCOUNT_INACTIVE =
    const AuthMe403ResponseCodeEnum._('ACCOUNT_INACTIVE');

AuthMe403ResponseCodeEnum _$authMe403ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'ACCOUNT_INACTIVE':
      return _$authMe403ResponseCodeEnum_ACCOUNT_INACTIVE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AuthMe403ResponseCodeEnum> _$authMe403ResponseCodeEnumValues =
    BuiltSet<AuthMe403ResponseCodeEnum>(const <AuthMe403ResponseCodeEnum>[
  _$authMe403ResponseCodeEnum_ACCOUNT_INACTIVE,
]);

Serializer<AuthMe403ResponseCodeEnum> _$authMe403ResponseCodeEnumSerializer =
    _$AuthMe403ResponseCodeEnumSerializer();

class _$AuthMe403ResponseCodeEnumSerializer
    implements PrimitiveSerializer<AuthMe403ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ACCOUNT_INACTIVE': 'ACCOUNT_INACTIVE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ACCOUNT_INACTIVE': 'ACCOUNT_INACTIVE',
  };

  @override
  final Iterable<Type> types = const <Type>[AuthMe403ResponseCodeEnum];
  @override
  final String wireName = 'AuthMe403ResponseCodeEnum';

  @override
  Object serialize(Serializers serializers, AuthMe403ResponseCodeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AuthMe403ResponseCodeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AuthMe403ResponseCodeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AuthMe403Response extends AuthMe403Response {
  @override
  final String message;
  @override
  final AuthMe403ResponseCodeEnum code;

  factory _$AuthMe403Response(
          [void Function(AuthMe403ResponseBuilder)? updates]) =>
      (AuthMe403ResponseBuilder()..update(updates))._build();

  _$AuthMe403Response._({required this.message, required this.code})
      : super._();
  @override
  AuthMe403Response rebuild(void Function(AuthMe403ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthMe403ResponseBuilder toBuilder() =>
      AuthMe403ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthMe403Response &&
        message == other.message &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthMe403Response')
          ..add('message', message)
          ..add('code', code))
        .toString();
  }
}

class AuthMe403ResponseBuilder
    implements Builder<AuthMe403Response, AuthMe403ResponseBuilder> {
  _$AuthMe403Response? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  AuthMe403ResponseCodeEnum? _code;
  AuthMe403ResponseCodeEnum? get code => _$this._code;
  set code(AuthMe403ResponseCodeEnum? code) => _$this._code = code;

  AuthMe403ResponseBuilder() {
    AuthMe403Response._defaults(this);
  }

  AuthMe403ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthMe403Response other) {
    _$v = other as _$AuthMe403Response;
  }

  @override
  void update(void Function(AuthMe403ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthMe403Response build() => _build();

  _$AuthMe403Response _build() {
    final _$result = _$v ??
        _$AuthMe403Response._(
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'AuthMe403Response', 'message'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'AuthMe403Response', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
