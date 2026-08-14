// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RegisterRequestContactTypeEnum _$registerRequestContactTypeEnum_phone =
    const RegisterRequestContactTypeEnum._('phone');
const RegisterRequestContactTypeEnum _$registerRequestContactTypeEnum_email =
    const RegisterRequestContactTypeEnum._('email');

RegisterRequestContactTypeEnum _$registerRequestContactTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'phone':
      return _$registerRequestContactTypeEnum_phone;
    case 'email':
      return _$registerRequestContactTypeEnum_email;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RegisterRequestContactTypeEnum>
    _$registerRequestContactTypeEnumValues = BuiltSet<
        RegisterRequestContactTypeEnum>(const <RegisterRequestContactTypeEnum>[
  _$registerRequestContactTypeEnum_phone,
  _$registerRequestContactTypeEnum_email,
]);

Serializer<RegisterRequestContactTypeEnum>
    _$registerRequestContactTypeEnumSerializer =
    _$RegisterRequestContactTypeEnumSerializer();

class _$RegisterRequestContactTypeEnumSerializer
    implements PrimitiveSerializer<RegisterRequestContactTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'phone': 'phone',
    'email': 'email',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'phone': 'phone',
    'email': 'email',
  };

  @override
  final Iterable<Type> types = const <Type>[RegisterRequestContactTypeEnum];
  @override
  final String wireName = 'RegisterRequestContactTypeEnum';

  @override
  Object serialize(
          Serializers serializers, RegisterRequestContactTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RegisterRequestContactTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RegisterRequestContactTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RegisterRequest extends RegisterRequest {
  @override
  final String username;
  @override
  final String displayName;
  @override
  final String password;
  @override
  final RegisterRequestContactTypeEnum contactType;
  @override
  final RegisterRequestContactValue contactValue;
  @override
  final String deviceName;
  @override
  final String passwordConfirmation;

  factory _$RegisterRequest([void Function(RegisterRequestBuilder)? updates]) =>
      (RegisterRequestBuilder()..update(updates))._build();

  _$RegisterRequest._(
      {required this.username,
      required this.displayName,
      required this.password,
      required this.contactType,
      required this.contactValue,
      required this.deviceName,
      required this.passwordConfirmation})
      : super._();
  @override
  RegisterRequest rebuild(void Function(RegisterRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegisterRequestBuilder toBuilder() => RegisterRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterRequest &&
        username == other.username &&
        displayName == other.displayName &&
        password == other.password &&
        contactType == other.contactType &&
        contactValue == other.contactValue &&
        deviceName == other.deviceName &&
        passwordConfirmation == other.passwordConfirmation;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, contactType.hashCode);
    _$hash = $jc(_$hash, contactValue.hashCode);
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jc(_$hash, passwordConfirmation.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RegisterRequest')
          ..add('username', username)
          ..add('displayName', displayName)
          ..add('password', password)
          ..add('contactType', contactType)
          ..add('contactValue', contactValue)
          ..add('deviceName', deviceName)
          ..add('passwordConfirmation', passwordConfirmation))
        .toString();
  }
}

class RegisterRequestBuilder
    implements Builder<RegisterRequest, RegisterRequestBuilder> {
  _$RegisterRequest? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  RegisterRequestContactTypeEnum? _contactType;
  RegisterRequestContactTypeEnum? get contactType => _$this._contactType;
  set contactType(RegisterRequestContactTypeEnum? contactType) =>
      _$this._contactType = contactType;

  RegisterRequestContactValueBuilder? _contactValue;
  RegisterRequestContactValueBuilder get contactValue =>
      _$this._contactValue ??= RegisterRequestContactValueBuilder();
  set contactValue(RegisterRequestContactValueBuilder? contactValue) =>
      _$this._contactValue = contactValue;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  String? _passwordConfirmation;
  String? get passwordConfirmation => _$this._passwordConfirmation;
  set passwordConfirmation(String? passwordConfirmation) =>
      _$this._passwordConfirmation = passwordConfirmation;

  RegisterRequestBuilder() {
    RegisterRequest._defaults(this);
  }

  RegisterRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _displayName = $v.displayName;
      _password = $v.password;
      _contactType = $v.contactType;
      _contactValue = $v.contactValue.toBuilder();
      _deviceName = $v.deviceName;
      _passwordConfirmation = $v.passwordConfirmation;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegisterRequest other) {
    _$v = other as _$RegisterRequest;
  }

  @override
  void update(void Function(RegisterRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterRequest build() => _build();

  _$RegisterRequest _build() {
    _$RegisterRequest _$result;
    try {
      _$result = _$v ??
          _$RegisterRequest._(
            username: BuiltValueNullFieldError.checkNotNull(
                username, r'RegisterRequest', 'username'),
            displayName: BuiltValueNullFieldError.checkNotNull(
                displayName, r'RegisterRequest', 'displayName'),
            password: BuiltValueNullFieldError.checkNotNull(
                password, r'RegisterRequest', 'password'),
            contactType: BuiltValueNullFieldError.checkNotNull(
                contactType, r'RegisterRequest', 'contactType'),
            contactValue: contactValue.build(),
            deviceName: BuiltValueNullFieldError.checkNotNull(
                deviceName, r'RegisterRequest', 'deviceName'),
            passwordConfirmation: BuiltValueNullFieldError.checkNotNull(
                passwordConfirmation,
                r'RegisterRequest',
                'passwordConfirmation'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'contactValue';
        contactValue.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RegisterRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
