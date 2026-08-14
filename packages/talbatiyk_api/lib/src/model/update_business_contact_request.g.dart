// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_business_contact_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateBusinessContactRequest extends UpdateBusinessContactRequest {
  @override
  final String? value;
  @override
  final String? label;

  factory _$UpdateBusinessContactRequest(
          [void Function(UpdateBusinessContactRequestBuilder)? updates]) =>
      (UpdateBusinessContactRequestBuilder()..update(updates))._build();

  _$UpdateBusinessContactRequest._({this.value, this.label}) : super._();
  @override
  UpdateBusinessContactRequest rebuild(
          void Function(UpdateBusinessContactRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateBusinessContactRequestBuilder toBuilder() =>
      UpdateBusinessContactRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateBusinessContactRequest &&
        value == other.value &&
        label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateBusinessContactRequest')
          ..add('value', value)
          ..add('label', label))
        .toString();
  }
}

class UpdateBusinessContactRequestBuilder
    implements
        Builder<UpdateBusinessContactRequest,
            UpdateBusinessContactRequestBuilder> {
  _$UpdateBusinessContactRequest? _$v;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  UpdateBusinessContactRequestBuilder() {
    UpdateBusinessContactRequest._defaults(this);
  }

  UpdateBusinessContactRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _value = $v.value;
      _label = $v.label;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateBusinessContactRequest other) {
    _$v = other as _$UpdateBusinessContactRequest;
  }

  @override
  void update(void Function(UpdateBusinessContactRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateBusinessContactRequest build() => _build();

  _$UpdateBusinessContactRequest _build() {
    final _$result = _$v ??
        _$UpdateBusinessContactRequest._(
          value: value,
          label: label,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
