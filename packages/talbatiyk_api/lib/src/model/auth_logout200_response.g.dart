// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_logout200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthLogout200ResponseMessageEnum
    _$authLogout200ResponseMessageEnum_period =
    const AuthLogout200ResponseMessageEnum._('period');

AuthLogout200ResponseMessageEnum _$authLogout200ResponseMessageEnumValueOf(
    String name) {
  switch (name) {
    case 'period':
      return _$authLogout200ResponseMessageEnum_period;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AuthLogout200ResponseMessageEnum>
    _$authLogout200ResponseMessageEnumValues = BuiltSet<
        AuthLogout200ResponseMessageEnum>(const <AuthLogout200ResponseMessageEnum>[
  _$authLogout200ResponseMessageEnum_period,
]);

Serializer<AuthLogout200ResponseMessageEnum>
    _$authLogout200ResponseMessageEnumSerializer =
    _$AuthLogout200ResponseMessageEnumSerializer();

class _$AuthLogout200ResponseMessageEnumSerializer
    implements PrimitiveSerializer<AuthLogout200ResponseMessageEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'period': 'تم تسجيل الخروج بنجاح.',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'تم تسجيل الخروج بنجاح.': 'period',
  };

  @override
  final Iterable<Type> types = const <Type>[AuthLogout200ResponseMessageEnum];
  @override
  final String wireName = 'AuthLogout200ResponseMessageEnum';

  @override
  Object serialize(
          Serializers serializers, AuthLogout200ResponseMessageEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AuthLogout200ResponseMessageEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AuthLogout200ResponseMessageEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AuthLogout200Response extends AuthLogout200Response {
  @override
  final AuthLogout200ResponseMessageEnum message;

  factory _$AuthLogout200Response(
          [void Function(AuthLogout200ResponseBuilder)? updates]) =>
      (AuthLogout200ResponseBuilder()..update(updates))._build();

  _$AuthLogout200Response._({required this.message}) : super._();
  @override
  AuthLogout200Response rebuild(
          void Function(AuthLogout200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthLogout200ResponseBuilder toBuilder() =>
      AuthLogout200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthLogout200Response && message == other.message;
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
    return (newBuiltValueToStringHelper(r'AuthLogout200Response')
          ..add('message', message))
        .toString();
  }
}

class AuthLogout200ResponseBuilder
    implements Builder<AuthLogout200Response, AuthLogout200ResponseBuilder> {
  _$AuthLogout200Response? _$v;

  AuthLogout200ResponseMessageEnum? _message;
  AuthLogout200ResponseMessageEnum? get message => _$this._message;
  set message(AuthLogout200ResponseMessageEnum? message) =>
      _$this._message = message;

  AuthLogout200ResponseBuilder() {
    AuthLogout200Response._defaults(this);
  }

  AuthLogout200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthLogout200Response other) {
    _$v = other as _$AuthLogout200Response;
  }

  @override
  void update(void Function(AuthLogout200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthLogout200Response build() => _build();

  _$AuthLogout200Response _build() {
    final _$result = _$v ??
        _$AuthLogout200Response._(
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'AuthLogout200Response', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
