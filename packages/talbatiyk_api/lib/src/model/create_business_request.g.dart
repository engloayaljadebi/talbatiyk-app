// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_business_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateBusinessRequest extends CreateBusinessRequest {
  @override
  final String name;
  @override
  final String? legalName;
  @override
  final String? description;
  @override
  final BuiltList<String> capabilities;
  @override
  final CreateBusinessRequestLocation location;
  @override
  final CreateBusinessRequestContact contact;

  factory _$CreateBusinessRequest(
          [void Function(CreateBusinessRequestBuilder)? updates]) =>
      (CreateBusinessRequestBuilder()..update(updates))._build();

  _$CreateBusinessRequest._(
      {required this.name,
      this.legalName,
      this.description,
      required this.capabilities,
      required this.location,
      required this.contact})
      : super._();
  @override
  CreateBusinessRequest rebuild(
          void Function(CreateBusinessRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateBusinessRequestBuilder toBuilder() =>
      CreateBusinessRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateBusinessRequest &&
        name == other.name &&
        legalName == other.legalName &&
        description == other.description &&
        capabilities == other.capabilities &&
        location == other.location &&
        contact == other.contact;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, legalName.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, capabilities.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, contact.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateBusinessRequest')
          ..add('name', name)
          ..add('legalName', legalName)
          ..add('description', description)
          ..add('capabilities', capabilities)
          ..add('location', location)
          ..add('contact', contact))
        .toString();
  }
}

class CreateBusinessRequestBuilder
    implements Builder<CreateBusinessRequest, CreateBusinessRequestBuilder> {
  _$CreateBusinessRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _legalName;
  String? get legalName => _$this._legalName;
  set legalName(String? legalName) => _$this._legalName = legalName;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  ListBuilder<String>? _capabilities;
  ListBuilder<String> get capabilities =>
      _$this._capabilities ??= ListBuilder<String>();
  set capabilities(ListBuilder<String>? capabilities) =>
      _$this._capabilities = capabilities;

  CreateBusinessRequestLocationBuilder? _location;
  CreateBusinessRequestLocationBuilder get location =>
      _$this._location ??= CreateBusinessRequestLocationBuilder();
  set location(CreateBusinessRequestLocationBuilder? location) =>
      _$this._location = location;

  CreateBusinessRequestContactBuilder? _contact;
  CreateBusinessRequestContactBuilder get contact =>
      _$this._contact ??= CreateBusinessRequestContactBuilder();
  set contact(CreateBusinessRequestContactBuilder? contact) =>
      _$this._contact = contact;

  CreateBusinessRequestBuilder() {
    CreateBusinessRequest._defaults(this);
  }

  CreateBusinessRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _legalName = $v.legalName;
      _description = $v.description;
      _capabilities = $v.capabilities.toBuilder();
      _location = $v.location.toBuilder();
      _contact = $v.contact.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateBusinessRequest other) {
    _$v = other as _$CreateBusinessRequest;
  }

  @override
  void update(void Function(CreateBusinessRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateBusinessRequest build() => _build();

  _$CreateBusinessRequest _build() {
    _$CreateBusinessRequest _$result;
    try {
      _$result = _$v ??
          _$CreateBusinessRequest._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'CreateBusinessRequest', 'name'),
            legalName: legalName,
            description: description,
            capabilities: capabilities.build(),
            location: location.build(),
            contact: contact.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'capabilities';
        capabilities.build();
        _$failedField = 'location';
        location.build();
        _$failedField = 'contact';
        contact.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CreateBusinessRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
