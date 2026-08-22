// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_follow_store422_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierFollowStore422Response extends SupplierFollowStore422Response {
  @override
  final String message;
  @override
  final SupplierFollowStore422ResponseErrors errors;

  factory _$SupplierFollowStore422Response(
          [void Function(SupplierFollowStore422ResponseBuilder)? updates]) =>
      (SupplierFollowStore422ResponseBuilder()..update(updates))._build();

  _$SupplierFollowStore422Response._(
      {required this.message, required this.errors})
      : super._();
  @override
  SupplierFollowStore422Response rebuild(
          void Function(SupplierFollowStore422ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierFollowStore422ResponseBuilder toBuilder() =>
      SupplierFollowStore422ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierFollowStore422Response &&
        message == other.message &&
        errors == other.errors;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, errors.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SupplierFollowStore422Response')
          ..add('message', message)
          ..add('errors', errors))
        .toString();
  }
}

class SupplierFollowStore422ResponseBuilder
    implements
        Builder<SupplierFollowStore422Response,
            SupplierFollowStore422ResponseBuilder> {
  _$SupplierFollowStore422Response? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  SupplierFollowStore422ResponseErrorsBuilder? _errors;
  SupplierFollowStore422ResponseErrorsBuilder get errors =>
      _$this._errors ??= SupplierFollowStore422ResponseErrorsBuilder();
  set errors(SupplierFollowStore422ResponseErrorsBuilder? errors) =>
      _$this._errors = errors;

  SupplierFollowStore422ResponseBuilder() {
    SupplierFollowStore422Response._defaults(this);
  }

  SupplierFollowStore422ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _errors = $v.errors.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierFollowStore422Response other) {
    _$v = other as _$SupplierFollowStore422Response;
  }

  @override
  void update(void Function(SupplierFollowStore422ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierFollowStore422Response build() => _build();

  _$SupplierFollowStore422Response _build() {
    _$SupplierFollowStore422Response _$result;
    try {
      _$result = _$v ??
          _$SupplierFollowStore422Response._(
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'SupplierFollowStore422Response', 'message'),
            errors: errors.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'errors';
        errors.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SupplierFollowStore422Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
