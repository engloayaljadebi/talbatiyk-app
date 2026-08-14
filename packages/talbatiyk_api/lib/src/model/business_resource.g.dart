// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_resource.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BusinessResource extends BusinessResource {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? legalName;
  @override
  final String? description;
  @override
  final String status;
  @override
  final BuiltList<JsonObject?>? capabilities;
  @override
  final BusinessLocationResource? primaryLocation;
  @override
  final BusinessContactResource? primaryContact;
  @override
  final BusinessResourceMembership? membership;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  factory _$BusinessResource(
          [void Function(BusinessResourceBuilder)? updates]) =>
      (BusinessResourceBuilder()..update(updates))._build();

  _$BusinessResource._(
      {required this.id,
      required this.name,
      this.legalName,
      this.description,
      required this.status,
      this.capabilities,
      this.primaryLocation,
      this.primaryContact,
      this.membership,
      this.createdAt,
      this.updatedAt})
      : super._();
  @override
  BusinessResource rebuild(void Function(BusinessResourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BusinessResourceBuilder toBuilder() =>
      BusinessResourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BusinessResource &&
        id == other.id &&
        name == other.name &&
        legalName == other.legalName &&
        description == other.description &&
        status == other.status &&
        capabilities == other.capabilities &&
        primaryLocation == other.primaryLocation &&
        primaryContact == other.primaryContact &&
        membership == other.membership &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, legalName.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, capabilities.hashCode);
    _$hash = $jc(_$hash, primaryLocation.hashCode);
    _$hash = $jc(_$hash, primaryContact.hashCode);
    _$hash = $jc(_$hash, membership.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BusinessResource')
          ..add('id', id)
          ..add('name', name)
          ..add('legalName', legalName)
          ..add('description', description)
          ..add('status', status)
          ..add('capabilities', capabilities)
          ..add('primaryLocation', primaryLocation)
          ..add('primaryContact', primaryContact)
          ..add('membership', membership)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class BusinessResourceBuilder
    implements Builder<BusinessResource, BusinessResourceBuilder> {
  _$BusinessResource? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _legalName;
  String? get legalName => _$this._legalName;
  set legalName(String? legalName) => _$this._legalName = legalName;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  ListBuilder<JsonObject?>? _capabilities;
  ListBuilder<JsonObject?> get capabilities =>
      _$this._capabilities ??= ListBuilder<JsonObject?>();
  set capabilities(ListBuilder<JsonObject?>? capabilities) =>
      _$this._capabilities = capabilities;

  BusinessLocationResourceBuilder? _primaryLocation;
  BusinessLocationResourceBuilder get primaryLocation =>
      _$this._primaryLocation ??= BusinessLocationResourceBuilder();
  set primaryLocation(BusinessLocationResourceBuilder? primaryLocation) =>
      _$this._primaryLocation = primaryLocation;

  BusinessContactResourceBuilder? _primaryContact;
  BusinessContactResourceBuilder get primaryContact =>
      _$this._primaryContact ??= BusinessContactResourceBuilder();
  set primaryContact(BusinessContactResourceBuilder? primaryContact) =>
      _$this._primaryContact = primaryContact;

  BusinessResourceMembershipBuilder? _membership;
  BusinessResourceMembershipBuilder get membership =>
      _$this._membership ??= BusinessResourceMembershipBuilder();
  set membership(BusinessResourceMembershipBuilder? membership) =>
      _$this._membership = membership;

  String? _createdAt;
  String? get createdAt => _$this._createdAt;
  set createdAt(String? createdAt) => _$this._createdAt = createdAt;

  String? _updatedAt;
  String? get updatedAt => _$this._updatedAt;
  set updatedAt(String? updatedAt) => _$this._updatedAt = updatedAt;

  BusinessResourceBuilder() {
    BusinessResource._defaults(this);
  }

  BusinessResourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _legalName = $v.legalName;
      _description = $v.description;
      _status = $v.status;
      _capabilities = $v.capabilities?.toBuilder();
      _primaryLocation = $v.primaryLocation?.toBuilder();
      _primaryContact = $v.primaryContact?.toBuilder();
      _membership = $v.membership?.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BusinessResource other) {
    _$v = other as _$BusinessResource;
  }

  @override
  void update(void Function(BusinessResourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BusinessResource build() => _build();

  _$BusinessResource _build() {
    _$BusinessResource _$result;
    try {
      _$result = _$v ??
          _$BusinessResource._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'BusinessResource', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'BusinessResource', 'name'),
            legalName: legalName,
            description: description,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'BusinessResource', 'status'),
            capabilities: _capabilities?.build(),
            primaryLocation: _primaryLocation?.build(),
            primaryContact: _primaryContact?.build(),
            membership: _membership?.build(),
            createdAt: createdAt,
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'capabilities';
        _capabilities?.build();
        _$failedField = 'primaryLocation';
        _primaryLocation?.build();
        _$failedField = 'primaryContact';
        _primaryContact?.build();
        _$failedField = 'membership';
        _membership?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BusinessResource', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
