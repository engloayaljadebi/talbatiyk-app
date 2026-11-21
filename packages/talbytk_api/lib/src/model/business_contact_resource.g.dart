// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_contact_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusinessContactResource extends BusinessContactResource {
  @override
  final String id;
  @override
  final String type;
  @override
  final String value;
  @override
  final String? label;
  @override
  final bool isPrimary;
  @override
  final bool isVerified;
  @override
  final String? verifiedAt;

  factory _$BusinessContactResource(
          [void Function(BusinessContactResourceBuilder)? updates]) =>
      (BusinessContactResourceBuilder()..update(updates))._build();

  _$BusinessContactResource._(
      {required this.id,
      required this.type,
      required this.value,
      this.label,
      required this.isPrimary,
      required this.isVerified,
      this.verifiedAt})
      : super._();
  @override
  BusinessContactResource rebuild(
          void Function(BusinessContactResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusinessContactResourceBuilder toBuilder() =>
      BusinessContactResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusinessContactResource &&
        id == other.id &&
        type == other.type &&
        value == other.value &&
        label == other.label &&
        isPrimary == other.isPrimary &&
        isVerified == other.isVerified &&
        verifiedAt == other.verifiedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, isPrimary.hashCode);
    _$hash = $jc(_$hash, isVerified.hashCode);
    _$hash = $jc(_$hash, verifiedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BusinessContactResource')
          ..add('id', id)
          ..add('type', type)
          ..add('value', value)
          ..add('label', label)
          ..add('isPrimary', isPrimary)
          ..add('isVerified', isVerified)
          ..add('verifiedAt', verifiedAt))
        .toString();
  }
}

class BusinessContactResourceBuilder
    implements
        Builder<BusinessContactResource, BusinessContactResourceBuilder> {
  _$BusinessContactResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  bool? _isPrimary;
  bool? get isPrimary => _$this._isPrimary;
  set isPrimary(bool? isPrimary) => _$this._isPrimary = isPrimary;

  bool? _isVerified;
  bool? get isVerified => _$this._isVerified;
  set isVerified(bool? isVerified) => _$this._isVerified = isVerified;

  String? _verifiedAt;
  String? get verifiedAt => _$this._verifiedAt;
  set verifiedAt(String? verifiedAt) => _$this._verifiedAt = verifiedAt;

  BusinessContactResourceBuilder() {
    BusinessContactResource._defaults(this);
  }

  BusinessContactResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _type = $v.type;
      _value = $v.value;
      _label = $v.label;
      _isPrimary = $v.isPrimary;
      _isVerified = $v.isVerified;
      _verifiedAt = $v.verifiedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusinessContactResource other) {
    _$v = other as _$BusinessContactResource;
  }

  @override
  void update(void Function(BusinessContactResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusinessContactResource build() => _build();

  _$BusinessContactResource _build() {
    final _$result = _$v ??
        _$BusinessContactResource._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'BusinessContactResource', 'id'),
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'BusinessContactResource', 'type'),
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'BusinessContactResource', 'value'),
          label: label,
          isPrimary: BuiltValueNullFieldError.checkNotNull(
              isPrimary, r'BusinessContactResource', 'isPrimary'),
          isVerified: BuiltValueNullFieldError.checkNotNull(
              isVerified, r'BusinessContactResource', 'isVerified'),
          verifiedAt: verifiedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
