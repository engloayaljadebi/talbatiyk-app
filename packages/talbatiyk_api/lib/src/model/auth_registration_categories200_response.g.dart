// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_registration_categories200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthRegistrationCategories200Response
    extends AuthRegistrationCategories200Response {
  @override
  final BuiltList<AuthRegistrationCategories200ResponseDataInner> data;

  factory _$AuthRegistrationCategories200Response(
          [void Function(AuthRegistrationCategories200ResponseBuilder)?
              updates]) =>
      (AuthRegistrationCategories200ResponseBuilder()..update(updates))
          ._build();

  _$AuthRegistrationCategories200Response._({required this.data}) : super._();
  @override
  AuthRegistrationCategories200Response rebuild(
          void Function(AuthRegistrationCategories200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthRegistrationCategories200ResponseBuilder toBuilder() =>
      AuthRegistrationCategories200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthRegistrationCategories200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(
            r'AuthRegistrationCategories200Response')
          ..add('data', data))
        .toString();
  }
}

class AuthRegistrationCategories200ResponseBuilder
    implements
        Builder<AuthRegistrationCategories200Response,
            AuthRegistrationCategories200ResponseBuilder> {
  _$AuthRegistrationCategories200Response? _$v;

  ListBuilder<AuthRegistrationCategories200ResponseDataInner>? _data;
  ListBuilder<AuthRegistrationCategories200ResponseDataInner> get data =>
      _$this._data ??=
          ListBuilder<AuthRegistrationCategories200ResponseDataInner>();
  set data(ListBuilder<AuthRegistrationCategories200ResponseDataInner>? data) =>
      _$this._data = data;

  AuthRegistrationCategories200ResponseBuilder() {
    AuthRegistrationCategories200Response._defaults(this);
  }

  AuthRegistrationCategories200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthRegistrationCategories200Response other) {
    _$v = other as _$AuthRegistrationCategories200Response;
  }

  @override
  void update(
      void Function(AuthRegistrationCategories200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthRegistrationCategories200Response build() => _build();

  _$AuthRegistrationCategories200Response _build() {
    _$AuthRegistrationCategories200Response _$result;
    try {
      _$result = _$v ??
          _$AuthRegistrationCategories200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuthRegistrationCategories200Response',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
