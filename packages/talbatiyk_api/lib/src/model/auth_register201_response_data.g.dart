// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_register201_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AuthRegister201ResponseDataTokenTypeEnum
    _$authRegister201ResponseDataTokenTypeEnum_bearer =
    const AuthRegister201ResponseDataTokenTypeEnum._('bearer');

AuthRegister201ResponseDataTokenTypeEnum
    _$authRegister201ResponseDataTokenTypeEnumValueOf(String name) {
  switch (name) {
    case 'bearer':
      return _$authRegister201ResponseDataTokenTypeEnum_bearer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AuthRegister201ResponseDataTokenTypeEnum>
    _$authRegister201ResponseDataTokenTypeEnumValues = BuiltSet<
        AuthRegister201ResponseDataTokenTypeEnum>(const <AuthRegister201ResponseDataTokenTypeEnum>[
  _$authRegister201ResponseDataTokenTypeEnum_bearer,
]);

Serializer<AuthRegister201ResponseDataTokenTypeEnum>
    _$authRegister201ResponseDataTokenTypeEnumSerializer =
    _$AuthRegister201ResponseDataTokenTypeEnumSerializer();

class _$AuthRegister201ResponseDataTokenTypeEnumSerializer
    implements PrimitiveSerializer<AuthRegister201ResponseDataTokenTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'bearer': 'Bearer',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Bearer': 'bearer',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AuthRegister201ResponseDataTokenTypeEnum
  ];
  @override
  final String wireName = 'AuthRegister201ResponseDataTokenTypeEnum';

  @override
  Object serialize(Serializers serializers,
          AuthRegister201ResponseDataTokenTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AuthRegister201ResponseDataTokenTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AuthRegister201ResponseDataTokenTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AuthRegister201ResponseData extends AuthRegister201ResponseData {
  @override
  final UserResource user;
  @override
  final String accessToken;
  @override
  final AuthRegister201ResponseDataTokenTypeEnum tokenType;

  factory _$AuthRegister201ResponseData(
          [void Function(AuthRegister201ResponseDataBuilder)? updates]) =>
      (AuthRegister201ResponseDataBuilder()..update(updates))._build();

  _$AuthRegister201ResponseData._(
      {required this.user, required this.accessToken, required this.tokenType})
      : super._();
  @override
  AuthRegister201ResponseData rebuild(
          void Function(AuthRegister201ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthRegister201ResponseDataBuilder toBuilder() =>
      AuthRegister201ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthRegister201ResponseData &&
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
    return (newBuiltValueToStringHelper(r'AuthRegister201ResponseData')
          ..add('user', user)
          ..add('accessToken', accessToken)
          ..add('tokenType', tokenType))
        .toString();
  }
}

class AuthRegister201ResponseDataBuilder
    implements
        Builder<AuthRegister201ResponseData,
            AuthRegister201ResponseDataBuilder> {
  _$AuthRegister201ResponseData? _$v;

  UserResourceBuilder? _user;
  UserResourceBuilder get user => _$this._user ??= UserResourceBuilder();
  set user(UserResourceBuilder? user) => _$this._user = user;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  AuthRegister201ResponseDataTokenTypeEnum? _tokenType;
  AuthRegister201ResponseDataTokenTypeEnum? get tokenType => _$this._tokenType;
  set tokenType(AuthRegister201ResponseDataTokenTypeEnum? tokenType) =>
      _$this._tokenType = tokenType;

  AuthRegister201ResponseDataBuilder() {
    AuthRegister201ResponseData._defaults(this);
  }

  AuthRegister201ResponseDataBuilder get _$this {
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
  void replace(AuthRegister201ResponseData other) {
    _$v = other as _$AuthRegister201ResponseData;
  }

  @override
  void update(void Function(AuthRegister201ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthRegister201ResponseData build() => _build();

  _$AuthRegister201ResponseData _build() {
    _$AuthRegister201ResponseData _$result;
    try {
      _$result = _$v ??
          _$AuthRegister201ResponseData._(
            user: user.build(),
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'AuthRegister201ResponseData', 'accessToken'),
            tokenType: BuiltValueNullFieldError.checkNotNull(
                tokenType, r'AuthRegister201ResponseData', 'tokenType'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuthRegister201ResponseData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
