// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_business_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateBusinessRequest extends UpdateBusinessRequest {
  @override
  final String? name;
  @override
  final String? legalName;
  @override
  final String? description;

  factory _$UpdateBusinessRequest(
          [void Function(UpdateBusinessRequestBuilder)? updates]) =>
      (UpdateBusinessRequestBuilder()..update(updates))._build();

  _$UpdateBusinessRequest._({this.name, this.legalName, this.description})
      : super._();
  @override
  UpdateBusinessRequest rebuild(
          void Function(UpdateBusinessRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateBusinessRequestBuilder toBuilder() =>
      UpdateBusinessRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateBusinessRequest &&
        name == other.name &&
        legalName == other.legalName &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, legalName.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateBusinessRequest')
          ..add('name', name)
          ..add('legalName', legalName)
          ..add('description', description))
        .toString();
  }
}

class UpdateBusinessRequestBuilder
    implements Builder<UpdateBusinessRequest, UpdateBusinessRequestBuilder> {
  _$UpdateBusinessRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _legalName;
  String? get legalName => _$this._legalName;
  set legalName(String? legalName) => _$this._legalName = legalName;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  UpdateBusinessRequestBuilder() {
    UpdateBusinessRequest._defaults(this);
  }

  UpdateBusinessRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _legalName = $v.legalName;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateBusinessRequest other) {
    _$v = other as _$UpdateBusinessRequest;
  }

  @override
  void update(void Function(UpdateBusinessRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateBusinessRequest build() => _build();

  _$UpdateBusinessRequest _build() {
    final _$result = _$v ??
        _$UpdateBusinessRequest._(
          name: name,
          legalName: legalName,
          description: description,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
