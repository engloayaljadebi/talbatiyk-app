// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_contact_value.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RegisterRequestContactValue extends RegisterRequestContactValue {
  @override
  final AnyOf anyOf;

  factory _$RegisterRequestContactValue(
          [void Function(RegisterRequestContactValueBuilder)? updates]) =>
      (RegisterRequestContactValueBuilder()..update(updates))._build();

  _$RegisterRequestContactValue._({required this.anyOf}) : super._();
  @override
  RegisterRequestContactValue rebuild(
          void Function(RegisterRequestContactValueBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegisterRequestContactValueBuilder toBuilder() =>
      RegisterRequestContactValueBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterRequestContactValue && anyOf == other.anyOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, anyOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RegisterRequestContactValue')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class RegisterRequestContactValueBuilder
    implements
        Builder<RegisterRequestContactValue,
            RegisterRequestContactValueBuilder> {
  _$RegisterRequestContactValue? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  RegisterRequestContactValueBuilder() {
    RegisterRequestContactValue._defaults(this);
  }

  RegisterRequestContactValueBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegisterRequestContactValue other) {
    _$v = other as _$RegisterRequestContactValue;
  }

  @override
  void update(void Function(RegisterRequestContactValueBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterRequestContactValue build() => _build();

  _$RegisterRequestContactValue _build() {
    final _$result = _$v ??
        _$RegisterRequestContactValue._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'RegisterRequestContactValue', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
