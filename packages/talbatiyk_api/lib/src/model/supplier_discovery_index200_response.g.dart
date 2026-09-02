// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_discovery_index200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierDiscoveryIndex200Response
    extends SupplierDiscoveryIndex200Response {
  @override
  final BuiltList<SupplierSummaryResource> data;

  factory _$SupplierDiscoveryIndex200Response(
          [void Function(SupplierDiscoveryIndex200ResponseBuilder)? updates]) =>
      (SupplierDiscoveryIndex200ResponseBuilder()..update(updates))._build();

  _$SupplierDiscoveryIndex200Response._({required this.data}) : super._();
  @override
  SupplierDiscoveryIndex200Response rebuild(
          void Function(SupplierDiscoveryIndex200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierDiscoveryIndex200ResponseBuilder toBuilder() =>
      SupplierDiscoveryIndex200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierDiscoveryIndex200Response && data == other.data;
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
    return (newBuiltValueToStringHelper(r'SupplierDiscoveryIndex200Response')
          ..add('data', data))
        .toString();
  }
}

class SupplierDiscoveryIndex200ResponseBuilder
    implements
        Builder<SupplierDiscoveryIndex200Response,
            SupplierDiscoveryIndex200ResponseBuilder> {
  _$SupplierDiscoveryIndex200Response? _$v;

  ListBuilder<SupplierSummaryResource>? _data;
  ListBuilder<SupplierSummaryResource> get data =>
      _$this._data ??= ListBuilder<SupplierSummaryResource>();
  set data(ListBuilder<SupplierSummaryResource>? data) => _$this._data = data;

  SupplierDiscoveryIndex200ResponseBuilder() {
    SupplierDiscoveryIndex200Response._defaults(this);
  }

  SupplierDiscoveryIndex200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierDiscoveryIndex200Response other) {
    _$v = other as _$SupplierDiscoveryIndex200Response;
  }

  @override
  void update(
      void Function(SupplierDiscoveryIndex200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierDiscoveryIndex200Response build() => _build();

  _$SupplierDiscoveryIndex200Response _build() {
    _$SupplierDiscoveryIndex200Response _$result;
    try {
      _$result = _$v ??
          _$SupplierDiscoveryIndex200Response._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SupplierDiscoveryIndex200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
