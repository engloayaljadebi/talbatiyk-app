// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_business_request_contact.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateBusinessRequestContactTypeEnum
    _$createBusinessRequestContactTypeEnum_phone =
    const CreateBusinessRequestContactTypeEnum._('phone');
const CreateBusinessRequestContactTypeEnum
    _$createBusinessRequestContactTypeEnum_whatsapp =
    const CreateBusinessRequestContactTypeEnum._('whatsapp');
const CreateBusinessRequestContactTypeEnum
    _$createBusinessRequestContactTypeEnum_email =
    const CreateBusinessRequestContactTypeEnum._('email');
const CreateBusinessRequestContactTypeEnum
    _$createBusinessRequestContactTypeEnum_website =
    const CreateBusinessRequestContactTypeEnum._('website');

CreateBusinessRequestContactTypeEnum
    _$createBusinessRequestContactTypeEnumValueOf(String name) {
  switch (name) {
    case 'phone':
      return _$createBusinessRequestContactTypeEnum_phone;
    case 'whatsapp':
      return _$createBusinessRequestContactTypeEnum_whatsapp;
    case 'email':
      return _$createBusinessRequestContactTypeEnum_email;
    case 'website':
      return _$createBusinessRequestContactTypeEnum_website;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateBusinessRequestContactTypeEnum>
    _$createBusinessRequestContactTypeEnumValues = BuiltSet<
        CreateBusinessRequestContactTypeEnum>(const <CreateBusinessRequestContactTypeEnum>[
  _$createBusinessRequestContactTypeEnum_phone,
  _$createBusinessRequestContactTypeEnum_whatsapp,
  _$createBusinessRequestContactTypeEnum_email,
  _$createBusinessRequestContactTypeEnum_website,
]);

Serializer<CreateBusinessRequestContactTypeEnum>
    _$createBusinessRequestContactTypeEnumSerializer =
    _$CreateBusinessRequestContactTypeEnumSerializer();

class _$CreateBusinessRequestContactTypeEnumSerializer
    implements PrimitiveSerializer<CreateBusinessRequestContactTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'phone': 'phone',
    'whatsapp': 'whatsapp',
    'email': 'email',
    'website': 'website',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'phone': 'phone',
    'whatsapp': 'whatsapp',
    'email': 'email',
    'website': 'website',
  };

  @override
  final Iterable<Type> types = const <Type>[
    CreateBusinessRequestContactTypeEnum
  ];
  @override
  final String wireName = 'CreateBusinessRequestContactTypeEnum';

  @override
  Object serialize(
          Serializers serializers, CreateBusinessRequestContactTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateBusinessRequestContactTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateBusinessRequestContactTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateBusinessRequestContact extends CreateBusinessRequestContact {
  @override
  final CreateBusinessRequestContactTypeEnum type;
  @override
  final String value;
  @override
  final String? label;

  factory _$CreateBusinessRequestContact(
          [void Function(CreateBusinessRequestContactBuilder)? updates]) =>
      (CreateBusinessRequestContactBuilder()..update(updates))._build();

  _$CreateBusinessRequestContact._(
      {required this.type, required this.value, this.label})
      : super._();
  @override
  CreateBusinessRequestContact rebuild(
          void Function(CreateBusinessRequestContactBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateBusinessRequestContactBuilder toBuilder() =>
      CreateBusinessRequestContactBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateBusinessRequestContact &&
        type == other.type &&
        value == other.value &&
        label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateBusinessRequestContact')
          ..add('type', type)
          ..add('value', value)
          ..add('label', label))
        .toString();
  }
}

class CreateBusinessRequestContactBuilder
    implements
        Builder<CreateBusinessRequestContact,
            CreateBusinessRequestContactBuilder> {
  _$CreateBusinessRequestContact? _$v;

  CreateBusinessRequestContactTypeEnum? _type;
  CreateBusinessRequestContactTypeEnum? get type => _$this._type;
  set type(CreateBusinessRequestContactTypeEnum? type) => _$this._type = type;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  CreateBusinessRequestContactBuilder() {
    CreateBusinessRequestContact._defaults(this);
  }

  CreateBusinessRequestContactBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _value = $v.value;
      _label = $v.label;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateBusinessRequestContact other) {
    _$v = other as _$CreateBusinessRequestContact;
  }

  @override
  void update(void Function(CreateBusinessRequestContactBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateBusinessRequestContact build() => _build();

  _$CreateBusinessRequestContact _build() {
    final _$result = _$v ??
        _$CreateBusinessRequestContact._(
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'CreateBusinessRequestContact', 'type'),
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'CreateBusinessRequestContact', 'value'),
          label: label,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
