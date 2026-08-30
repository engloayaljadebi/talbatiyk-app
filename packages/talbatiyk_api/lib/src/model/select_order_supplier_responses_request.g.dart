// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'select_order_supplier_responses_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SelectOrderSupplierResponsesRequest
    extends SelectOrderSupplierResponsesRequest {
  @override
  final int expectedVersion;
  @override
  final BuiltList<SelectOrderSupplierResponsesRequestSelectionsInner>
      selections;

  factory _$SelectOrderSupplierResponsesRequest(
          [void Function(SelectOrderSupplierResponsesRequestBuilder)?
              updates]) =>
      (SelectOrderSupplierResponsesRequestBuilder()..update(updates))._build();

  _$SelectOrderSupplierResponsesRequest._(
      {required this.expectedVersion, required this.selections})
      : super._();
  @override
  SelectOrderSupplierResponsesRequest rebuild(
          void Function(SelectOrderSupplierResponsesRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SelectOrderSupplierResponsesRequestBuilder toBuilder() =>
      SelectOrderSupplierResponsesRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SelectOrderSupplierResponsesRequest &&
        expectedVersion == other.expectedVersion &&
        selections == other.selections;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedVersion.hashCode);
    _$hash = $jc(_$hash, selections.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SelectOrderSupplierResponsesRequest')
          ..add('expectedVersion', expectedVersion)
          ..add('selections', selections))
        .toString();
  }
}

class SelectOrderSupplierResponsesRequestBuilder
    implements
        Builder<SelectOrderSupplierResponsesRequest,
            SelectOrderSupplierResponsesRequestBuilder> {
  _$SelectOrderSupplierResponsesRequest? _$v;

  int? _expectedVersion;
  int? get expectedVersion => _$this._expectedVersion;
  set expectedVersion(int? expectedVersion) =>
      _$this._expectedVersion = expectedVersion;

  ListBuilder<SelectOrderSupplierResponsesRequestSelectionsInner>? _selections;
  ListBuilder<SelectOrderSupplierResponsesRequestSelectionsInner>
      get selections => _$this._selections ??=
          ListBuilder<SelectOrderSupplierResponsesRequestSelectionsInner>();
  set selections(
          ListBuilder<SelectOrderSupplierResponsesRequestSelectionsInner>?
              selections) =>
      _$this._selections = selections;

  SelectOrderSupplierResponsesRequestBuilder() {
    SelectOrderSupplierResponsesRequest._defaults(this);
  }

  SelectOrderSupplierResponsesRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedVersion = $v.expectedVersion;
      _selections = $v.selections.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SelectOrderSupplierResponsesRequest other) {
    _$v = other as _$SelectOrderSupplierResponsesRequest;
  }

  @override
  void update(
      void Function(SelectOrderSupplierResponsesRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SelectOrderSupplierResponsesRequest build() => _build();

  _$SelectOrderSupplierResponsesRequest _build() {
    _$SelectOrderSupplierResponsesRequest _$result;
    try {
      _$result = _$v ??
          _$SelectOrderSupplierResponsesRequest._(
            expectedVersion: BuiltValueNullFieldError.checkNotNull(
                expectedVersion,
                r'SelectOrderSupplierResponsesRequest',
                'expectedVersion'),
            selections: selections.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'selections';
        selections.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'SelectOrderSupplierResponsesRequest',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
