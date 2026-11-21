// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_follow_show200_response_data.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SupplierFollowShow200ResponseData
    extends SupplierFollowShow200ResponseData {
  @override
  final String businessId;
  @override
  final bool isFollowing;

  factory _$SupplierFollowShow200ResponseData(
          [void Function(SupplierFollowShow200ResponseDataBuilder)? updates]) =>
      (SupplierFollowShow200ResponseDataBuilder()..update(updates))._build();

  _$SupplierFollowShow200ResponseData._(
      {required this.businessId, required this.isFollowing})
      : super._();
  @override
  SupplierFollowShow200ResponseData rebuild(
          void Function(SupplierFollowShow200ResponseDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SupplierFollowShow200ResponseDataBuilder toBuilder() =>
      SupplierFollowShow200ResponseDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SupplierFollowShow200ResponseData &&
        businessId == other.businessId &&
        isFollowing == other.isFollowing;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, businessId.hashCode);
    _$hash = $jc(_$hash, isFollowing.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SupplierFollowShow200ResponseData')
          ..add('businessId', businessId)
          ..add('isFollowing', isFollowing))
        .toString();
  }
}

class SupplierFollowShow200ResponseDataBuilder
    implements
        Builder<SupplierFollowShow200ResponseData,
            SupplierFollowShow200ResponseDataBuilder> {
  _$SupplierFollowShow200ResponseData? _$v;

  String? _businessId;
  String? get businessId => _$this._businessId;
  set businessId(String? businessId) => _$this._businessId = businessId;

  bool? _isFollowing;
  bool? get isFollowing => _$this._isFollowing;
  set isFollowing(bool? isFollowing) => _$this._isFollowing = isFollowing;

  SupplierFollowShow200ResponseDataBuilder() {
    SupplierFollowShow200ResponseData._defaults(this);
  }

  SupplierFollowShow200ResponseDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _businessId = $v.businessId;
      _isFollowing = $v.isFollowing;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SupplierFollowShow200ResponseData other) {
    _$v = other as _$SupplierFollowShow200ResponseData;
  }

  @override
  void update(
      void Function(SupplierFollowShow200ResponseDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SupplierFollowShow200ResponseData build() => _build();

  _$SupplierFollowShow200ResponseData _build() {
    final _$result = _$v ??
        _$SupplierFollowShow200ResponseData._(
          businessId: BuiltValueNullFieldError.checkNotNull(
              businessId, r'SupplierFollowShow200ResponseData', 'businessId'),
          isFollowing: BuiltValueNullFieldError.checkNotNull(
              isFollowing, r'SupplierFollowShow200ResponseData', 'isFollowing'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
