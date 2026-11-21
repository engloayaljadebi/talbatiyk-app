// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_login200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthLogin200ResponseDataTokenTypeEnum
    _$authLogin200ResponseDataTokenTypeEnum_bearer =
    const AuthLogin200ResponseDataTokenTypeEnum._('bearer');

AuthLogin200ResponseDataTokenTypeEnum
    _$authLogin200ResponseDataTokenTypeEnumValueOf(String name) {
  switch (name) {
    case 'bearer':
      return _$authLogin200ResponseDataTokenTypeEnum_bearer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AuthLogin200ResponseDataTokenTypeEnum>
    _$authLogin200ResponseDataTokenTypeEnumValues = BuiltSet<
        AuthLogin200ResponseDataTokenTypeEnum>(const <AuthLogin200ResponseDataTokenTypeEnum>[
  _$authLogin200ResponseDataTokenTypeEnum_bearer,
]);

Serializer<AuthLogin200ResponseDataTokenTypeEnum>
    _$authLogin200ResponseDataTokenTypeEnumSerializer =
    _$AuthLogin200ResponseDataTokenTypeEnumSerializer();

class _$AuthLogin200ResponseDataTokenTypeEnumSerializer
    implements PrimitiveSerializer<AuthLogin200ResponseDataTokenTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'bearer': 'Bearer',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Bearer': 'bearer',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AuthLogin200ResponseDataTokenTypeEnum
  ];
  @override
  final String wireName = 'AuthLogin200ResponseDataTokenTypeEnum';

  @override
  Object serialize(
          Serializers serializers, AuthLogin200ResponseDataTokenTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AuthLogin200ResponseDataTokenTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AuthLogin200ResponseDataTokenTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AuthLogin200ResponseData extends AuthLogin200ResponseData {
  @override
  final UserResource user;
  @override
  final String accessToken;
  @override
  final AuthLogin200ResponseDataTokenTypeEnum tokenType;

  factory _$AuthLogin200ResponseData(
          [void Function(AuthLogin200ResponseDataBuilder)? updates]) =>
      (AuthLogin200ResponseDataBuilder()..update(updates))._build();

  _$AuthLogin200ResponseData._(
      {required this.user, required this.accessToken, required this.tokenType})
      : super._();
  @override
  AuthLogin200ResponseData rebuild(
          void Function(AuthLogin200ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthLogin200ResponseDataBuilder toBuilder() =>
      AuthLogin200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthLogin200ResponseData &&
        user == other.user &&
        accessToken == other.accessToken &&
        tokenType == other.tokenType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, tokenType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthLogin200ResponseData')
          ..add('user', user)
          ..add('accessToken', accessToken)
          ..add('tokenType', tokenType))
        .toString();
  }
}

class AuthLogin200ResponseDataBuilder
    implements
        Builder<AuthLogin200ResponseData, AuthLogin200ResponseDataBuilder> {
  _$AuthLogin200ResponseData? _$v;

  UserResourceBuilder? _user;
  UserResourceBuilder get user => _$this._user ??= UserResourceBuilder();
  set user(UserResourceBuilder? user) => _$this._user = user;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  AuthLogin200ResponseDataTokenTypeEnum? _tokenType;
  AuthLogin200ResponseDataTokenTypeEnum? get tokenType => _$this._tokenType;
  set tokenType(AuthLogin200ResponseDataTokenTypeEnum? tokenType) =>
      _$this._tokenType = tokenType;

  AuthLogin200ResponseDataBuilder() {
    AuthLogin200ResponseData._defaults(this);
  }

  AuthLogin200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user.toBuilder();
      _accessToken = $v.accessToken;
      _tokenType = $v.tokenType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthLogin200ResponseData other) {
    _$v = other as _$AuthLogin200ResponseData;
  }

  @override
  void update(void Function(AuthLogin200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthLogin200ResponseData build() => _build();

  _$AuthLogin200ResponseData _build() {
    _$AuthLogin200ResponseData _$result;
    try {
      _$result = _$v ??
          _$AuthLogin200ResponseData._(
            user: user.build(),
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'AuthLogin200ResponseData', 'accessToken'),
            tokenType: BuiltValueNullFieldError.checkNotNull(
                tokenType, r'AuthLogin200ResponseData', 'tokenType'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuthLogin200ResponseData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
