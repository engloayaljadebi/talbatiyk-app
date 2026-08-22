// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_follow_store422_response_errors.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierFollowStore422ResponseErrors
    extends SupplierFollowStore422ResponseErrors {
  @override
  final BuiltList<String> businessId;

  factory _$SupplierFollowStore422ResponseErrors(
          [void Function(SupplierFollowStore422ResponseErrorsBuilder)?
              updates]) =>
      (SupplierFollowStore422ResponseErrorsBuilder()..update(updates))._build();

  _$SupplierFollowStore422ResponseErrors._({required this.businessId})
      : super._();
  @override
  SupplierFollowStore422ResponseErrors rebuild(
          void Function(SupplierFollowStore422ResponseErrorsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierFollowStore422ResponseErrorsBuilder toBuilder() =>
      SupplierFollowStore422ResponseErrorsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierFollowStore422ResponseErrors &&
        businessId == other.businessId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, businessId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SupplierFollowStore422ResponseErrors')
          ..add('businessId', businessId))
        .toString();
  }
}

class SupplierFollowStore422ResponseErrorsBuilder
    implements
        Builder<SupplierFollowStore422ResponseErrors,
            SupplierFollowStore422ResponseErrorsBuilder> {
  _$SupplierFollowStore422ResponseErrors? _$v;

  ListBuilder<String>? _businessId;
  ListBuilder<String> get businessId =>
      _$this._businessId ??= ListBuilder<String>();
  set businessId(ListBuilder<String>? businessId) =>
      _$this._businessId = businessId;

  SupplierFollowStore422ResponseErrorsBuilder() {
    SupplierFollowStore422ResponseErrors._defaults(this);
  }

  SupplierFollowStore422ResponseErrorsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _businessId = $v.businessId.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierFollowStore422ResponseErrors other) {
    _$v = other as _$SupplierFollowStore422ResponseErrors;
  }

  @override
  void update(
      void Function(SupplierFollowStore422ResponseErrorsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierFollowStore422ResponseErrors build() => _build();

  _$SupplierFollowStore422ResponseErrors _build() {
    _$SupplierFollowStore422ResponseErrors _$result;
    try {
      _$result = _$v ??
          _$SupplierFollowStore422ResponseErrors._(
            businessId: businessId.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'businessId';
        businessId.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SupplierFollowStore422ResponseErrors',
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
