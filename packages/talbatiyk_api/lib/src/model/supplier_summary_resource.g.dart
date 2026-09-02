// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_summary_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierSummaryResource extends SupplierSummaryResource {
  @override
  final String id;
  @override
  final String name;

  factory _$SupplierSummaryResource(
          [void Function(SupplierSummaryResourceBuilder)? updates]) =>
      (SupplierSummaryResourceBuilder()..update(updates))._build();

  _$SupplierSummaryResource._({required this.id, required this.name})
      : super._();
  @override
  SupplierSummaryResource rebuild(
          void Function(SupplierSummaryResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierSummaryResourceBuilder toBuilder() =>
      SupplierSummaryResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierSummaryResource &&
        id == other.id &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SupplierSummaryResource')
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class SupplierSummaryResourceBuilder
    implements
        Builder<SupplierSummaryResource, SupplierSummaryResourceBuilder> {
  _$SupplierSummaryResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  SupplierSummaryResourceBuilder() {
    SupplierSummaryResource._defaults(this);
  }

  SupplierSummaryResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierSummaryResource other) {
    _$v = other as _$SupplierSummaryResource;
  }

  @override
  void update(void Function(SupplierSummaryResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierSummaryResource build() => _build();

  _$SupplierSummaryResource _build() {
    final _$result = _$v ??
        _$SupplierSummaryResource._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'SupplierSummaryResource', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'SupplierSummaryResource', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
