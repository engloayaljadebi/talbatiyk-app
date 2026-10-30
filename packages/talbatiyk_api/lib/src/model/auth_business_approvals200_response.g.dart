// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_business_approvals200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthBusinessApprovals200Response
    extends AuthBusinessApprovals200Response {
  @override
  final BuiltList<AuthBusinessApprovals200ResponseDataInner> data;

  factory _$AuthBusinessApprovals200Response(
          [void Function(AuthBusinessApprovals200ResponseBuilder)? updates]) =>
      (AuthBusinessApprovals200ResponseBuilder()..update(updates))._build();

  _$AuthBusinessApprovals200Response._({required this.data}) : super._();
  @override
  AuthBusinessApprovals200Response rebuild(
          void Function(AuthBusinessApprovals200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthBusinessApprovals200ResponseBuilder toBuilder() =>
      AuthBusinessApprovals200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthBusinessApprovals200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'AuthBusinessApprovals200Response')
          ..add('data', data))
        .toString();
  }
}

class AuthBusinessApprovals200ResponseBuilder
    implements
        Builder<AuthBusinessApprovals200Response,
            AuthBusinessApprovals200ResponseBuilder> {
  _$AuthBusinessApprovals200Response? _$v;

  ListBuilder<AuthBusinessApprovals200ResponseDataInner>? _data;
  ListBuilder<AuthBusinessApprovals200ResponseDataInner> get data =>
      _$this._data ??= ListBuilder<AuthBusinessApprovals200ResponseDataInner>();
  set data(ListBuilder<AuthBusinessApprovals200ResponseDataInner>? data) =>
      _$this._data = data;

  AuthBusinessApprovals200ResponseBuilder() {
    AuthBusinessApprovals200Response._defaults(this);
  }

  AuthBusinessApprovals200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthBusinessApprovals200Response other) {
    _$v = other as _$AuthBusinessApprovals200Response;
  }

  @override
  void update(void Function(AuthBusinessApprovals200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthBusinessApprovals200Response build() => _build();

  _$AuthBusinessApprovals200Response _build() {
    _$AuthBusinessApprovals200Response _$result;
    try {
      _$result = _$v ??
          _$AuthBusinessApprovals200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuthBusinessApprovals200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
